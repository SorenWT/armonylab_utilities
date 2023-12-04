function sub = posturestudy_preproc(sub,template)

% first get some useful stuff from the facemorph

if isfield(sub.raw,'facemorph')
    
    boundary = [0];
    for ii = 1:length(sub.raw.facemorph)
        if isfield(sub.raw.facemorph{ii},'test_part')% && strcmpi(sub.raw.facemorph{ii}.test_part,'midblock_rest') %&& strcmpi(sub.raw.facemorph{ii}.test_part,'midsesh_updatevars')
            %boundary = [boundary ii];
            %testparts{ii} = sub.raw.facemorph{ii}.test_part;
        end
    end
    
    boundary = [boundary length(sub.raw.facemorph)];
    
    for i = 1:length(boundary)-1
        blocks{i} = sub.raw.facemorph((boundary(i)+1):boundary(i+1));
    end
    
    % in case we're dealing with the replication study, split the seq into 3 parts
    
    if isfield(sub.raw.facemorph{2},'seq')
        %        for i = 1:length(blocks)
        %            sub.raw.facemorph{2}.(['seq' num2str(i)]) = sub.raw.facemorph{2}.seq;
        %            sub.raw.facemorph{2}.(['seq' num2str(i)]).emotion = sub.raw.facemorph{2}.seq.emotion((1+84*(i-1)):84*i);
        %            sub.raw.facemorph{2}.(['seq' num2str(i)]).actor = sub.raw.facemorph{2}.seq.actor((1+84*(i-1)):84*i);
        %            sub.raw.facemorph{2}.(['seq' num2str(i)]).button = sub.raw.facemorph{2}.seq.button((1+84*(i-1)):84*i);
        %
        %        end
        sub.raw.facemorph{2}.seq1 = sub.raw.facemorph{2}.seq;
    end
    
    for i = 1:length(blocks)
        blockresps{i} = jspsych_result_filter(blocks{i},'test_part','response');
        
        blockstims{i} = jspsych_result_filter(blocks{i},'test_part','pres_main');
        
        blockord{i} = sub.raw.facemorph{2}.(['seq' num2str(i)]).button;
        blockgroup{i} = sub.raw.facemorph{2}.(['seq' num2str(i)]).group;
        for ii = 1:length(blockresps{i})
            if strcmpi(blockresps{i}{ii}.block,'HASA')
                if strcmpi(blockresps{i}{ii}.resp,'HAPPY')
                    blockresps{i}{ii}.respcode = 0;
                elseif strcmpi(blockresps{i}{ii}.resp,'SAD')
                    blockresps{i}{ii}.respcode = 1;
                else
                    blockresps{i}{ii}.respcode = NaN;
                end
            elseif strcmpi(blockresps{i}{ii}.block,'AFAN')
                if strcmpi(blockresps{i}{ii}.resp,'FEARFUL')
                    blockresps{i}{ii}.respcode = 0;
                elseif strcmpi(blockresps{i}{ii}.resp,'ANGRY')
                    blockresps{i}{ii}.respcode = 1;
                else
                    blockresps{i}{ii}.respcode = NaN;
                end
            elseif strcmpi(blockresps{i}{ii}.block,'HAAN')
                if strcmpi(blockresps{i}{ii}.resp,'HAPPY')
                    blockresps{i}{ii}.respcode = 0;
                elseif strcmpi(blockresps{i}{ii}.resp,'ANGRY')
                    blockresps{i}{ii}.respcode = 1;
                else
                    blockresps{i}{ii}.respcode = NaN;
                end
            end
        end
        blocknames{i} = blockresps{i}{1}.block;
    end
    
    for i = 1:length(blocks)
        if length(blockresps{i})==length(blockord{i})
            sub.facemorph.(blocknames{i}).blockord = i;
            sub.facemorph.(blocknames{i}).raw.resps = blockresps{i};
            sub.facemorph.(blocknames{i}).raw.stims = blockstims{i};
            sub.facemorph.(blocknames{i}).raw.ord = blockord{i};
            sub.facemorph.(blocknames{i}).group = blockgroup{i};
            
            sub.facemorph.(blocknames{i}).morphlevel = vert(getfield_list(blockresps{i},'stimlevel'));
            sub.facemorph.(blocknames{i}).respcode = vert(getfield_list(blockresps{i},'respcode'));
            sub.facemorph.(blocknames{i}).actor = vert(getfield_list(blockstims{i},'actorid'));
            sub.facemorph.(blocknames{i}).rt = vert(getfield_list(blockresps{i},'rt'));
            sub.facemorph.(blocknames{i}).mdl = pilot_fit_logistic(sub.facemorph.(blocknames{i}).morphlevel,sub.facemorph.(blocknames{i}).respcode,sub.facemorph.(blocknames{i}).actor);
            
            sub.facemorph.(blocknames{i}).respright = xor(vert(getfield_list(blockresps{i},'respcode')),sub.facemorph.(blocknames{i}).raw.ord(1:end)-1);
            sub.facemorph.(blocknames{i}).prcright = mean(sub.facemorph.(blocknames{i}).respright);
            
            sub.facemorph.(blocknames{i}).prcerror = (mean(sub.facemorph.(blocknames{i}).respcode(sub.facemorph.(blocknames{i}).morphlevel==1)==1)+ ...
                mean(sub.facemorph.(blocknames{i}).respcode(sub.facemorph.(blocknames{i}).morphlevel==101)==0))/2;
        end
    end
    
elseif isfield(template,'facemorph')
    fields = fieldnames_recurse(template.facemorph);
    fields = cell_unpack(fields);
    sub.facemorph = struct;
    for i = 1:length(fields)
        tmp = getfield_nest(template.facemorph,fields{i});
        if isnumeric(tmp)
            sub.facemorph = assignfield_nest(sub.facemorph,fields{i},NaN(size(tmp)));
        elseif iscell(tmp) && ~isempty(tmp)
            clear tmp2
            for ii = 1:length(tmp)
                if isnumeric(tmp{ii})
                    tmp2{ii} = NaN(size(tmp{ii}));
                else
                    tmp2{ii} = NaN;
                end
            end
            sub.facemorph = assignfield_nest(sub.facemorph,fields{i},tmp2);
        elseif istable(tmp)
            sub.facemorph = assignfield_nest(sub.facemorph,fields{i},array2table(NaN(size(tmp)),'VariableNames',tmp.Properties.VariableNames));
        end
    end
end

%
% if strcmpi(blockresps{i}{1}.block,'HASA')
%     sub.facemorph.HASA.blockord = 1;
%     sub.facemorph.AFAN.blockord = 2;
%
%     sub.facemorph.HASA.raw.resps = block1resps;
%     sub.facemorph.AFAN.raw.resps = block2resps;
%     sub.facemorph.HASA.raw.stims = block1stims;
%     sub.facemorph.AFAN.raw.stims = block2stims;
%     sub.facemorph.HASA.raw.ord = block1ord;
%     sub.facemorph.AFAN.raw.ord = block2ord;
%
%     sub.facemorph.HASA.morphlevel = vert(getfield_list(block1resps,'stimlevel'));
%     sub.facemorph.HASA.respcode = vert(getfield_list(block1resps,'respcode'));
%     sub.facemorph.HASA.actor = vert(getfield_list(block1stims,'actorid'));
%     sub.facemorph.HASA.rt = vert(getfield_list(block1resps,'rt'));
%     sub.facemorph.HASA.mdl = pilot_fit_logistic(sub.facemorph.HASA.morphlevel,sub.facemorph.HASA.respcode,sub.facemorph.HASA.actor);
%
%     sub.facemorph.AFAN.morphlevel = vert(getfield_list(block2resps,'stimlevel'));
%     sub.facemorph.AFAN.respcode = vert(getfield_list(block2resps,'respcode'));
%     sub.facemorph.AFAN.actor = vert(getfield_list(block2stims,'actorid'));
%     sub.facemorph.AFAN.rt = vert(getfield_list(block2resps,'rt'));
%     sub.facemorph.AFAN.mdl = pilot_fit_logistic(sub.facemorph.AFAN.morphlevel,sub.facemorph.AFAN.respcode,sub.facemorph.AFAN.actor);
%
%     sub.facemorph.HASA.respright = xor(vert(getfield_list(block1resps,'respcode')),sub.facemorph.AFAN.raw.ord(1:end-1)-1);
%     sub.facemorph.AFAN.respright = xor(vert(getfield_list(block2resps,'respcode')),sub.facemorph.HASA.raw.ord(1:end-1)-1);
%     sub.facemorph.HASA.prcright = mean(sub.facemorph.HASA.respright);
%     sub.facemorph.AFAN.prcright = mean(sub.facemorph.AFAN.respright);
% else
%     sub.facemorph.HASA.blockord = 2;
%     sub.facemorph.AFAN.blockord = 1;
%
%     sub.facemorph.HASA.resps = block2resps;
%     sub.facemorph.AFAN.resps = block1resps;
%     sub.facemorph.HASA.raw.stims = block2stims;
%     sub.facemorph.AFAN.raw.stims = block1stims;
%     sub.facemorph.HASA.raw.ord = block2ord;
%     sub.facemorph.AFAN.raw.ord = block1ord;
%
%     sub.facemorph.HASA.morphlevel = vert(getfield_list(block2resps,'stimlevel'));
%     sub.facemorph.HASA.respcode = vert(getfield_list(block2resps,'respcode'));
%     sub.facemorph.HASA.actor = vert(getfield_list(block2stims,'actorid'));
%     sub.facemorph.HASA.rt = vert(getfield_list(block2resps,'rt'));
%     sub.facemorph.HASA.mdl = pilot_fit_logistic(sub.facemorph.HASA.morphlevel,sub.facemorph.HASA.respcode,sub.facemorph.HASA.actor);
%
%     sub.facemorph.AFAN.morphlevel = vert(getfield_list(block1resps,'stimlevel'));
%     sub.facemorph.AFAN.respcode = vert(getfield_list(block1resps,'respcode'));
%     sub.facemorph.AFAN.actor = vert(getfield_list(block1stims,'actorid'));
%     sub.facemorph.AFAN.rt = vert(getfield_list(block1resps,'rt'));
%     sub.facemorph.AFAN.mdl = pilot_fit_logistic(sub.facemorph.AFAN.morphlevel,sub.facemorph.AFAN.respcode,sub.facemorph.AFAN.actor);
%
%     sub.facemorph.HASA.respright = xor(vert(getfield_list(block2resps,'respcode')),(sub.facemorph.HASA.raw.ord(1:end-1))-1);
%     sub.facemorph.AFAN.respright = xor(vert(getfield_list(block1resps,'respcode')),(sub.facemorph.AFAN.raw.ord(1:end-1))-1);
%     sub.facemorph.HASA.prcright = mean(sub.facemorph.HASA.respright);
%     sub.facemorph.AFAN.prcright = mean(sub.facemorph.AFAN.respright);
% end

% sub.facemorph.HASA.prcerror = (mean(sub.facemorph.HASA.respcode(sub.facemorph.HASA.morphlevel==1)==1)+ ...
%     mean(sub.facemorph.HASA.respcode(sub.facemorph.HASA.morphlevel==101)==0))/2;
% sub.facemorph.AFAN.prcerror = (mean(sub.facemorph.AFAN.respcode(sub.facemorph.AFAN.morphlevel==1)==1)+ ...
%     mean(sub.facemorph.AFAN.respcode(sub.facemorph.AFAN.morphlevel==101)==0))/2;

clear tmp tmp2

% now for the bodily maps

if isfield(sub.raw,'embody')% && ~isfield(sub,'embody')
    
    maptrls = jspsych_result_filter(sub.raw.embody,'trial_type','embody');
    scaletrls = jspsych_result_filter(sub.raw.embody,'trial_type','survey-likert');
    
    
    
    if ~isempty(maptrls) && ~isempty(scaletrls)
        badmaps = zeros(1,length(maptrls));
        for i = 1:length(maptrls)
            if ~isfield(maptrls{i},'stimulus')
                badmaps(i) = 1;
            end
        end
        badindx = find(badmaps);
        
        maptrls(badindx) = [];
        
        scaletrls(badindx(badindx<=length(scaletrls))) = [];
        %     catch
        %        disp('test')
        %     end
        
        
        
        for i = 1:length(maptrls)
            sub.embody.bodymap{i} = embody_json2map(maptrls(i));
            sub.embody.emotion{i} = maptrls{i}.stimulus;
        end
        
        if isfield_nest(sub.raw.embody{1},'sesdat.actorder') && sub.raw.embody{1}.sesdat.actorder == 1;
           for i = 1:length(maptrls)
               sub.embody.bodymap{i} = -sub.embody.bodymap{i};
           end
           
           sub.embody.actorder = sub.raw.embody{1}.sesdat.actorder;
           sub.embody.colororder = sub.raw.embody{1}.sesdat.colororder;
        end
        
        for i = 1:length(scaletrls)
            scl = jsondecode(scaletrls{i}.responses);
            sub.embody.resps(i) = scl;
        end
        
        sub.embody.resps = mergestructs(sub.embody.resps);
        sub.embody.resps.emotion = sub.embody.emotion(1:length(sub.embody.resps.lapse))';
        sub.embody.resps = struct2table(sub.embody.resps);
        
        allemos = {'ANGER','CONTEMPT','DISGUST','ENVY','FEAR','HAPPINESS','PRIDE','SADNESS','SHAME','SURPRISE','THINKING','HUNGER','YOUR HEARTBEAT','BREATHING'};
        
        if length(sub.embody.bodymap) < length(allemos)
            [m1] = match_str(allemos,sub.embody.emotion);
            [~,m2] = match_str(sub.embody.emotion,allemos);
            bmap = cell(1,length(allemos));
            bmap(m1) = sub.embody.bodymap;
            indx = setdiff(1:length(allemos),m1);
            for q = indx
                bmap(q) = {NaN(size(sub.embody.bodymap{1}))};
            end
            sub.embody.bodymap = bmap;
            sub.embody.emotion = allemos;
            varnames = sub.embody.resps.Properties.VariableNames;
            
            [m1] = match_str(allemos,sub.embody.resps.emotion);
            resps = sub.embody.resps{:,1:5};
            resps = array2table(NaN(length(allemos),5),'VariableNames',varnames(1:5));
            resps.emotion = allemos';
            resps{m1,1:5} = sub.embody.resps{:,1:5};
            sub.embody.resps = resps;
            sub.embody.origorder = m2;
        end
        
        [~,m1] = match_str(allemos,sub.embody.emotion);
        [~,m2] = match_str(sub.embody.emotion,allemos);
        sub.embody.bodymap = sub.embody.bodymap(m1);
        sub.embody.emotion = sub.embody.emotion(m1);
        sub.embody.resps{:,1:5} = sub.embody.resps{m1,1:5};
        sub.embody.resps.emotion = sub.embody.resps.emotion(m1);
        if ~isfield(sub.embody,'origorder')
            sub.embody.origorder = m2;
        end
    else
    end
end
%         fields = fieldnames_recurse(template.embody);
%         fields = cell_unpack(fields);
%         sub.embody = struct;
%         for i = 1:length(fields)
%             tmp = getfield_nest(template.embody,fields{i});
%             if isnumeric(tmp)
%                 sub.embody = assignfield_nest(sub.embody,fields{i},NaN(size(tmp)));
%             elseif iscell(tmp)
%                 for ii = 1:length(tmp)
%                     if isnumeric(tmp{ii})
%                         tmp2{ii} = NaN(size(tmp{ii}));
%                     else
%                         tmp2{ii} = NaN;
%                     end
%                 end
%                 sub.embody = assignfield_nest(sub.embody,fields{i},tmp2);
%             elseif istable(tmp)
%                 sub.embody = assignfield_nest(sub.embody,fields{i},array2table(NaN(size(tmp)),'VariableNames',tmp.Properties.VariableNames));
%             end
%         end
%     end
%else%if ~isfield(sub,'embody')
%     fields = fieldnames_recurse(template.embody);
%     fields = cell_unpack(fields);
%     sub.embody = struct;
%     for i = 1:length(fields)
%         tmp = getfield_nest(template.embody,fields{i});
%         if isnumeric(tmp)
%             sub.embody = assignfield_nest(sub.embody,fields{i},NaN(size(tmp)));
%         elseif iscell(tmp)
%             for ii = 1:length(tmp)
%                 if isnumeric(tmp{ii})
%                     tmp2{ii} = NaN(size(tmp{ii}));
%                 else
%                     tmp2{ii} = NaN;
%                 end
%             end
%             sub.embody = assignfield_nest(sub.embody,fields{i},tmp2);
%         elseif istable(tmp)
%             sub.embody = assignfield_nest(sub.embody,fields{i},array2table(NaN(size(tmp)),'VariableNames',tmp.Properties.VariableNames));
%         end
%     end
end