function badfolders = run_openpose(fldrlist,fldrout)

if isstruct(fldrlist)
    fldrnames = extractfield(fldrlist,'name');
    fldrfldrs = extractfield(fldrlist,'folder');
    fldrlist = fullfile(fldrfldrs,fldrnames);
end

for i = 1:length(fldrlist)
    if strcmpi(fldrlist{i}(end),'/')
        fldrlist{i}(end) = [];
    end
end

if nargin < 2
    fldrout = fldrlist;
elseif ischar(fldrout)
    fldrout = repmat({fldrout},length(fldrlist),1);
end

% script to fix the openpose issues

oposecall = @(fldrin,fldrout) system(['sh ~/Desktop/armonylab/openpose_wrapper.sh ' fldrin ' ' fldrout]);

badfolders = [];

setenv('PATH','/Users/Soren/opt/anaconda3/bin:/Users/Soren/opt/anaconda3/condabin:/usr/local/fsl/bin:/Library/Frameworks/Python.framework/Versions/3.6/bin:/Library/Frameworks/Python.framework/Versions/3.5/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/Library/Apple/usr/bin:/Users/Soren/Library/Python/2.7/bin:/Users/Soren/abin:/Applications/workbench/bin_macosx64:/Users/Soren/.local/bin')

for i = 1:length(fldrlist)
    [~,output] = oposecall(fldrlist{i},fldrout{i});
    
    %[~,output] = system(['sh ~/Desktop/masters/openpose_wrapper.sh ' fld ' ' fldrout]);
    if contains(output,'Segmentation fault: 11')
        thesefiles = dir([fldrlist{i} '/*']);
        tmp = extractfield(thesefiles,'isdir');
        tmp = [tmp{:}];
        thesefiles(tmp) = [];
        thesefilenames = extractfield(thesefiles,'name');
        mkdir([fldrlist{i} '/1'])
        mkdir([fldrlist{i} '/2'])
        if length(thesefilenames) > 1
            files1 = thesefilenames(1:floor(length(thesefilenames)/2));
            files2 = thesefilenames((floor(length(thesefilenames)/2)+1):end);
        else
            warning(['Errors persist in folder ' fldrlist{i} ' - check this out manually'])
            badfolders = [badfolders fldrlist{i}];
        end
        
        for q = 1:length(files1)
            files1{q} = ['"' files1{q} '"'];
        end
        
        for q = 1:length(files2)
            files2{q} = ['"' files2{q} '"'];
        end
        
        system(['cp ' fldrlist{i} '/{' strjoin(files1,',') '} ' fldrlist{i} '/1'])
        system(['cp ' fldrlist{i} '/{' strjoin(files2,',') '} ' fldrlist{i} '/2'])
        
        % recursively split files into new folders until it stops segfaulting
        newfldrlist = {[fldrlist{i} '/1'],[fldrlist{i} '/2']};
        tmpbads = run_openpose(newfldrlist,fldrout{i});
        badfolders = [badfolders tmpbads];
    end
    
    system(['mogrify -resize 50% -format jpg ' fullfile(fldrout{i},'openpose_output_img','*.png') ])
    system(['rm ' fullfile(fldrout{i},'openpose_output_img','*.png')])
    
end

end