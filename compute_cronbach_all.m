function [alphas,cis]=compute_cronbach_all(subs,sclinfo)

allscales = subs{1}.scales.allscales.Properties.VariableNames;
count = 1;

for i = 1:length(sclinfo)
   thisscl = sclinfo{i};
   items = getfield_list(subs,['scales.raw.' thisscl.shortname]);
   items = cat(1,items{:});
   factnames = fieldnames(thisscl.factors);
   for ii = 1:length(factnames)
       [alphas(count),cis(count,:)] = cronbach(items{:,thisscl.factors.(factnames{ii})},1);
        count = count+1;
   end
end