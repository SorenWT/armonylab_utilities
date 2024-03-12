function posnorm = posturedata_convert_twist(posall,pts)
% converts a set of postural angles with duplicate measurements in the
% lateral views into a set with a mean and a twist parameter
% uses the subject anatomy in pts - if not input, a template is used


posnorm = posall;

% confirm that head/shoulder/ribcage/hips translations in the posterior view
% are measured relative to each other rather than to the spine points

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


% convert the anterior and posterior view translations into angulations
% based on the model above

% posnorm.('T1-T4_PosteriorAngulationsX') = asin(posnorm.('T1-T4_PosteriorTranslations')./(pts.shoulders{2}(3)-pts.t4{1}(3)));
% posnorm.('T4-T8_PosteriorAngulations') = asin(posnorm.('T4-T8_PosteriorTranslations')./(pts.t4{1}(3)-pts.t8{2}(3)));
% posnorm.('T8-T12_PosteriorTranslations') = asin(posnorm.('T8-T12_PosteriorTranslations')./(pts.t8{1}(3)-pts.t12{1}(3)));
% posnorm.('T12-L3_PosteriorTranslations') = asin(posnorm.('T12-L3_PosteriorTranslations')./(pts.t12{1}(3)-pts.l3{1}(3)));
% posnorm.('L3-MidPSIS_PosteriorTranslations') = asin(posnorm.('L3-MidPSIS_PosteriorTranslations')./(pts.l3{1}(3)-pts.hips{2}(3)));

% convert the two lateral angulation variables to a variable reflecting the
% average and a variable reflecting the twist

l1 = pts.knees{2}(3)-pts.ankles{2}(3); l2 = pts.knees{3}(1)-pts.knees{1}(1);
% double negative is because of the mislabeled signs in posterior view
posnorm.Knees_LateralTwist = rad2deg(atan((l1.*sin(deg2rad(posnorm.Knees_LateralAngulations))-l1.*sin(-deg2rad(posnorm.Knees_post_LateralAngulations)))./l2));
posnorm.Knees_LateralAngulations = (posnorm.Knees_LateralAngulations-posnorm.Knees_post_LateralAngulations)./2;

l1 = pts.hips{2}(3)-pts.knees{2}(3); l2 = pts.hips{3}(1)-pts.hips{1}(1);
try
posnorm.('Hips/Pelvis_LateralTwist') = rad2deg(atan((l1*sin(deg2rad(posnorm.('Hips/Pelvis_LateralAngulations')))-l1*sin(-deg2rad(posnorm.('Hips/Pelvis_post_LateralAngulations'))))./l2));
posnorm.('Hips/Pelvis_LateralAngulations') = (posnorm.('Hips/Pelvis_LateralAngulations')-posnorm.('Hips/Pelvis_post_LateralAngulations'))./2;
catch
posnorm.('Hips/Pelvis_LateralTwist') = rad2deg(atan((l1*sin(deg2rad(posnorm.('Hips_Pelvis_LateralAngulations')))-l1*sin(-deg2rad(posnorm.('Hips_Pelvis_post_LateralAngulations'))))./l2));
posnorm.('Hips/Pelvis_LateralAngulations') = (posnorm.('Hips_Pelvis_LateralAngulations')-posnorm.('Hips_Pelvis_post_LateralAngulations'))./2;
end

l1 = pts.shoulders{2}(3)-pts.hips{2}(3); l2 = pts.shoulders{3}(1)-pts.shoulders{1}(1);
posnorm.('Shoulder_LateralTwist') = rad2deg(atan((l1*sin(deg2rad(posnorm.('Shoulder_LateralAngulations')))-l1*sin(-deg2rad(posnorm.('Shoulder_post_LateralAngulations'))))./l2));
posnorm.('Shoulder_LateralAngulations') = (posnorm.('Shoulder_LateralAngulations')-posnorm.('Shoulder_post_LateralAngulations'))./2;

l1 = pts.head{2}(3)-pts.shoulders{2}(3); l2 = pts.head{3}(1)-pts.head{1}(1);
posnorm.('Head_LateralTwist') = rad2deg(atan((l1*sin(deg2rad(posnorm.('Head_LateralAngulations')))-l1*sin(-deg2rad(posnorm.('Head_post_LateralAngulations'))))./l2));
posnorm.('Head_LateralAngulations') = (posnorm.('Head_LateralAngulations')-posnorm.('Head_post_LateralAngulations'))./2;

transvars = contains(posnorm.Properties.VariableNames,'Translations');

posnorm(:,transvars) = [];

postvars = contains(posnorm.Properties.VariableNames,'_post_') & ~contains(posnorm.Properties.VariableNames,'LateralAngulationsX') & ~contains(posnorm.Properties.VariableNames,'Elbow');
posnorm(:,postvars) = [];
