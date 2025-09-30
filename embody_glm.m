function [coeffs,recon,coeffvals] = embody_glm(map,basis)

mask = imread('~/Desktop/armonylab/embody-test/embody/matlab/mask.png');
mask = [zeros(522,2) mask zeros(522,2)];
mask = [zeros(1,175); mask; zeros(1,175)];

if all(isnan(map))
   coeffvals = NaN(length(basis.name),1);
   coeffs = array2table(coeffvals','VariableNames',basis.name);
   recon = map;
   return
end

if numel(map) < 50000
   mask = imresize(mask,0.25);
end

inmask = find(mask > 128);

% rescale the basis functions if the size doesn't match
if numel(basis.fcn{1})> numel(map)
    basis = rmfield(basis,'vec');
   for i = 1:length(basis.fcn)
      basis.fcn{i} = imresize(basis.fcn{i},0.25); 
      basis.fcn{i} = basis.fcn{i}./norm(basis.fcn{i});
      
      basis.vec(:,i) = basis.fcn{i}(inmask);
   end
end

[coeffs,fitinfo] = lasso(basis.vec,map(inmask),'Alpha',1,'Intercept',false);
bestlam = findknee(fitinfo.MSE);
coeffs = coeffs(:,bestlam); 

%lm = fitlm(basis.vec,map(inmask));
%coeffs = lm.Coefficients.Estimate(2:end);

recon = zeros(size(mask)); 
recon(inmask) = basis.vec*coeffs;


coeffvals = coeffs;
coeffs = array2table(coeffs','VariableNames',basis.name);
