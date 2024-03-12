function [scl_preproc] = scale_preproc(scaleinfo,rawscale)


info = scaleinfo;
factnames = fieldnames(scaleinfo.factors);

scl_preproc = rawscale;
for i = 1:width(scl_preproc)
    for ii = 1:height(scl_preproc)
        tmptmp = find(strcmpi(scl_preproc{ii,i},scaleinfo.respcoding));
        if isempty(tmptmp); tmptmp = NaN; end
        tmp(ii) = tmptmp;
        if scaleinfo.reverse(i) == -1
            tmp(ii) = length(scaleinfo.respcoding)+1-tmp(ii);
        end
    end
    scl_preproc.(scl_preproc.Properties.VariableNames{i}) = vert(tmp);
end
