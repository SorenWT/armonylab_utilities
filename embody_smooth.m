function [vectmaps,smoothmaps] = embody_smooth(bodymap_cell,smoothing)

h=fspecial('gaussian',[smoothing(1) smoothing(1)],smoothing(2)); % should maybe replace this with a disk?

smoothmaps = bodymap_cell;
for i = 1:length(bodymap_cell)
    tmp1 = double(bodymap_cell{i}).*(bodymap_cell{i}>0); tmp2 = double(bodymap_cell{i}).*(bodymap_cell{i}<0);
    
    smoothmaps{i} = imfilter(tmp1,h)+imfilter(tmp2,h); 
end

vectmaps = cellfun(@(d)reshape(d,[],1),smoothmaps,'UniformOutput',false);
vectmaps = cat(2,vectmaps{:});