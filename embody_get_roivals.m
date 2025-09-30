function [subs] = embody_get_roivals(subs,parc)

mask = imread('~/Desktop/armonylab/embody-test/embody/matlab/mask.png');
mask = [zeros(522,2) mask zeros(522,2)];
mask = [zeros(1,175); mask; zeros(1,175)];

mask = imresize(mask,0.25);
inmask = find(mask>128);

act_vectmaps = getfield_list(subs,'embody.act_vectmaps'); 
act_vectmaps = cat(3,act_vectmaps{:});

for i = 1:size(act_vectmaps,2)
    for ii = 1:size(act_vectmaps,1)
        [~,pdata(ii,i),~,tmp] = ttest(squeeze(act_vectmaps(ii,i,:)),squeeze(nanmean(act_vectmaps(:,i,:),1)),'tail','right');
        tdata(ii,i) = tmp.tstat;
    end
end

% set manually to get something that looks right
%tcrit = [NaN(1,10) 10 10 8 8];
%tcrit

%vectmaps = act_vectmaps+deact_vectmaps;

%tmpvectmaps = reshape(act_vectmaps,size(act_vectmaps,1),[]);
%means = nanmean(tmpvectmaps,2);
%act_vectmaps = act_vectmaps-repmat(means,1,size(act_vectmaps,2),size(act_vectmaps,3));

for i = 1:length(subs)
    subs{i}.embody.roivals.head = squeeze(mean(act_vectmaps(:,1:10,i).*(bonf_holm(pdata(:,11))<0.05),1))';
    subs{i}.embody.roivals.heart = squeeze(mean(act_vectmaps(:,1:10,i).*(bonf_holm(pdata(:,13))<0.05),1))';
    subs{i}.embody.roivals.stomach = squeeze(mean(act_vectmaps(:,1:10,i).*(bonf_holm(pdata(:,12))<0.05),1))';
    subs{i}.embody.roivals.chest = squeeze(mean(act_vectmaps(:,1:10,i).*(bonf_holm(pdata(:,14))<0.05),1))';
    subs{i}.embody.roivals.all = squeeze(mean(act_vectmaps(:,1:10,i),1))';
    
    subs{i}.embody.roivals.phys.head = squeeze(mean(act_vectmaps(:,11:14,i).*(bonf_holm(pdata(:,11))<0.05),1))';
    subs{i}.embody.roivals.phys.heart = squeeze(mean(act_vectmaps(:,11:14,i).*(bonf_holm(pdata(:,13))<0.05),1))';
    subs{i}.embody.roivals.phys.stomach = squeeze(mean(act_vectmaps(:,11:14,i).*(bonf_holm(pdata(:,12))<0.05),1))';
    subs{i}.embody.roivals.phys.chest = squeeze(mean(act_vectmaps(:,11:14,i).*(bonf_holm(pdata(:,14))<0.05),1))';
    subs{i}.embody.roivals.phys.all = squeeze(mean(act_vectmaps(:,11:14,i),1))';


    subs{i}.embody.roivals.meantbl = array2table([mean(subs{i}.embody.roivals.head) mean(subs{i}.embody.roivals.heart) mean(subs{i}.embody.roivals.stomach) mean(subs{i}.embody.roivals.chest) mean(subs{i}.embody.roivals.all) ...
        mean(subs{i}.embody.roivals.phys.head) mean(subs{i}.embody.roivals.phys.heart) mean(subs{i}.embody.roivals.phys.stomach) mean(subs{i}.embody.roivals.phys.chest) mean(subs{i}.embody.roivals.phys.all)],...
        'VariableNames',{'head','heart','stomach','chest','all','phys_head','phys_heart','phys_stomach','phys_chest','phys_all'});
end

clear act_vectmaps deact_vectmaps
