% creating templates for hunched/submissive postures


hunch = array2table(zeros(1,size(posall,2)),'VariableNames',posall.Properties.VariableNames);

%antvars = contains(hunch.Properties.VariableNames,'Anterior') | contains(hunch.Properties.VariableNames,'Posterior');
 
%hunch{:,antvars} = zeros(1,sum(antvars));

hunch.Head_LateralTranslations = 5;
hunch.Head_post_LateralTranslations = 5;
hunch.Shoulder_LateralTranslations = -4;
hunch.Shoulder_post_LateralTranslations = 4;
hunch.('Hips/Pelvis_LateralTranslations') = 2;
hunch.('Hips/Pelvis_post_LateralTranslations') = -2;
hunch.('Knees_LateralTranslations') = 2;
hunch.('Knees_post_LateralTranslations') = -2;

posturescreen_plot(hunch);
