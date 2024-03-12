function mdl = pilot_fit_logistic(morphlevels,resps,actors)

morphlevels = vert(morphlevels); resps = vert(resps); actors = vert(actors);

tbl = array2table([morphlevels resps actors],'VariableNames',{'morphlevel' ,'resp', 'actor'});

try
    mdl.mdl = fitglme(tbl,'resp ~ 1+morphlevel+(1|actor)','Distribution','Binomial','Link','Logit');
catch
    warning('Model failed to fit! Fitting without random intercept for actor')
    mdl.mdl = fitglme(tbl,'resp ~ 1+morphlevel','Distribution','Binomial','Link','Logit');
end


% calculate a bunch of GOF statistics
mdl.yhat = predict(mdl.mdl,tbl);
mdl.p = mdl.mdl.Coefficients{2,6};
mdl.AIC = mdl.mdl.ModelCriterion.AIC; mdl.loglik = mdl.mdl.ModelCriterion.LogLikelihood; mdl.dev = mdl.mdl.ModelCriterion.Deviance;
[H,p_lemeshow] = lemeshow(mdl.yhat,resps,7);
mdl.H = H; mdl.p_lemeshow = p_lemeshow;
mdl.sse = sum((resps-mdl.yhat).^2);

% convert the coefficients to a struct to make them take less long to index
varnames = {'Name','Estimate','SE','tStat','DF','pValue','Lower','Upper'};
mdl.Coefficients = struct;
for i = 1:length(varnames)
    mdl.Coefficients.(varnames{i}) = mdl.mdl.Coefficients.(varnames{i});
end

% calculate threshold
for i = 1:10
    mlevs = linspace(min(morphlevels),max(morphlevels),1000);
    newtbl = array2table([mlevs' ones(1000,1).*i],'VariableNames',{'morphlevel','actor'});
    tmppred = predict(mdl.mdl,newtbl);
    [~,indx] = min(abs(tmppred-0.5));
    thresh(i) = mlevs(indx);
end
mdl.actthresh = thresh;
mdl.thresh = mean(thresh);

mdl.expthresh = median(morphlevels);
