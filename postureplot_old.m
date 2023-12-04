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

if nargin < 3
    scalef = ones(1,9);
end

pts = construct_def_skeleton(scalef);
origpts = pts;

pos = posture_convert_veridical(pos);
%pos = posture_fix_format(pos);

%% Hips and legs
%ang = (pos.('Hips/Pelvis_AnteriorAngulationsX')+pos.('Hips/Pelvis_PosteriorAngulationsX'))/2; % this is the veridical angle now, it's either already been averaged or it doesn't have any relation to the measured angles
ang = pos.('Hips/Pelvis_AnteriorAngulationsX');
pts.knees{2} = roty(ang)*pts.knees{2};
pts.hips{2} = roty(ang)*pts.hips{2};

newax = pts.hips{2}; % define new axis for rotation

pts.knees{2} = rot3D(newax,-pos.Knees_LateralAngulations)*pts.knees{2};

%pts.knees{1} = pts.knees{2}; pts.knees{1}(1) = pts.knees{1}(1)-4.5;
pts.knees{1} = rotz(pos.Knees_LateralTwist)*(origpts.knees{1}-origpts.knees{2})+pts.knees{2};
pts.knees{3} = pts.knees{2}; pts.knees{3}(1) = pts.knees{3}(1)+4.5;
pts.knees{3} = rotz(pos.Knees_LateralTwist)*(pts.knees{3}-pts.knees{2})+pts.knees{2};


pts.hips{2} = rotx(-pos.('Hips/Pelvis_LateralAngulations'))*(pts.hips{2}-origpts2.knees{2})+pts.knees{2};

pts.hips{1} = pts.hips{2}; pts.hips{1}(1) = pts.hips{1}(1)-abs(origpts.hips{2}(1)-origpts.hips{1}(1));
pts.hips{1} = rotz(pos.('Hips/Pelvis_LateralTwist'))*(pts.hips{1}-pts.hips{2})+pts.hips{2};
pts.hips{3} = pts.hips{2}; pts.hips{3}(1) = pts.hips{3}(1)+abs(origpts.hips{2}(1)-origpts.hips{1}(1));
pts.hips{3} = rotz(pos.('Hips/Pelvis_LateralTwist'))*(pts.hips{3}-pts.hips{2})+pts.hips{2};



% balance the posterior-view spine angulations with the anterior view ribcage angulations
% otherwise there might be large-looking shifts at the ribcage level
%ang = (pos.('L3-MidPSIS_PosteriorAngulations') + pos.('Ribcage_AnteriorAngulationsX'))/2;
%ang = pos.('L3-MidPSIS_PosteriorAngulations');

%% Shoulders and torso

% keeping the spine points, but assuming for now that we don't have posturescreen so we just use the shoulder ones
% change this if we later add a manually-defined ribcage point 
ang = pos.Shoulder_AnteriorAngulationsX;
pts.l3{1} = pts.hips{2}+roty(ang)*(pts.l3{1}-origpts.hips{2});
pts.t12{1} = pts.l3{1}+roty(ang)*(pts.t12{1}-origpts.l3{1});

%ang = (pos.('Ribcage_AnteriorAngulationsX')+pos.('Ribcage_PosteriorAngulationsX'))/2;
pts.t8{2} = pts.hips{2}+roty(ang)*(pts.t8{2}-origpts.hips{2});
% the roty(90) is only because the ribcage doesn't have any angles to it in
% posturescreen (and isn't a thing in openpose)
newdir = (pts.t8{2}-pts.hips{2})/norm(pts.t8{2}-pts.hips{2}); % unit vector in direction of t8 from hips
pts.t8{1} =  pts.t8{2} + roty(90)*newdir*norm(origpts.t8{2}-origpts.t8{1}); % orthogonal to newdir and with length equal to the original rib size
pts.t8{3} = pts.t8{2} + roty(-90)*newdir*norm(origpts.t8{2}-origpts.t8{3});

%ang = (pos.('T4-T8_PosteriorAngulations') + pos.('Shoulder_AnteriorAngulationsX'))/2;
pts.t4{1} = pts.t8{2}+roty(ang)*(pts.t4{1}-origpts.t8{2});

%ang = (pos.('Shoulder_PosteriorAngulationsX') + pos.('Shoulder_AnteriorAngulationsX'))/2;
pts.shoulders{2} = pts.t8{2}+roty(ang)*(origpts.shoulders{2}-origpts.t8{2});

%ang2 = (pos.('Shoulder_PosteriorAngulations') + pos.('Shoulder_AnteriorAngulations'))/2;
% dealing with veridical angles, so don't need front and back views
ang2 = pos.Shoulder_AnteriorAngulations;

newdir = (pts.shoulders{2}-pts.t8{2})/norm(pts.shoulders{2}-pts.t8{2}); % unit vector in direction of shoulders from t8 (same as from hips right now)
pts.shoulders{1} =  pts.shoulders{2} + roty(-ang2)*roty(90)*newdir*norm(origpts.shoulders{2}-origpts.shoulders{1}); % orthogonal to newdir and with length equal to the original shoulder size
pts.shoulders{3} = pts.shoulders{2} + roty(-ang2)*roty(-90)*newdir*norm(origpts.shoulders{2}-origpts.shoulders{3});


newax = pts.t8{2}-pts.hips{2}; % axis from hips to t8
newaxortho = roty(90)*newax; % orthogonal to newax - for lateral angulations
ang = -pos.('Shoulder_LateralAngulations');

pts.l3{1} = rot3d(newaxortho,ang)*(pts.l3{1}-pts.hips{2})+pts.hips{2};
pts.t12{1} = rot3d(newaxortho,ang)*(pts.t12{1}-pts.hips{2})+pts.hips{2};

pts.t8{2} = rot3d(newax,ang)*(pts.t8{2}-origpts2.hips{2})+pts.hips{2};


% deal with the ribs
newdir = (pts.t8{2}-pts.hips{2})/norm(pts.t8{2}-pts.hips{2}); % unit vector in direction of t8 from hips
pts.t8{1} =  pts.t8{2} + rot3d(newaxortho,90)*newdir*norm(origpts.t8{2}-origpts.t8{1}); % orthogonal to newdir and with length equal to the original rib size
pts.t8{3} =  pts.t8{2} + rot3d(newaxortho,-90)*newdir*norm(origpts.t8{2}-origpts.t8{3}); % orthogonal to newdir and with length equal to the original rib size
% now rotate to be in line with the twists on the hips/shoulders
ang = (pos.('Hips/Pelvis_LateralTwist')+pos.Shoulder_LateralTwist)/2;
pts.t8{1} = rot3d(newax,ang)*(pts.t8{1}-pts.t8{2})+pts.t8{2};
pts.t8{3} = rot3d(newax,ang)*(pts.t8{3}-pts.t8{2})+pts.t8{2};

ang = -pos.Shoulder_LateralAngulations;
pts.t4{1} = rot3d(newaxortho,ang)*(pts.t4{1}-pts.t8{2})+pts.hips{2};

pts.shoulders{2} = rotx(-pos.('Shoulder_LateralAngulations'))*(pts.shoulders{2}-origpts2.hips{2})+pts.hips{2};

pts.shoulders{1} = pts.shoulders{2}; pts.shoulders{1}(1) = pts.shoulders{1}(1)-10.5;
pts.shoulders{1} = rotz(pos.('Shoulder_LateralTwist'))*(pts.shoulders{1}-pts.shoulders{2})+pts.shoulders{2};
pts.shoulders{3} = pts.shoulders{2}; pts.shoulders{3}(1) = pts.shoulders{3}(1)+10.5;
pts.shoulders{3} = rotz(pos.('Shoulder_LateralTwist'))*(pts.shoulders{3}-pts.shoulders{2})+pts.shoulders{2};





%% Head
ang = (pos.('Head_PosteriorAngulationsX') + pos.('Head_AnteriorAngulationsX'))/2;
pts.head{2} = pts.shoulders{2}+roty(ang)*(pts.head{2}-origpts.shoulders{2});

ang2 = (pos.('Head_PosteriorAngulations') + pos.('Head_AnteriorAngulations'))/2;
pts.head{1} = pts.head{2}; pts.head{1}(1) = pts.head{1}(1)-2; pts.head{1} = roty(-ang2)*(pts.head{1}-pts.head{2})+pts.head{2};
pts.head{3} = pts.head{2}; pts.head{3}(1) = pts.head{3}(1)+2; pts.head{3} = roty(-ang2)*(pts.head{3}-pts.head{2})+pts.head{2};

% now do the lateral view stuff

% new reference for lateral changes
origpts2 = pts;


pts.knees{2} = rotx(-pos.Knees_LateralAngulations)*pts.knees{2};

pts.knees{1} = pts.knees{2}; pts.knees{1}(1) = pts.knees{1}(1)-4.5;
pts.knees{1} = rotz(pos.Knees_LateralTwist)*(pts.knees{1}-pts.knees{2})+pts.knees{2};
pts.knees{3} = pts.knees{2}; pts.knees{3}(1) = pts.knees{3}(1)+4.5;
pts.knees{3} = rotz(pos.Knees_LateralTwist)*(pts.knees{3}-pts.knees{2})+pts.knees{2};


pts.hips{2} = rotx(-pos.('Hips/Pelvis_LateralAngulations'))*(pts.hips{2}-origpts2.knees{2})+pts.knees{2};

pts.hips{1} = pts.hips{2}; pts.hips{1}(1) = pts.hips{1}(1)-abs(origpts.hips{2}(1)-origpts.hips{1}(1));
pts.hips{1} = rotz(pos.('Hips/Pelvis_LateralTwist'))*(pts.hips{1}-pts.hips{2})+pts.hips{2};
pts.hips{3} = pts.hips{2}; pts.hips{3}(1) = pts.hips{3}(1)+abs(origpts.hips{2}(1)-origpts.hips{1}(1));
pts.hips{3} = rotz(pos.('Hips/Pelvis_LateralTwist'))*(pts.hips{3}-pts.hips{2})+pts.hips{2};

pts.l3{1} = rotx(-pos.('Shoulder_LateralAngulations'))*(pts.l3{1}-origpts2.hips{2})+pts.hips{2};
pts.t12{1} = rotx(-pos.('Shoulder_LateralAngulations'))*(pts.t12{1}-origpts2.hips{2})+pts.hips{2};

pts.t8{2} = rotx(-pos.('Shoulder_LateralAngulations'))*(pts.t8{2}-origpts2.hips{2})+pts.hips{2};

% rotate the ribcage to be in line with the twists of the hips and
% shoulders
ang = (pos.('Hips/Pelvis_LateralTwist')+pos.Shoulder_LateralTwist)/2;

pts.t8{1} = pts.t8{2}; pts.t8{1}(1) = pts.t8{1}(1)-9;
pts.t8{1} = rotz(ang)*(pts.t8{1}-pts.t8{2})+pts.t8{2};
pts.t8{3} = pts.t8{2}; pts.t8{3}(1) = pts.t8{3}(1)+9;
pts.t8{3} = rotz(ang)*(pts.t8{3}-pts.t8{2})+pts.t8{2};

pts.t4{1} = rotx(-pos.('Shoulder_LateralAngulations'))*(pts.t4{1}-origpts2.hips{2})+pts.hips{2};

pts.shoulders{2} = rotx(-pos.('Shoulder_LateralAngulations'))*(pts.shoulders{2}-origpts2.hips{2})+pts.hips{2};

pts.shoulders{1} = pts.shoulders{2}; pts.shoulders{1}(1) = pts.shoulders{1}(1)-10.5;
pts.shoulders{1} = rotz(pos.('Shoulder_LateralTwist'))*(pts.shoulders{1}-pts.shoulders{2})+pts.shoulders{2};
pts.shoulders{3} = pts.shoulders{2}; pts.shoulders{3}(1) = pts.shoulders{3}(1)+10.5;
pts.shoulders{3} = rotz(pos.('Shoulder_LateralTwist'))*(pts.shoulders{3}-pts.shoulders{2})+pts.shoulders{2};

pts.head{2} = rotx(-pos.('Head_LateralAngulations'))*(pts.head{2}-origpts2.shoulders{2})+pts.shoulders{2};

pts.head{1} = pts.head{2}; pts.head{1}(1) = pts.head{1}(1)-2;
pts.head{1} = rotz(pos.('Head_LateralTwist'))*(pts.head{1}-pts.head{2})+pts.head{2};
pts.head{3} = pts.head{2}; pts.head{3}(1) = pts.head{3}(1)+2;
pts.head{3} = rotz(pos.('Head_LateralTwist'))*(pts.head{3}-pts.head{2})+pts.head{2};

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


pts.ankles = {[-6 0 -36]' [0 0 -36]' [6 0 -36]'};
for i = 1:3
   pts.knees{i} = pts.ankles{i}+[0 0 18*scalef(1)]'; 
end

for i = 1:3
   pts.hips{i} = pts.knees{i}+[(i-2)*(scalef(5)-1) 0 18*scalef(2)]'; 
end

pts.l3{1} = pts.hips{2}+[0 0 4*scalef(3)]';
pts.t12{1} = pts.l3{1}+[0 0 4*scalef(3)]';
pts.t8 = {pts.t12{1}+[-7.5*(scalef(3)+scalef(4))/2 0 4*scalef(3)]' pts.t12{1}+[0 0 4*scalef(3)]' pts.t12{1}+[7.5*(scalef(3)+scalef(4))/2 0 4*scalef(3)]'};
pts.t4{1} = pts.t8{2}+[0 0 7.5*scalef(3)]';
pts.shoulders = {pts.t4{1}+[-10*scalef(6) 0 7.5*scalef(3)]' pts.t4{1}+[0 0 7.5*scalef(3)]' pts.t4{1}+[10*scalef(6) 0 7.5*scalef(3)]'};
pts.head = {pts.shoulders{2}+[-2*scalef(7) 0 9*scalef(4)]' pts.shoulders{2}+[0 3*scalef(8) 9*scalef(4)]' pts.shoulders{2}+[2*scalef(7) 0 9*scalef(4)]'};

pts = orderfields(pts,9:-1:1);
pts.elbows = {pts.shoulders{1}-[0 0 15*scalef(9)]' pts.shoulders{3}-[0 0 15*scalef(9)]'};

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
   [12 14] [13 14] [14 15] [13 16] [15 18] [16 19] [18 21] [4 22] [6 23]};

fields = fieldnames(pts);
allpts = [];
for i = 1:length(fields)
    allpts = cat(2,allpts,pts.(fields{i}){:});
end

if doplot
scatter3(allpts(1,:),allpts(2,:),allpts(3,:),96,'k','filled')
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
