function reducout = posture_convert_orig(posreduc,posnames,strictflag)

if nargin<3
   strictflag = false;
end


% assumes data from posturedata_reduce
reducout = array2table(zeros(size(posreduc,1),length(posnames)),'VariableNames',posnames);

vars = posreduc.Properties.VariableNames;
for i = 1:size(posreduc,2)
    reducout.(vars{i}) = posreduc.(vars{i});
end

if strictflag
    postvars = posnames(contains(posnames,'_post_'));
    eqvars = erase(postvars,'post_');
    for i = 1:length(postvars)
       reducout.(postvars{i}) = -reducout.(eqvars{i}); % put the mislabeled sign back
    end
    
    eqvars = posnames(contains(posnames,'Anterior'));
    postvars = replace(eqvars,'Anterior','Posterior');
    for i = 1:length(postvars)
        reducout.(postvars{i}) = reducout.(eqvars{i});
    end
end