function posout = posture_convert_veridical(posin,pts)
% this function converts a set of measured angles and variables to

originnames = posin.Properties.VariableNames;

hasribcage = any(contains(originnames,'Ribcage'));

hastwist = any(contains(originnames,'Twist'));

hasspine = any(contains(originnames','T1-T4'));

hasdisplacements = any(contains(originnames,'Translations'));

hasextended = any(contains(originnames,'Stance'));

hasantpost = any(contains(originnames,'Anterior'));

isaveraged = ~any(contains(originnames,'Posterior'));

if nargin < 2
    pts.head = {[-2 0 36] [0 0 36] [2 0 36]};
    pts.shoulders = {[-10.5 0 27] [0 0 27] [10.5 0 27]};
    pts.t4 = {[0 0 19.5]};
    pts.t8 = {[-9 0 12] [0 0 12] [9 0 12]};
    pts.t12 = {[0 0 8]};
    pts.l3 = {[0 0 4]};
    pts.hips = {[-7.5 0 0] [0 0 0] [7.5 0 0]};
    pts.knees = {[-4.5 0 -18] [0 0 -18] [4.5 0 -18]};
    pts.ankles = {[-4.5 0 -36] [0 0 -36] [4.5 0 -36]};
end

posout = posin;

if ~hastwist
    if ~hasantpost
        posout.('Hips/Pelvis_AnteriorAngulations') = 0;
        posout.Shoulder_AnteriorAngulations = 0;
        posout.Head_AnteriorAngulations = 0;
        posout.('Hips/Pelvis_AnteriorAngulationsX') = 0;
        posout.Shoulder_AnteriorAngulationsX = 0;
        posout.Head_AnteriorAngulationsX = 0;
        originnames = posout.Properties.VariableNames;
    end
    
    % fix openpose info
    if ~hasribcage
        shouldervars = find(contains(originnames,'Shoulder_AnteriorAngulationsX') | ...
            contains(originnames,'Shoulder_PosteriorAngulationsX'));
        
        for i = 1:length(shouldervars)
            vname = replace(originnames{shouldervars(i)},'Shoulder','Ribcage');
            posout.(vname) = posout.(originnames{shouldervars(i)});
        end
    end
    originnames = posout.Properties.VariableNames;
    
    if isaveraged
        eqvars = originnames(contains(originnames,'Lateral'));
        postvars = replace(eqvars,'_Lateral','_post_Lateral');
        for i = 1:length(postvars)
            if ~any(contains(posout.Properties.VariableNames,postvars{i}))
                posout.(postvars{i}) = -posout.(eqvars{i}); % put the mislabeled sign back
            end
        end
        
        eqvars = originnames(contains(originnames,'Anterior'));
        postvars = replace(eqvars,'Anterior','Posterior');
        for i = 1:length(postvars)
            if ~any(contains(posout.Properties.VariableNames,postvars{i}))
                
                posout.(postvars{i}) = posout.(eqvars{i});
            end
        end
    end
    
    if ~hasspine
        posout.('T1-T4_PosteriorAngulations') = posout.Shoulder_PosteriorAngulationsX;
        posout.('T4-T8_PosteriorAngulations') = posout.Shoulder_PosteriorAngulationsX;
        posout.('T8-T12_PosteriorAngulations') = posout.Ribcage_PosteriorAngulationsX;
        posout.('T12-L3_PosteriorAngulations') = posout.Ribcage_PosteriorAngulationsX;
        posout.('L3-MidPSIS_PosteriorAngulations') = posout.Ribcage_PosteriorAngulationsX;
    end
    
    if hasdisplacements
        posout.Head_AnteriorAngulationsX = rad2deg(asin(posout.Head_AnteriorTranslations./(pts.head{2}(3)-pts.shoulders{2}(3))));
        posout.Shoulder_AnteriorAngulationsX = rad2deg(asin(posout.Shoulder_AnteriorTranslations./(pts.shoulders{2}(3)-pts.t8{2}(3))));
        posout.Ribcage_AnteriorAngulationsX = rad2deg(asin(posout.Ribcage_AnteriorTranslations./(pts.t8{2}(3)-pts.hips{2}(3))));
        posout.('Hips/Pelvis_AnteriorAngulationsX') = rad2deg(asin(posout.('Hips/Pelvis_AnteriorTranslations')./(pts.hips{2}(3)-pts.ankles{2}(3))));
        
        posout.Head_PosteriorAngulationsX = rad2deg(asin(posout.Head_PosteriorTranslations./(pts.head{2}(3)-pts.shoulders{2}(3))));
        posout.Shoulder_PosteriorAngulationsX = rad2deg(asin(posout.Shoulder_PosteriorTranslations./(pts.shoulders{2}(3)-pts.t8{2}(3))));
        posout.Ribcage_PosteriorAngulationsX = rad2deg(asin(posout.Ribcage_PosteriorTranslations./(pts.t8{2}(3)-pts.hips{2}(3))));
        posout.('Hips/Pelvis_PosteriorAngulationsX') = rad2deg(asin(posout.('Hips/Pelvis_PosteriorTranslations')./(pts.hips{2}(3)-pts.ankles{2}(3))));
    end
    
    % in this new version, we want to keep the hip and knee variables
    % separate, so only keep the twists for the shoulders and head
    
    tmppos = posout;
    
    posout = posturedata_convert_twist(posout,pts);
    
    posout.('Knees_LateralAngulations') = tmppos.('Knees_LateralAngulations');
    posout.('Knees_post_LateralAngulations') = tmppos.('Knees_post_LateralAngulations');
    try
    posout.('Hips/Pelvis_LateralAngulations') = tmppos.('Hips/Pelvis_LateralAngulations');
    posout.('Hips/Pelvis_post_LateralAngulations') = tmppos.('Hips/Pelvis_post_LateralAngulations');
    catch
            posout.('Hips/Pelvis_LateralAngulations') = tmppos.('Hips_Pelvis_LateralAngulations');
    posout.('Hips/Pelvis_post_LateralAngulations') = tmppos.('Hips_Pelvis_post_LateralAngulations');
    end
    
    posout.Knees_LateralTwist = []; posout.('Hips/Pelvis_LateralTwist') = [];
    
else
    if ~hasribcage
        shouldervars = find(contains(originnames,'Shoulder_AnteriorAngulationsX') | ...
            contains(originnames,'Shoulder_PosteriorAngulationsX'));
        
        for i = 1:length(shouldervars)
            vname = replace(originnames{shouldervars(i)},'Shoulder','Ribcage');
            posout.(vname) = posout.(originnames{shouldervars(i)});
        end
    end
    originnames = posout.Properties.VariableNames;
    
    if ~hasspine
        posout.('T1-T4_PosteriorAngulations') = posout.Shoulder_PosteriorAngulationsX;
        posout.('T4-T8_PosteriorAngulations') = posout.Shoulder_PosteriorAngulationsX;
        posout.('T8-T12_PosteriorAngulations') = posout.Ribcage_PosteriorAngulationsX;
        posout.('T12-L3_PosteriorAngulations') = posout.Ribcage_PosteriorAngulationsX;
        posout.('L3-MidPSIS_PosteriorAngulations') = posout.Ribcage_PosteriorAngulationsX;
    end
    
    % convert knee angles and hip back to original
    
end

if ~hasextended
    posout.Head_LateralAngulationsX = 0; posout.Head_post_LateralAngulationsX = 0;
    % not using stance
    %posout.Stance_AnteriorAngulations = 0; posout.Stance_PosteriorAngulations = 0;
    posout.Elbows_AnteriorAngulations = 0; posout.Elbows_PosteriorAngulations = 0;
    posout.Elbows_LateralAngulations = 0; posout.Elbows_post_LateralAngulations = 0;
end

% with the new postureplot, we only want to work with real angles, rather
% than measured ones. So do some averaging and get rid of duplicates

posout.Head_AnteriorAngulations = (posout.Head_AnteriorAngulations+posout.Head_PosteriorAngulations)/2;
posout.Shoulder_AnteriorAngulations = (posout.Shoulder_AnteriorAngulations+posout.Shoulder_PosteriorAngulations)/2;
try
posout.('Hips/Pelvis_AnteriorAngulations') = (posout.('Hips/Pelvis_AnteriorAngulations')+posout.('Hips/Pelvis_PosteriorAngulations'))/2;
catch
    posout.('Hips/Pelvis_AnteriorAngulations') = (posout.('Hips_Pelvis_AnteriorAngulations')+posout.('Hips_Pelvis_PosteriorAngulations'))/2;

end

posout.Head_AnteriorAngulationsX = (posout.Head_AnteriorAngulationsX+posout.Head_PosteriorAngulationsX)/2;
posout.Shoulder_AnteriorAngulationsX = (posout.Shoulder_AnteriorAngulationsX+posout.Shoulder_PosteriorAngulationsX)/2;
try
posout.('Hips/Pelvis_AnteriorAngulationsX') = (posout.('Hips/Pelvis_AnteriorAngulationsX')+posout.('Hips/Pelvis_PosteriorAngulationsX'))/2;
catch
    posout.('Hips/Pelvis_AnteriorAngulationsX') = (posout.('Hips_Pelvis_AnteriorAngulationsX')+posout.('Hips_Pelvis_PosteriorAngulationsX'))/2;

end

posout.Head_LateralAngulationsX = (posout.Head_LateralAngulationsX+posout.Head_post_LateralAngulationsX)/2;
%posout.Stance_AnteriorAngulations = (posout.Head_LateralAngulationsX+posout.Head_post_LateralAngulationsX)/2;

% rename everything
% make all xrots the right sign
newposout = table;
newposout.L_knee_xrot = -posout.Knees_post_LateralAngulations; newposout.R_knee_xrot = posout.Knees_LateralAngulations;
try
newposout.L_hip_xrot = -posout.('Hips/Pelvis_post_LateralAngulations'); newposout.R_hip_xrot = posout.('Hips/Pelvis_LateralAngulations');
newposout.Hip_center_yrot = -posout.('Hips/Pelvis_AnteriorAngulationsX');
catch
    newposout.L_hip_xrot = -posout.('Hips_Pelvis_post_LateralAngulations'); newposout.R_hip_xrot = posout.('Hips_Pelvis_LateralAngulations');
newposout.Hip_center_yrot = -posout.('Hips_Pelvis_AnteriorAngulationsX');
end

newposout.Torso_yrot = -posout.Shoulder_AnteriorAngulationsX; newposout.Torso_xrot = posout.Shoulder_LateralAngulations;
newposout.Torso_twist = posout.Shoulder_LateralTwist; newposout.Torso_tilt = posout.Shoulder_AnteriorAngulations-posout.Shoulder_AnteriorAngulationsX;

newposout.Head_yrot = -posout.Head_AnteriorAngulationsX; newposout.Head_xrot = posout.Head_LateralAngulations;
newposout.Head_twist = posout.Head_LateralTwist; newposout.Head_tilt = posout.Head_AnteriorAngulations-posout.Head_AnteriorAngulationsX;
newposout.Head_pitch = posout.Head_LateralAngulationsX+posout.Head_LateralAngulations;

newposout.L_elbow_yrot = -(posout.Elbows_AnteriorAngulations+posout.Elbows_PosteriorAngulations)/2; newposout.R_elbow_yrot = (posout.Elbows_AnteriorAngulations+posout.Elbows_PosteriorAngulations)/2;
newposout.L_elbow_xrot = posout.Elbows_post_LateralAngulations; newposout.R_elbow_xrot = posout.Elbows_LateralAngulations;

oldposout = posout;
posout = newposout;


end


