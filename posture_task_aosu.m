% script to extract videos, concatenate, and make blank annot files


basedir = '/Volumes/ARMONYLAB/posturestudy_behav/natural_posture_vids';

cd(basedir);

cameras = {'hallway','window'};

setenv('PATH','/Users/Soren/opt/anaconda3/bin:/Users/Soren/opt/anaconda3/condabin:/usr/local/fsl/bin:/Library/Frameworks/Python.framework/Versions/3.6/bin:/Library/Frameworks/Python.framework/Versions/3.5/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/Library/Apple/usr/bin:/Users/Soren/Library/Python/2.7/bin:/Users/Soren/abin:/Applications/workbench/bin_macosx64:/Users/Soren/.local/bin')

for i = 1:length(cameras)
    cd(fullfile(basedir,cameras{i}))
    dates = dir('*/*'); dates(~[dates(:).isdir]) = []; dates(contains({dates(:).name},'.')) = [];
    for ii = 20:length(dates)
        cd(fullfile(dates(ii).folder,dates(ii).name))
        instances = dir('*'); instances(~[instances(:).isdir]) = []; instances(contains({instances(:).name},'.')) = [];
        for iii = 1:length(instances)
            cd(fullfile(instances(iii).folder,instances(iii).name))
            if ~exist([dates(ii).folder(end-1:end) '_' dates(ii).name '_instance' num2str(iii) '.mp4'],'file')
                
                % convert all media files to mp4
                system('for i in *.media; do ffmpeg -i "$i" "${i%.*}.mp4"; done');
                
                % confirm that they all converted successfully
                tmp = dir('*.media'); tmp2 = dir('*.mp4');
                
                if length(tmp) ~= length(tmp2)
                    % do something with the ones that failed to convert
                    warning('One or more files failed to convert!')
                    badnames = setdiff(extractBefore({tmp(:).name},'.media'),extractBefore({tmp2(:).name},'.mp4'));
                    badnames = cellcat(newline,badnames,'',1);
                    badnames = cat(2,badnames{:});
                    writetxt('badfiles.txt',badnames)
                end
                
                % concatenate the mp4 files
                if length(tmp2)>0
                    namesout = strcat({tmp2(:).name},char(39));
                    namesout = cellcat(['file ' char(39)],namesout,'',0);
                    namesout = cellcat(newline,namesout,'',1);
                    namesout = cat(2,namesout{:});
                    writetxt('concatlist.txt',namesout);
                    
                    system(['ffmpeg -f concat -safe 0 -i concatlist.txt -c copy ' dates(ii).folder(end-1:end) '_' dates(ii).name '_instance' num2str(iii) '.mp4'])
                end
            end
        end
    end
end