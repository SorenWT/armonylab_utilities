function res = proc_embody_spec(dat,distfun,pers,sel,varargin)
% dat is a 3D array of bodymap data, in the form regions/pixels x emotions
% x subjects
% distfun is a function which calculates the distance between two vectors
% (or between two matrices - indicate this with the "distdim" optional
% argument
% pers is a vector with the personality measure to correlate with
% sel is a vector with indices of participants to include

argsin = varargin;
argsin = setdefault(argsin,'distdim','vect');% assumes distance function takes vectors, unless otherwise specified
argsin = setdefault(argsin,'ctrfunc',@(d,dim)mean(d,dim)); % what function to use to summarize the distribution of distances between body maps
argsin = setdefault(argsin,'plot','off');
argsin = setdefault(argsin,'notes','');
argsin = setdefault(argsin,'fullconfusion','off');
argsin = setdefault(argsin,'template',[]);

distdim = EasyParse(argsin,'distdim');
ctrfunc = EasyParse(argsin,'ctrfunc');
template = EasyParse(argsin,'template');

res.inputs.distfun = distfun; res.inputs.pers = pers; res.inputs.sel = sel; 
res.inputs.notes = EasyParse(argsin,'notes'); res.inputs.ctrfunc = ctrfunc;
res.inputs.distdim = distdim;

test = whos('dat');
if test.bytes < 10000000 % less than 10 Mb
   res.inputs.dat = dat; 
else
    warning('Data not stored in res.inputs - too large');
end

if length(unique(sel))<=2
sel = find(sel);
end

if EasyParse(argsin,'fullconfusion','on')
    resdat = reshape(dat, size(dat,1),[]);
    for i = 1:size(resdat,2)
       for ii = 1:i
           res.confusion(i,ii) = distfun(dat(:,i),dat(:,ii));
       end
    end
    res.confusion = res.confusion+res.confusion'-(res.confusion.*eye(size(res.confusion)));
    res.confgrp = array2table([vert(Make_designVect(repmat(10,1,size(dat,3)))) ...
        vert(repmat(1:10,1,size(dat,3)))],'VariableNames',{'sub','emo'});
end


for i = 1:size(dat,3)
    if ismember(i,sel)
        fprintf([num2str(i) ' '])
        if strcmpi(distdim,'vect')
            tmp = zeros(size(dat,2));
            
            for q = 1:size(dat,2)
                for qq = 1:size(dat,2)
                    tmp(q,qq) = distfun(dat(:,q,i),dat(:,qq,i));
                end
            end
            
        else
            tmp = distfun(dat(:,:,i),dat(:,:,i));
        end
        res.bodyspec.dist(i) = ctrfunc(belowDiag(tmp),1);
        
        if isempty(template)
            exclmean = nanmean(dat(:,:,except(1:size(dat,3),i)),3);
        else
           exclmean = template; 
        end
        if strcmpi(distdim,'vect')
            tmp = zeros(size(dat,2));
            % we only care about the corresponding emotions here
            for q = 1:size(dat,2)
                tmp(q,q) = distfun(dat(:,q,i),exclmean(:,q));
            end
        else
            tmp = distfun(dat(:,:,i),exclmean);
        end
        res.bodyspec.distmean(i) = ctrfunc(diag(tmp),1);
        res.distmeanmat(i,:) = horz(diag(tmp));
    else
       res.bodyspec.dist(i) = NaN;
       res.bodyspec.distmean(i) = NaN;
    end
end

res.bodyspec = struct2table(structfun(@vert,res.bodyspec,'uniformoutput',false));

%newspec = NaN(size(dat,3),2);
%newspec(sel,:) = tmpspec{:,:};
%res.bodyspec = array2table(tmpspec,'VariableNames',tmpspec.Properties.VariableNames);

[res.res.r,res.res.p,res.res.n,res.res.ci] = corrswt(res.bodyspec{sel,:},vert(pers(sel)));
res.res.n = length(sel);

if CheckInput(argsin,'cov') 
   [res.res.partr,res.res.partp] = partialcorr(res.bodyspec{sel,:},vert(pers(sel)),vert(EasyParse(argsin,'cov')),'rows','pairwise','type','spearman');
end

if strcmpi(EasyParse(argsin,'plot'),'on')
    subplot(1,2,1)
    nicecorrplot(res.bodyspec{sel,1},vert(pers(sel)),{'Distance between emotions','Personality'})
    subplot(1,2,2)
    nicecorrplot(res.bodyspec{sel,2},vert(pers(sel)),{'Distance to group mean','Personality'})
end