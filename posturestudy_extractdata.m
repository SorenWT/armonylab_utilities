function [subs,fullsubs] = posturestudy_extractdata(res)

cformindx = find(cellfun(@isstruct,res,'UniformOutput',true));


subs = cell(1,length(cformindx));
for i = 1:length(cformindx)
    if isfield(res{cformindx(i)},'emailid')
        subs{i} = struct;
        subs{i}.raw.consform = consentform_decode(res{cformindx(i)});
        subs{i}.emailid = subs{i}.raw.consform.emailid;
        if isnumeric(subs{i}.emailid)
            subs{i}.emailid = num2str(subs{i}.emailid);
        end

        subs{i}.raw.photos = [];
        if cformindx(i) ~= length(res) && length(res{cformindx(i)+1})==4
            subs{i}.raw.photos = res{cformindx(i)+1};
        else
            for q = 1:length(res)
                if iscell(res{q}) && ischar(res{q}{end}) && strcmpi(res{q}{end},subs{i}.emailid)
                    subs{i}.raw.photos = [subs{i}.raw.photos; res{q}]; % deal with people who may have multiple sets of photos due to retaking them
                end
            end
        end
                    %subs{i}.raw.embody = cell(0,0);

        for q = setdiff(1:length(res),cformindx)
            for qq = 1:length(res{q})
                if iscell(res{q}) && isfield(res{q}{qq},'emailid')  && strcmpi(subs{i}.emailid,res{q}{qq}.emailid)
                    if length(res{q}) > 100 && any(contains(fieldnames(res{q}{2}),'seq'))
                        subs{i}.raw.facemorph = res{q};
                    elseif length(res{q}) > 100
                        subs{i}.raw.perspective = res{q};
                    else
                        subs{i}.raw.embody = res{q};
                    end
                end
            end
        end
    end
end

subs(cellfun(@isempty,subs,'uniformoutput',true)) = [];


% remove duplicates
ids = getfield_list(subs,'emailid');
ids(cellfun(@isnumeric,ids,'uniformoutput',true)) = cellfun(@num2str,ids(cellfun(@isnumeric,ids,'uniformoutput',true)),'uniformoutput',false);
uniqueids = unique(ids);
rmindx = [];
for i = 1:length(uniqueids)
    if sum(strcmpi(ids,uniqueids{i}))>1
        dups = find(strcmpi(ids,uniqueids{i}));
        rmindx = [rmindx dups(2:end)]; % take the more recent consent form
    end
end
subs(rmindx) = [];


fullsubs = subs;

rmindx = [];
for i = 1:length(subs)
    if length(fieldnames(subs{i}.raw)) <= 2  % if they just did the consent form (plus the empty photos field)
        rmindx = [rmindx i];
    end
end

subs(rmindx) = [];
