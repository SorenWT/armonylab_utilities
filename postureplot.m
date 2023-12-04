function [pts,allpts] = postureplot(pos,doplot,scalef)
% pos must be a table of postural features from PostureScreen

% first set up a skeleton with all angles and displacements set to 0
% units in inches b/c I set the height of everyone to 6 ft
% coordinates are x (left to right), y (posterior to anterior), and z
% (bottom to top)

% points are sort of guesstimated - aim is more to make a
% reasonable-looking skeleton for visualization at this point

if nargin < 2
    doplot = 1;
end

if ~istable(pos) && length(pos)==20
    % special case for easy plotting of openpose datasets
    varnames = [
        {'Head_AnteriorAngulations'           }
        {'Shoulder_AnteriorAngulations'       }
        {'Hips/Pelvis_AnteriorAngulations'    }
        {'Head_AnteriorAngulationsX'          }
        {'Shoulder_AnteriorAngulationsX'      }
        {'Hips/Pelvis_AnteriorAngulationsX'   }
        {'Head_PosteriorAngulations'          }
        {'Shoulder_PosteriorAngulations'      }
        {'Hips/Pelvis_PosteriorAngulations'   }
        {'Head_PosteriorAngulationsX'         }
        {'Shoulder_PosteriorAngulationsX'     }
        {'Hips/Pelvis_PosteriorAngulationsX'  }
        {'Knees_post_LateralAngulations'      }
        {'Hips/Pelvis_post_LateralAngulations'}
        {'Shoulder_post_LateralAngulations'   }
        {'Head_post_LateralAngulations'       }
        {'Knees_LateralAngulations'           }
        {'Hips/Pelvis_LateralAngulations'     }
        {'Shoulder_LateralAngulations'        }
        {'Head_LateralAngulations'            }];
    
    warning('Setting variables assuming the standard OpenPOSE 20-angle angle set')
    pos = array2table(horz(pos),'VariableNames',horz(varnames));
    
end

if nargin < 3
    if any(contains(pos.Properties.VariableNames,'Stance'))
        tmpang = (pos.Stance_AnteriorAngulations+pos.Stance_PosteriorAngulations)/2;
        scalef = ones(1,10);
        scalef(10) = (12*scalef(5)+2*(18*scalef(1)+18*scalef(2))*sin(deg2rad(tmpang)))./(12*scalef(5));
    else
        scalef = ones(1,10);
    end
end

pts = construct_def_skeleton(scalef);
origpts = pts;

if ~contains(pos.Properties.VariableNames,'L_knee_xrot')
    pos = posture_convert_veridical(pos,pts);
end
%pos = posture_fix_format(pos);

%% Hips and legs
% first compute the left and right leg y rotations from the overall hip
% yrot and the hip/stance ratio
w1 = 12*scalef(5); w2 = 12*scalef(10);
d1 = 18*scalef(1)*cos(deg2rad(pos.R_knee_xrot))+18*scalef(2)*cos(deg2rad(pos.R_hip_xrot));
d2 = 18*scalef(1)*cos(deg2rad(pos.L_knee_xrot))+18*scalef(2)*cos(deg2rad(pos.L_hip_xrot));
thet = deg2rad(-pos.Hip_center_yrot);

syms phi1 phi2
[phi1,phi2] = vpasolve(w2==(d2*sin(phi2)+d1*sin(phi1)+w1*cos(asin((cos(phi1)/d1 + cos(phi2)/d2)/w1))),d1*sin(phi1)-d2*sin(phi2)==(d1*cos(phi1) + d2*cos(phi2))*tan(thet)/2,phi1,phi2);
R_leg_yrot = -rad2deg(double(phi1));
L_leg_yrot = -rad2deg(double(-phi2)); % left is positive

if ~isreal(R_leg_yrot) || ~isreal(L_leg_yrot) || isempty(R_leg_yrot) || isempty(L_leg_yrot)
    pts = origpts;
    allpts = plotstickman(pts,0);
    allpts = NaN*allpts;
    warning('Impossible posture - returning NaNs')
    return
end

rshinvect = origpts.knees{3}-origpts.ankles{3};
rshinrot = roty(R_leg_yrot)*rshinvect;
rshinrot = rot3d(roty(90)*rshinrot,-pos.R_knee_xrot)*rshinrot;

lshinvect = origpts.knees{1}-origpts.ankles{1};
lshinrot = roty(L_leg_yrot)*lshinvect;
lshinrot = rot3d(roty(90)*lshinrot,-pos.L_knee_xrot)*lshinrot;

pts.knees{3} = pts.ankles{3}+rshinrot;
pts.knees{1} = pts.ankles{1}+lshinrot;
pts.knees{2} = (pts.knees{1}+pts.knees{3})/2;

rthighvect = origpts.knees{3}-origpts.ankles{3};
rthighrot = roty(R_leg_yrot)*rthighvect;
rthighrot = rot3d(roty(90)*rthighrot,-pos.R_hip_xrot)*rthighrot;

lthighvect = origpts.knees{1}-origpts.ankles{1};
lthighrot = roty(L_leg_yrot)*lthighvect;
lthighrot = rot3d(roty(90)*lthighrot,-pos.L_hip_xrot)*lthighrot;

pts.hips{3} = pts.knees{3}+rthighrot;
pts.hips{1} = pts.knees{1}+lthighrot;
pts.hips{2} = (pts.hips{1}+pts.hips{3})/2;

%% Shoulders and torso

% keeping the spine points, but assuming for now that we don't have posturescreen so we just use the shoulder ones
% change this if we later add a manually-defined ribcage point

% do all the torso xrot and yrot things first, then do the tilts and twists
l3vect = origpts.l3{1}-origpts.hips{2};
l3rot = roty(pos.Torso_yrot)*l3vect;
l3rot = rot3d(roty(90)*l3rot,-pos.Torso_xrot)*l3rot;
pts.l3{1} = pts.hips{2}+l3rot;

t12vect = origpts.t12{1}-origpts.l3{1};
t12rot = roty(pos.Torso_yrot)*t12vect;
t12rot = rot3d(roty(90)*t12rot,-pos.Torso_xrot)*t12rot;
pts.t12{1} = pts.l3{1}+t12rot;

t8vect = origpts.t8{2}-origpts.t12{1};
t8rot = roty(pos.Torso_yrot)*t8vect;
t8ortho = roty(90)*t8rot; % save so we can use later for ribs
t8rot = rot3d(roty(90)*t8rot,-pos.Torso_xrot)*t8rot;
pts.t8{2} = pts.t12{1}+t8rot;

t4vect = origpts.t4{1}-origpts.t8{2};
t4rot = roty(pos.Torso_yrot)*t4vect;
t4rot = rot3d(roty(90)*t4rot,-pos.Torso_xrot)*t4rot;
pts.t4{1} = pts.t8{2}+t4rot;

shouldersvect = origpts.shoulders{2}-origpts.t4{1};
shouldersrot = roty(pos.Torso_yrot)*shouldersvect;
shouldersortho = roty(90)*shouldersrot;
shouldersrot = rot3d(roty(90)*shouldersrot,-pos.Torso_xrot)*shouldersrot;
pts.shoulders{2} = pts.t4{1}+shouldersrot;

% now do the twists and tilts
% twist before tilt

torsodir = ((pts.t8{2}-pts.t12{1})./norm(pts.t8{2}-pts.t12{1})); % unit vector along torso axis
%ribvect = roty(90)*torsodir*norm(origpts.t8{1}-origpts.t8{2});
ribvect = (t8ortho./norm(t8ortho))*norm(origpts.t8{1}-origpts.t8{2});
ribrot = rot3d(torsodir,pos.Torso_twist)*ribvect;
newdir = cross(ribrot,torsodir); % get the axis for tilt rotation
ribrot = rot3d(newdir,pos.Torso_tilt)*ribrot;
pts.t8{1} = pts.t8{2}-ribrot;
pts.t8{3} = pts.t8{2}+ribrot;

torsodir = ((pts.shoulders{2}-pts.t4{1})./norm(pts.shoulders{2}-pts.t4{1})); % unit vector along torso axis
%shouldersvect2 = roty(90)*torsodir*norm(origpts.shoulders{1}-origpts.shoulders{2});
shouldersvect2 = (shouldersortho./norm(shouldersortho))*norm(origpts.shoulders{1}-origpts.shoulders{2});
shouldersrot2 = rot3d(torsodir,pos.Torso_twist)*shouldersvect2;
newdir = cross(shouldersrot2,torsodir); % get the axis for tilt rotation
shouldersrot2 = rot3d(newdir,pos.Torso_tilt)*shouldersrot2;
pts.shoulders{1} = pts.shoulders{2}-shouldersrot2;
pts.shoulders{3} = pts.shoulders{2}+shouldersrot2;

%% Head

headvect = origpts.head{2}-origpts.shoulders{2};
headrot = roty(pos.Head_yrot)*headvect;
headortho = roty(90)*headrot;
headrot = rot3d(roty(90)*headrot,-pos.Head_xrot)*headrot;
pts.head{2} = pts.shoulders{2}+headrot;

headdir = ((pts.head{2}-pts.shoulders{2})./norm(pts.head{2}-pts.shoulders{2})); % unit vector along head axis
headvect2 = (headortho./norm(headortho))*norm(origpts.head{1}-origpts.head{2});
%headvect2 = roty(90)*headdir*norm(origpts.shoulders{1}-origpts.shoulders{2});
headrot2 = rot3d(headdir,pos.Head_twist)*headvect2;
newdir = cross(headrot2,headdir); % get the axis for tilt rotation
headrot2 = rot3d(newdir,pos.Head_tilt)*headrot2;
pts.head{1} = pts.head{2}-headrot2;
pts.head{3} = pts.head{2}+headrot2;

% do the head pitch
earaxis = pts.head{3}-pts.head{1}; % rotation axis running through ears
nosevect = cross(headdir,earaxis)./norm(cross(headdir,earaxis))*norm(origpts.nose{1}-origpts.head{2});
noserot = rot3d(earaxis,pos.Head_pitch)*nosevect;
pts.nose{1} = pts.head{2}+noserot;

%% Elbows

% elbow angles are defined relative to hanging down vertically

relbowvect = origpts.elbows{1}-origpts.shoulders{1};
relbowrot = roty(-pos.R_elbow_yrot)*relbowvect;
relbowrot = rot3d(roty(90)*relbowrot,-pos.R_elbow_xrot)*relbowrot;

lelbowvect = origpts.elbows{2}-origpts.shoulders{3};
lelbowrot = roty(-pos.L_elbow_yrot)*lelbowvect;
lelbowrot = rot3d(roty(90)*lelbowrot,-pos.L_elbow_xrot)*lelbowrot;

pts.elbows{2} = pts.shoulders{3}+relbowrot;
pts.elbows{1} = pts.shoulders{1}+lelbowrot;

%% Plot everything

allpts = plotstickman(pts,doplot);

end

function pts = construct_def_skeleton(scalef)

% scalef has 7 values:
% 1 - calf length
% 2 - thigh length
% 3 - torso length (OpenPOSE has this all as one segment, so only one scale factor)
% 4 - neck length
% 5 - hip width
% 6 - shoulder width
% 7 - head width


pts.ankles = {[-6*scalef(10) 0 -36]' [0 0 -36]' [6*scalef(10) 0 -36]'};
for i = 1:3
    pts.knees{i} = pts.ankles{i}+[0 0 18*scalef(1)]';
end

for i = 1:3
    %pts.hips{i} = pts.knees{i}+[(i-2)*(scalef(5)-1) 0 18*scalef(2)]';
    pts.hips{i} = [scalef(5)*6*(i-2) 0 18*scalef(2)+18*scalef(1)-36]';
end

pts.l3{1} = pts.hips{2}+[0 0 4*scalef(3)]';
pts.t12{1} = pts.l3{1}+[0 0 4*scalef(3)]';
pts.t8 = {pts.t12{1}+[-7.5*(scalef(5)+scalef(6))/2 0 4*scalef(3)]' pts.t12{1}+[0 0 4*scalef(3)]' pts.t12{1}+[7.5*(scalef(5)+scalef(6))/2 0 4*scalef(3)]'};
pts.t4{1} = pts.t8{2}+[0 0 7.5*scalef(3)]';
pts.shoulders = {pts.t4{1}+[-10*scalef(6) 0 7.5*scalef(3)]' pts.t4{1}+[0 0 7.5*scalef(3)]' pts.t4{1}+[10*scalef(6) 0 7.5*scalef(3)]'};
pts.head = {pts.shoulders{2}+[-3*scalef(7) 0 9*scalef(4)]' pts.shoulders{2}+[0 0 9*scalef(4)]' pts.shoulders{2}+[3*scalef(7) 0 9*scalef(4)]'};

pts = orderfields(pts,9:-1:1);
pts.elbows = {pts.shoulders{1}-[0 0 15*scalef(9)]' pts.shoulders{3}-[0 0 15*scalef(9)]'};
pts.nose = {pts.head{2}+[0 4*scalef(8) 0]'};

% pts.head = {[-2 0 36]' [0 0 36]' [2 0 36]'};
% pts.shoulders = {[-10.5 0 27]' [0 0 27]' [10.5 0 27]'};
% pts.t4 = {[0 0 19.5]'};
% pts.t8 = {[-9 0 12]' [0 0 12]' [9 0 12]'};
% pts.t12 = {[0 0 8]'};
% pts.l3 = {[0 0 4]'};
% pts.hips = {[-7.5 0 0]' [0 0 0]' [7.5 0 0]'};
% pts.knees = {[-4.5 0 -18]' [0 0 -18]' [4.5 0 -18]'};
% pts.ankles = {[-4.5 0 -36]' [0 0 -36]' [4.5 0 -36]'};

% make ankles the origin
f = fields(pts);
for i = 1:length(f)
    for ii = 1:length(pts.(f{i}))
        pts.(f{i}){ii}(3) = pts.(f{i}){ii}(3) + 36;
    end
end


end

function pos = pts2pos(allpts)

% convert allpts to pts for convenience
pos = table;

pos.Head_AnteriorTranslations = pts.head{1}(1);
pos.Shoulder_AnteriorTranslations = (pts.shoulders{1}(1)+pts.shoulders{3}(1));
pos.Ribcage_AnteriorTranslations = (pts.t8{1}(1)+pts.t8{3}(1));
pos.('Hips/Pelvis_AnteriorTranslations') = (pts.hips{1}(1)+pts.hips{3}(1));
pos.Head_AnteriorAngulations = 0; % fix this later - need to add eyes to head point
pos.Shoulder_AnteriorAngulations = rad2deg(atan((pts.shoulders{3}(2)-pts.shoulders{1}(2))./(pts.shoulders{3}(1)-pts.shoulders{1}(1))));
pos.('Hips/Pelvis_AnteriorAngulations') = rad2deg(atan((pts.hips{3}(2)-pts.hips{1}(2))./(pts.hips{3}(1)-pts.hips{1}(1))));




end

function allpts = plotstickman(pts,doplot)
% original, before adding elbows and feet
%connpairs = {[1 2] [2 3] [2 5] [4 5] [5 6] [5 7] [7 9] [8 9] [9 10] [9 11] [11 12] ...
%    [12 14] [13 14] [14 15] [14 17] [16 17] [17 18] [17 20] [19 20] [20 21]};

connpairs = {[1 2] [2 3] [2 5] [4 5] [5 6] [5 7] [7 9] [8 9] [9 10] [9 11] [11 12] ...
    [12 14] [13 14] [14 15] [13 16] [15 18] [16 19] [18 21] [4 22] [6 23] [2 24]};

fields = fieldnames(pts);
allpts = [];
for i = 1:length(fields)
    allpts = cat(2,allpts,pts.(fields{i}){:});
end

if doplot
    dontplot = [17 20];
    scatter3(allpts(1,except(1:length(allpts),dontplot)),allpts(2,except(1:length(allpts),dontplot)),allpts(3,except(1:length(allpts),dontplot)),96,'k','filled')
    axis equal
    set(gca,'XGrid','off','YGrid','off','ZGrid','off')
    set(gcf,'color','w')
    
    for i = 1:length(connpairs)
        line([allpts(1,connpairs{i}(1)) allpts(1,connpairs{i}(2))],...
            [allpts(2,connpairs{i}(1)) allpts(2,connpairs{i}(2))],...
            [allpts(3,connpairs{i}(1)) allpts(3,connpairs{i}(2))],'LineWidth',3);
    end
end


end

function matout=rot3d(ax,amnt)
matout = makehgtform('axisrotate',ax,deg2rad(amnt));
matout = matout(1:3,1:3); % only want 3D part
end
