 % first do the facebook subjects

res = jsonread('facebook_participants.txt');

[subs,fullsubs] = posturestudy_extractdata(res);
ids = getfield_list(subs,'emailid');
rmindx = [find(strcmpi(ids,'lavanya.virmani@mail.mcgill.ca')) ...
    find(strcmpi(ids,'shashank.murugesh@mail.mcgill.ca')) ...
    find(strcmpi(ids,'sorenwt@gmail.com'))];

subs(rmindx) = [];
ids(rmindx) = [];

for i = 1:length(subs)
   subs{i} = posturestudy_preproc(subs{i},subs{1});
end
nsubs = length(subs);

oldsubs = load('~/Desktop/masters/posturestudy/old_QC_analysis/combined/fixtilt/posturestudy_combined_fixtilt_fixmorph.mat','subs');
oldsubs = oldsubs.subs;
oldsubs = oldsubs(end-44:end);

keys = jsonread('jatos_keys_fb.txt'); keys = keys{1};


% get rid of emails and use codes

for i = 1:length(subs)
    subs{i}.id = char(keys.completioncodes{find(strcmpi(keys.ids,subs{i}.emailid),1)});
    subs{i} = rmfield(subs{i},'emailid');
    subs{i}.raw.consform = rmfield(subs{i}.raw.consform,'emailid');
end

clear scales*
clear pmod*
clear keys
clear ids
clear res

pmod1 = readtable('Personality module 1 (Responses).csv');
pmod2 = readtable('Personality module 2 (Responses).csv');

opts = detectImportOptions('Personality module 1 (Responses).csv');
opts = setvartype(opts,pmod1.Properties.VariableNames,'char');
pmod1 = readtable('Personality module 1 (Responses).csv',opts);
pmod2 = readtable('Personality module 2 (Responses).csv',opts);

realnames1 = pmod1.Properties.VariableDescriptions;
realnames1(3:end) = extractBetween(realnames1(3:end),'[',']');
realnames1 = regexprep(realnames1,'\s[a-z]','${upper($0)}');
realnames1 = erase(realnames1,' ');
realnames1 = replace(realnames1,'-','_');
realnames1 = replace(realnames1,',','_');
realnames1 = replace(realnames1,"'",'_');
realnames1 = replace(realnames1,'"','_');
realnames1 = replace(realnames1,'/','_');
realnames1 = replace(realnames1,';','_');
realnames1 = replace(realnames1,'...','x___');
for i = 1:length(realnames1)
    if length(realnames1{i}) > 63
    realnames1{i} = realnames1{i}(1:63);
    end
end
realnames1 = replace(realnames1,'ICanReturnMyAwarenessToMyBodyIfIAmDistracted','ICanReturnAwarenessToMyBodyIfIAmDistracted');
realnames1 = replace(realnames1,'INoticeHowMyBodyChangesWhenIFeelHappy_joyful','INoticeHowMyBodyChangesWhenIFeelHappy_Joyful');


for i = 1:length(realnames1)
   if any(strcmpi(realnames1(1:i-1),realnames1{i}))
      realnames1{i} = [realnames1{i} '2'];
   end
end


realnames2 = pmod2.Properties.VariableDescriptions;
realnames2(3:end) = extractBetween(realnames2(3:end),'[',']');
realnames2 = regexprep(realnames2,'\s[a-z]','${upper($0)}');
realnames2 = erase(realnames2,' ');
realnames2 = replace(realnames2,'-','_');
realnames2 = replace(realnames2,',','_');
realnames2 = replace(realnames2,"'",'_');
realnames2 = replace(realnames2,'"','_');
realnames2 = replace(realnames2,'/','_');
realnames2 = replace(realnames2,';','_');
realnames2 = replace(realnames2,'...','x___');
for i = 1:length(realnames2)
    if length(realnames2{i}) > 63
    realnames2{i} = realnames2{i}(1:63);
    end
end
realnames2 = replace(realnames2,'IFeelWorried','IAmWorried');
realnames2 = replace(realnames2,'IAmPresentlyWorryingOverPossibleMisfortunes','IAmPresentlyWorrying');
realnames2 = replace(realnames2,'IWishICouldBeAsHappyAsOthersSeemToBe','IWishICouldBeAsHappyAsOthersSeem');
realnames2 = replace(realnames2,'IWorryTooMuchOverSomethingThatReallyDoesNotMatter','IWorryTooMuchOverThingsThatDon_tMatter');

for i = 1:length(realnames2)
   if any(strcmpi(realnames2(1:i-1),realnames2{i}))
      realnames2{i} = [realnames2{i} '2'];
   end
end

pmod1.Properties.VariableNames = realnames1;
pmod2.Properties.VariableNames = realnames2;

info1 = load('Scales_module1.mat'); info2 = load('Scales_module2.mat');

for i = 1:length(subs)
    fillflag = false;
    %if isfield(subs{i},'scales')
    %    subs{i} = rmfield(subs{i},'scales');
    %    subs{i}.raw = rmfield(subs{i}.raw,'scales');
    %end
    if ~isfield(subs{i},'scales')
    if any(strcmpi(pmod1{:,2},subs{i}.emailid))
        subs{i} = sub_calc_scales(subs{i},pmod1,info1);
    else
        fillflag = true;
    end
    if any(strcmpi(pmod2{:,2},subs{i}.emailid))
        subs{i} = sub_calc_scales(subs{i},pmod2,info2);
    else
        fillflag = true;
    end
    
    if fillflag
        subs{i} = scales_fill_nan(subs{i},subs{1});
    end
    end
end

ids = getfield_list(subs,'id'); 
oldids = getfield_list(oldsubs,'id');
for i = 1:length(oldids)
    newindx = find(strcmpi(ids,oldids{i}));
    subs{newindx} = oldsubs{i};
end


% 
% cd posturephotos
% 
% posture_save_all_photos(subs);
% 
% for i = 1:length(subs)
%     subs{i}.raw = rmfield(subs{i}.raw,'photos');
% end
% 
% % do posturescreen and fix bad photos before running the next part
% cd ..
% cd 'Posture Assessments'
% 
% files = dir('*.pdf');
% 
% ids = getfield_list(subs,'id');
% 
% for i = 1:length(files)
%    subid = tokenize(files(i).name,'_');
%    subid = subid(3);
%    %subid = lower(subid);
% %    %if strcmpi(name{1},'liu') && strcmpi(name{2},'rachel')
% %        indx = find(strcmpi(ids,'qing82008@gmail.com'));
% %        [posall,posavg] = posturescreen_extractdata(files(i).name);
% %        subs{indx}.posture.all = posall;
% %        subs{indx}.posture.avg = posavg;
%    %else
%        %indx = intersect(find(contains(ids,subid{1})),find(contains(ids,subid{2})));
%        indx = find(strcmpi(subid,ids));
%        [posall,posavg] = posturescreen_extractdata(files(i).name);
%        subs{indx}.posture.all = posall;
%        subs{indx}.posture.avg = posavg;
%    %end
% end
% 
% for i = 1:length(subs)
%     if ~isfield(subs{i},'posture')
%        subs{i}.posture.all = subs{indx}.posture.all; 
%        subs{i}.posture.all{:,:} = NaN(size(subs{i}.posture.all));
%        subs{i}.posture.avg = subs{indx}.posture.avg; 
%        subs{i}.posture.avg{:,:} = NaN(size(subs{i}.posture.avg));
%     end
% end

% get OpenPose info 

cd openpose_output_json

files = dir('*.json');
fnames = extractfield(files,'name');
%filesubids = extractBefore(fnames,'_photo');

for i = 1:length(subs)
    subfiles = files(contains(fnames,ids{i}));
    clear pose subpnts whichview
    for q = 1:length(subfiles)
       [pose{q},subpnts{q},whichview{q}] = openpose_readposture_stand(fullfile(subfiles(q).folder,subfiles(q).name),1,0); 
    end
    
    if ~(exist('whichview','var') && any(strcmpi(whichview,'anterior')) && any(strcmpi(whichview,'posterior')) && any(strcmpi(whichview,'left')) && any(strcmpi(whichview,'right')))
        % redo with manual check if any views are missing
        for q = 1:length(subfiles)
            [pose{q},subpnts{q},whichview{q}] = openpose_readposture(fullfile(subfiles(q).folder,subfiles(q).name),1,1);
        end
        
    end
%     if exist('whichview','var')
%         nviews(i,1) = sum(strcmpi(whichview,'anterior'));
%         nviews(i,2) = sum(strcmpi(whichview,'posterior'));
%         nviews(i,3) = sum(strcmpi(whichview,'left'));
%         nviews(i,4) = sum(strcmpi(whichview,'right'));
%     end
        
    if exist('whichview','var') && any(strcmpi(whichview,'anterior')) && any(strcmpi(whichview,'posterior')) && any(strcmpi(whichview,'left')) && any(strcmpi(whichview,'right'))
        ant = pose{find(strcmpi(whichview,'anterior'),1)};
        post = pose{find(strcmpi(whichview,'posterior'),1)};
        left = pose{find(strcmpi(whichview,'left'),1)};
        right = pose{find(strcmpi(whichview,'right'),1)};
        
        subs{i}.posture.raw.oposeall = [ant post left right];
    elseif ~isfield(subs{i},'posture')
        subs{i}.posture.raw.oposeall = subs{1}.posture.oposeall;
        subs{i}.posture.raw.oposeall{:,:} = NaN(size(subs{i}.posture.oposeall{:,:}));
    end
end

% remember to redo 17ew26fled and 8szukbp84f manually

% get tilt info

cd ../openpose_outputs_img

files = dir('*.png');
fnames = extractfield(files,'name');

for i = 1:length(subs)
    subfiles = files(contains(fnames,ids{i}));
    if length(subfiles) > 0
    subs{i}.posture.tilt = get_photo_tilt(subfiles(1).name); % assume tilt is the same across different photos
    else
        subs{i}.posture.tilt = NaN;
    end
end

for i = 1:length(subs)
   %subs{i}.posture.raw.oposeall = subs{i}.posture.oposeall;
   subs{i}.posture.oposeall{:,:} = subs{i}.posture.raw.oposeall{:,:} - tiltfilter*subs{i}.posture.tilt;
end

% create parcellated bodily maps

load('embody_selatlas.mat'); load('embody_postatlas.mat'); load('embody_postatlas2.mat');

for i = 1:length(subs)
    for q = 1:length(subs{i}.embody.bodymap)
       %[subs{i}.embody.parc.sel.vect,subs{i}.embody.parc.sel.map] = parcellate(subs{i}.embody.bodymap,selatlas);
        %[subs{i}.embody.parc.post.vect(:,q),subs{i}.embody.parc.post.map{q}] = parcellate(subs{i}.embody.bodymap{q},postatlas.atlas);
        %subs{i}.embody.parc.post.names = postatlas.names;
        [subs{i}.embody.parc.post2.vect(:,q),subs{i}.embody.parc.post2.map{q}] = parcellate(subs{i}.embody.bodymap{q},postatlas2.atlas);
         subs{i}.embody.parc.post2.names = postatlas2.names;
    end
end

%% Below: version for the SONA participants

res = jsonread('sona_participants.txt');

[subs,fullsubs] = posturestudy_extractdata(res);
ids = getfield_list(subs,'emailid');
rmindx = [];

subs(rmindx) = [];
ids(rmindx) = [];

pmod1 = readtable('Personality module 1 (SONA) v2 (Responses).csv');
pmod2 = readtable('Personality module 2 (SONA) v2 (Responses).csv');

opts = detectImportOptions('Personality module 1 (SONA) v2 (Responses).csv');
opts = setvartype(opts,pmod1.Properties.VariableNames,'char');
pmod1 = readtable('Personality module 1 (SONA) v2 (Responses).csv',opts);
pmod2 = readtable('Personality module 2 (SONA) v2 (Responses).csv',opts);

realnames1 = pmod1.Properties.VariableDescriptions;
realnames1(3:end) = extractBetween(realnames1(3:end),'[',']');
realnames1 = regexprep(realnames1,'\s[a-z]','${upper($0)}');
realnames1 = erase(realnames1,' ');
realnames1 = replace(realnames1,'-','_');
realnames1 = replace(realnames1,',','_');
realnames1 = replace(realnames1,"'",'_');
realnames1 = replace(realnames1,'"','_');
realnames1 = replace(realnames1,'/','_');
realnames1 = replace(realnames1,';','_');
realnames1 = replace(realnames1,'...','x___');
for i = 1:length(realnames1)
    if length(realnames1{i}) > 63
    realnames1{i} = realnames1{i}(1:63);
    end
end
realnames1 = replace(realnames1,'ICanReturnMyAwarenessToMyBodyIfIAmDistracted','ICanReturnAwarenessToMyBodyIfIAmDistracted');
realnames1 = replace(realnames1,'INoticeHowMyBodyChangesWhenIFeelHappy_joyful','INoticeHowMyBodyChangesWhenIFeelHappy_Joyful');


for i = 1:length(realnames1)
   if any(strcmpi(realnames1(1:i-1),realnames1{i}))
      realnames1{i} = [realnames1{i} '2'];
   end
end


realnames2 = pmod2.Properties.VariableDescriptions;
realnames2(3:end) = extractBetween(realnames2(3:end),'[',']');
realnames2 = regexprep(realnames2,'\s[a-z]','${upper($0)}');
realnames2 = erase(realnames2,' ');
realnames2 = replace(realnames2,'-','_');
realnames2 = replace(realnames2,',','_');
realnames2 = replace(realnames2,"'",'_');
realnames2 = replace(realnames2,'"','_');
realnames2 = replace(realnames2,'/','_');
realnames2 = replace(realnames2,';','_');
realnames2 = replace(realnames2,'...','x___');
for i = 1:length(realnames2)
    if length(realnames2{i}) > 63
    realnames2{i} = realnames2{i}(1:63);
    end
end
realnames2 = replace(realnames2,'IFeelWorried','IAmWorried');
realnames2 = replace(realnames2,'IAmPresentlyWorryingOverPossibleMisfortunes','IAmPresentlyWorrying');
realnames2 = replace(realnames2,'IWishICouldBeAsHappyAsOthersSeemToBe','IWishICouldBeAsHappyAsOthersSeem');
realnames2 = replace(realnames2,'IWorryTooMuchOverSomethingThatReallyDoesNotMatter','IWorryTooMuchOverThingsThatDon_tMatter');

for i = 1:length(realnames2)
   if any(strcmpi(realnames2(1:i-1),realnames2{i}))
      realnames2{i} = [realnames2{i} '2'];
   end
end

pmod1.Properties.VariableNames = realnames1;
pmod2.Properties.VariableNames = realnames2;

info1 = load('Scales_module1.mat'); info2 = load('Scales_module2.mat');

for i = 1:length(subs)
    fillflag = false;
    if isfield(subs{i},'scales')
        subs{i} = rmfield(subs{i},'scales');
        subs{i}.raw = rmfield(subs{i}.raw,'scales');
    end
    
    if any(strcmpi(pmod1{:,2},subs{i}.emailid))
        subs{i} = sub_calc_scales(subs{i},pmod1,info1);
    else
        fillflag = true;
    end
    if any(strcmpi(pmod2{:,2},subs{i}.emailid))
        subs{i} = sub_calc_scales(subs{i},pmod2,info2);
    else
        fillflag = true;
    end
    
    if fillflag
        subs{i} = scales_fill_nan(subs{i},subs{1});
    end
end

for i = 1:length(subs)
   fields = fieldnames(subs{i}.scales.raw);
   fields(contains(fields,'all')) = [];
   %tmp = table;
   tmp = [];
   for q = 1:length(fields)
       tmp = [tmp subs{i}.scales.raw.(fields{q}){:,:}];
   end
   subs{i}.scales.raw.allvect = tmp;
end

for i = 1:length(subs)
   subs{i} = posturestudy_preproc(subs{i},subs{1}); % this assumes subject 1 has complete data - if not, change it
end
nsubs = length(subs);

badmaps = [10 21 26 53]; % populate this manually from looking at the plots

badmapids = ids(badmaps);

oldbads = readtable('~/Desktop/masters/posturestudy/old_QC_analysis/bads.csv');

bads = table;
bads.id = {}; bads.tilt = zeros(0); bads.photos = zeros(0); bads.embody = zeros(0);

for i = 1:length(ids)
    if any(strcmpi(ids{i},oldbads.id))
        indx = find(strcmpi(ids{i},oldbads.id));
       bads.id{i} = ids{i}; bads.tilt(i) = oldbads.tilt(indx); 
       bads.photos(i) = oldbads.photos(indx); bads.embody(i) = oldbads.embody(indx); bads.manualposture(i) = oldbads.manualposture(indx);
    else
        bads.id{i} = ids{i}; bads.tilt(i) = NaN;
        bads.photos(i) = 0; bads.embody(i) = 0; bads.manualposture(i) = 0;
    end
end

bads.embody(badmaps) = 1;

%allbadmaps = find(bads.embody);

% check bodymaps for weird stuff

mask = imread('~/Desktop/masters/embody-test/embody/matlab/mask.png');
mask = [zeros(522,2) mask zeros(522,2)];
mask = [zeros(1,175); mask; zeros(1,175)];
inmask = find(mask > 128);

allbadmaps = zeros(1,length(subs));

f = figure;
for i = 1:length(subs)
    figure(f)
    set(gcf,'units','normalized','position',[0 0.2 0.8 0.8])

    %tmp = randi(10);
    for q = 1:10
        if ~any(any(isnan(subs{i}.embody.bodymap{q}))) && ~(all(all(subs{i}.embody.bodymap{q}==0)))
            subplot(2,5,q)
            embody_plotmap(subs{i}.embody.bodymap{q},mask);
            title(subs{i}.embody.emotion{q})
        elseif all(all(subs{i}.embody.bodymap{q}==0))
            subplot(2,5,q)
            cla
            title([subs{i}.embody.emotion{q} ' (empty)'])
        end
        %title(['Subject ' num2str(i)])
    end
    doexclude = input(['Subject ' subs{i}.emailid ', index ' num2str(i) ': input n to exclude, otherwise enter nothing to keep. '],'s');
    if ~isempty(doexclude) && strcmpi(doexclude,'n')
      allbadmaps(i) = 1;
    end
end

badmapindx = find(allbadmaps);

for q = 1:length(badmapindx)
    subs{badmapindx(q)}.excluded.embody = subs{badmapindx(q)}.embody;
    for i = 1:10
        subs{badmapindx(q)}.embody.bodymap{i} = NaN(524,175);
    end
end



keys = jsonread('jatos_keys_sona.txt'); keys = keys{1};

for i = 1:length(keys.completioncodes)
    keys.completioncodes{i} = char(keys.completioncodes{i});
end

% rename OpenPOSE images before you get rid of SONA IDs

cd ~/Desktop/masters/sona_participants/openpose_output_img

files = dir('*.png');
fnames = extractfield(files,'name');

for i = 1:length(subs)
    thesefiles = fnames(contains(fnames,subs{i}.emailid));
    if length(thesefiles) > 0
       for ii = 1:length(thesefiles)
            system(['mv "' thesefiles{ii} '" "' replace(thesefiles{ii},subs{i}.emailid,...
                char(keys.completioncodes{find(strcmpi(keys.ids,subs{i}.emailid),1)})) '"']);
       end 
    end
end

cd ../openpose_output_json

files = dir('*.json');
fnames = extractfield(files,'name');

for i = 1:length(subs)
    thesefiles = fnames(contains(fnames,subs{i}.emailid));
    if length(thesefiles) > 0
       for ii = 1:length(thesefiles)
            system(['mv "' thesefiles{ii} '" "' replace(thesefiles{ii},subs{i}.emailid,...
                char(keys.completioncodes{find(strcmpi(keys.ids,subs{i}.emailid),1)})) '"']);
       end 
    end
end

% get rid of emails and use codes

for i = 1:length(subs)
    subs{i}.id = char(keys.completioncodes{find(strcmpi(keys.ids,subs{i}.emailid),1)});
    %subs{i} = rmfield(subs{i},'emailid');
    %subs{i}.raw.consform = rmfield(subs{i}.raw.consform,'emailid');
end

ids = getfield_list(subs,'id');


clear scales*
clear pmod*
clear keys
clear res

% cd posturephotos
% 
% posture_save_all_photos(subs);
% 
% for i = 1:length(subs)
%     subs{i}.raw = rmfield(subs{i}.raw,'photos');
% end

% do posturescreen and fix bad photos before running the next part
cd /Users/Soren/Desktop/masters/sona_participants/posturescreen_sona_participants

files = dir('*.pdf');
fnames = extractfield(files,'name');


for i = 1:length(subs)
   %subid = tokenize(files(i).name,'_');
   %subid = subid(3);
   %subid = lower(subid);
%    %if strcmpi(name{1},'liu') && strcmpi(name{2},'rachel')
%        indx = find(strcmpi(ids,'qing82008@gmail.com'));
%        [posall,posavg] = posturescreen_extractdata(files(i).name);
%        subs{indx}.posture.all = posall;
%        subs{indx}.posture.avg = posavg;
   %else
       %indx = intersect(find(contains(ids,subid{1})),find(contains(ids,subid{2})));
       %indx = find(strcmpi(subid,ids));
       subfile = files(contains(fnames,subs{i}.id));
       if ~isempty(subfile)
       [posall,posavg] = posturescreen_extractdata(subfile.name);
       subs{i}.posture.raw.all = posall;
       subs{i}.posture.raw.avg = posavg;
       else
           subs{i}.posture.raw.all = subs{3}.posture.raw.all;
           subs{i}.posture.raw.all{:,:} = NaN(size(subs{i}.posture.raw.all));
           subs{i}.posture.raw.avg = subs{3}.posture.raw.avg;
           subs{i}.posture.raw.avg{:,:} = NaN(size(subs{i}.posture.raw.avg));
       end
   %end
end

% for i = 1:length(subs)
%     if ~isfield(subs{i},'posture')
%        subs{i}.posture.all = subs{indx}.posture.all; 
%        subs{i}.posture.all{:,:} = NaN(size(subs{i}.posture.all));
%        subs{i}.posture.avg = subs{indx}.posture.avg; 
%        subs{i}.posture.avg{:,:} = NaN(size(subs{i}.posture.avg));
%     end
% end

% get OpenPose info 

cd ~/Desktop/masters/posturestudy/sona_participants/openpose_output_json

files = dir('*.json');
fnames = extractfield(files,'name');
%filesubids = extractBefore(fnames,'_photo');

%ids = getfield_list(subs,'id');

for i = 1:length(subs)
    subfiles = files(contains(fnames,ids{i}));
    clear pose subpnts whichview
    for q = 1:length(subfiles)
       [pose{q},subpnts{q},whichview{q}] = openpose_readposture(fullfile(subfiles(q).folder,subfiles(q).name)); 
    end
    if exist('whichview','var')
        nviews(i,1) = sum(strcmpi(whichview,'anterior'));
        nviews(i,2) = sum(strcmpi(whichview,'posterior'));
        nviews(i,3) = sum(strcmpi(whichview,'left'));
        nviews(i,4) = sum(strcmpi(whichview,'right'));
    end
        
    if exist('whichview','var') && any(strcmpi(whichview,'anterior')) && any(strcmpi(whichview,'posterior')) && any(strcmpi(whichview,'left')) && any(strcmpi(whichview,'right'))
        ant = pose{find(strcmpi(whichview,'anterior'),1)};
        post = pose{find(strcmpi(whichview,'posterior'),1)};
        left = pose{find(strcmpi(whichview,'left'),1)};
        right = pose{find(strcmpi(whichview,'right'),1)};
        
        subs{i}.posture.raw.oposeall = [ant post left right];
    else
        subs{i}.posture.raw.oposeall = subs{1}.posture.raw.oposeall;
        subs{i}.posture.raw.oposeall{:,:} = NaN(size(subs{i}.posture.raw.oposeall{:,:}));
    end
end

failids = ids(find(any(diff(nviews,[],2)~=0,2)));
% add manually the ones where multiple people were found
[~,failindx] = match_str(failids,ids);

% set at this point the participants who need manual fixes to openpose

bads.manualposture(24) = 1;


% get tilt correction for photos

cd ~/Desktop/masters/sona_participants/openpose_output_img

files = dir('*.png');
fnames = extractfield(files,'name');

%tiltfilter_opose = [1     1     1    -1    -1    -1     -1    -1    -1    -1     1     1    1     1     1     1     1     1     1     1     1     1];
%tiltfilter_opose = [-1 -1 -1 -1 -1 -1 -1 1 1 1 1 1 1 1 -1 -1 -1 -1 -1 -1 -1 -1];
tiltfilter_opose = -ones(1,22);
tiltfilter_opose(contains(subs{1}.posture.raw.oposeall.Properties.VariableNames,'Posterior')) = 1;
% expresses how the tilt affects each variable

% remember to select the leftmost point first so that the sign of the angle is correct
for i = 1:length(subs)
    subfiles = files(contains(fnames,ids{i}));
    oldindx = find(strcmpi(bads.id,ids{i}));
    % only redo tilt correction if the participant is new or was excluded before for not having other data
    if length(subfiles) > 0 && (isempty(oldindx) || isnan(bads.tilt(oldindx))) 
        subs{i}.posture.tilt = get_photo_tilt(subfiles(1).name); % assume tilt is the same across different photos
    else
        if length(subfiles) == 0
        subs{i}.posture.tilt = NaN;
        else
           subs{i}.posture.tilt = bads.tilt(oldindx); 
        end
    end
end

tilts = getfield_list(subs,'posture.tilt');
bads.tilt = tilts';

for i = 1:length(subs)
   %subs{i}.posture.raw.oposeall = subs{i}.posture.oposeall;
   subs{i}.posture.oposeall = subs{i}.posture.raw.oposeall;
   subs{i}.posture.oposeall{:,:} = subs{i}.posture.raw.oposeall{:,:} + tiltfilter_opose*subs{i}.posture.tilt;
    subs{i}.posture.projtilt.opose = subs{i}.posture.raw.oposeall;
    subs{i}.posture.projtilt.opose{:,:} = projout(subs{i}.posture.raw.oposeall{:,:},tiltfilter_opose)';
end

% applies to 27-element angle version
%tiltfilter_pscreen = [1 1 1 1 1 1 1 -1 -1 -1 1 1 1 1 1 1 1 1 1 -1 -1 -1 -1 1 1 1 1]; 
%tiltfilter_pscreen = [-1 -1 -1 -1 -1 -1 -1 1 1 1 1 1 1 1 1 1 1 1 1 -1 -1 -1 -1 1 1 1 1]; 
tiltfilter_pscreen = -ones(1,27); 
tiltfilter_pscreen(contains(subs{1}.posture.raw.ang.Properties.VariableNames,'Posterior')) = 1;

for i = 1:length(subs)
   %subs{i}.posture.raw.ang = posturescreen_convert_angle(subs{i}.posture.raw.all);
   %subs{i}.posture.screen = subs{i}.posture.raw.ang;
   subs{i}.posture.screen{:,:} = subs{i}.posture.raw.ang{:,:}+tiltfilter_pscreen*subs{i}.posture.tilt;
   subs{i}.posture.projtilt.screen = subs{i}.posture.raw.ang;
   subs{i}.posture.projtilt.screen{:,:} = projout(subs{i}.posture.raw.ang{:,:},tiltfilter_pscreen)';
end

% finally, exclude participants with bad photos for one reason or another

badpostureids = {'k6k3bjk16m','2r69k1n3ke','9261xcgk3n','fhkwfg3p66','ftkuf751ep',...
    'qypz1x4z7v','7gha0vg585','yumb03wlb6','fxzhbgq7g7','vtchdk9s6y','8r1qrjw5e0','h7az8n01ga'};

[~,badposture] = match_str(ids,badpostureids);

%bads.photos(badposture) = 1;

for i = badposture'
   subs{i}.posture.excluded = subs{i}.posture;
   %subs{i}.posture.raw.all{:,:} = NaN*subs{i}.posture.raw.all{:,:};
   %subs{i}.posture.raw.ang{:,:} = NaN*subs{i}.posture.raw.ang{:,:};
   subs{i}.posture.raw.oposeall{:,:} = NaN*subs{i}.posture.raw.oposeall{:,:};
   %subs{i}.posture.screen{:,:} = NaN*subs{i}.posture.screen{:,:};
   %subs{i}.posture.oposeall{:,:} = NaN*subs{i}.posture.oposeall{:,:};
end


% create parcellated bodily maps

load('embody_selatlas.mat'); load('embody_postatlas.mat'); load('embody_postatlas2.mat');

for i = 1:length(subs)
    for q = 1:length(subs{i}.embody.bodymap)
       %[subs{i}.embody.parc.sel.vect,subs{i}.embody.parc.sel.map] = parcellate(subs{i}.embody.bodymap,selatlas);
        [subs{i}.embody.parc.post.vect(:,q),subs{i}.embody.parc.post.map{q}] = parcellate(subs{i}.embody.bodymap{q},postatlas.atlas);
        subs{i}.embody.parc.post.names = postatlas.names;
        [subs{i}.embody.parc.post2.vect(:,q),subs{i}.embody.parc.post2.map{q}] = parcellate(subs{i}.embody.bodymap{q},postatlas2.atlas);
         subs{i}.embody.parc.post2.names = postatlas2.names;
    end
end


% finally, write the bads file

writetable(bads,'bads.csv')