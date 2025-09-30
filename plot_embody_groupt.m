function [tdata,alldata,tID,allemos] = plot_embody_groupt(subs,thesesubs,field,p,pindx,tdata)

if nargin < 4 || isempty(p)
    figure
    p = panel('no-manage-font');
    pindx = {};
end

if nargin < 3
    field = 'bodymap';
end

nemos = length(subs{1}.embody.emotion);

p(pindx{:}).pack(2,round(nemos/2))


mask = imread('~/Desktop/armonylab/embody-test/embody/matlab/mask.png');
mask = [zeros(522,2) mask zeros(522,2)];
mask = [zeros(1,175); mask; zeros(1,175)];

if size(getfield_nest(subs{1}.embody,'bodymap'),1) < 200
    mask = imresize(mask,0.25);
end

inmask = find(mask > 128);

if ~exist('tdata','var')
    if iscell(thesesubs)
        [~,alldata{1}] = plot_embody_groupt(subs,thesesubs{1});
        delete(gcf)
        [~,alldata{2}] = plot_embody_groupt(subs,thesesubs{2});
        delete(gcf)
        allemos = unique(subs{1}.embody.emotion);
    else
        
        if islogical(thesesubs)
            thesesubs = find(thesesubs);
        end
        
        allemos = subs{1}.embody.emotion;
        for i = 1:length(thesesubs)
            for ii = 1:length(allemos)
                indx = find(strcmpi(subs{thesesubs(i)}.embody.emotion,allemos{ii}));
                if length(indx)>0
                    
                    if ~contains(field,'-')
                        tmp = getfield_nest(subs{thesesubs(i)}.embody,field);
                        tmp = tmp{indx}(inmask);
                    else
                        fieldtok = tokenize(field,'-');
                        tmp = getfield_nest(subs{thesesubs(i)}.embody,fieldtok{1});
                        tmp = tmp{indx}(inmask);
                        
                        tmp2 = getfield_nest(subs{thesesubs(i)}.embody,fieldtok{2});
                        tmp2 = tmp2{indx}(inmask);
                        
                        tmp = tmp-tmp2;
                    end
                    %tmp = subs{thesesubs(i)}.embody.act_vectmaps(:,indx);
                    %tmp = reshape(subs{thesesubs(i)}.embody.bodymap{indx},[],1);
                    %tmp = subs{thesesubs(i)}.embody.vectmaps(:,indx);
                    try
                        %alldata(:,i,ii) = tmp(inmask);
                        alldata(:,i,ii) = tmp;
                    catch
                        disp('test')
                    end
                else
                    alldata(:,i,ii) = NaN(length(inmask),1);
                end
            end
        end
    end
    
    if ~iscell(alldata)
        for i = 1:length(allemos)
            %tdata(:,i) = nanmean(alldata(:,:,i)',1);
            for ii = 1:size(alldata,1)
                if ~all(isnan(alldata(ii,:,i)))
                    [~,~,~,STATS] = ttest(alldata(ii,:,i)');
                    tdata(ii,i)=STATS.tstat;
                else
                    tdata(ii,i) = NaN;
                end
            end
        end
    else
        for i = 1:length(allemos)
            %tdata(:,i) = nanmean(alldata(:,:,i)',1);
            [~,~,~,STATS] = ttest2(alldata{1}(:,:,i)',alldata{2}(:,:,i)');
            tdata(:,i)=STATS.tstat;
        end
    end
else
            allemos = subs{1}.embody.emotion;

end

%alltdata=tdata(:);
alltdata = tdata;
alltdata(find(~isfinite(alltdata))) = [];

if ~iscell(thesesubs)
    nsubs = length(thesesubs);
    df = nsubs-1;
else
    df = sum(cellfun(@length,thesesubs))-2;
end
P        = 1-cdf('T',alltdata,df);  % p values
%pID = fdr(P(1:length(P)*10/14),0.05);
%tID      = icdf('T',1-pID,df);      % T threshold, indep or pos. correl.
tID = icdf('T',1-0.05,df);

load('hotcoldmap')

thresh = tID;
%thresh = 0;

tvals_for_plot=zeros(size(mask,1),size(mask,2),10);
for condit=1:nemos
    temp=zeros(size(mask));
    temp(inmask)=tdata(:,condit);
    temp(find(~isfinite(temp)))=0; % we set nans and infs to 0 for display
    %max(temp(:))
    tvals_for_plot(:,:,condit)=temp;
end


for i = 1:nemos
    [i1,i2] = ind2sub([2 round(nemos/2)],i);
    p(pindx{:},i1,i2).select()
    embody_plotmap(tvals_for_plot(:,:,i).*(abs(tvals_for_plot(:,:,i)) > thresh));
    set(gca,'YDir','reverse');
    axis equal
    title(allemos{i},'FontSize',14)
end
p.margintop = 8;
set(gcf,'Color','w')
Normalize_Clim(gcf,1)
cbar = colorbar;
cbar.Label.String = 't value';
cbar.FontSize = 16;
p.marginright = 20; p.de.marginright = 5;


