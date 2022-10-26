
%-------------------------------------------------------------------------------
% Project   : Shapenet
% Author    : Timon W. Matz
% Language  : matlab
% CreateTime: 02 Okt 2022
% Function  : Example file how to call analyse_intensity_at_outlines to
%             extract anisotropy and orientation along outline (of the inside)
%-------------------------------------------------------------------------------

watershedded_labelled_image = [0 0 1 1 1 1 0 0; 0 1 1 1 1 1 1 0; 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1; 0 1 1 1 1 1 1 0; 0 0 1 1 1 1 0 0]; % Initialize watershedded_labelled_image here
microtubule_intensity_projection_image = randi([0, 255], 8, 8); % Initialize microtubule_intensity_projection_image here
cell_outlines = {{1, 1, [1 2 3 4 5 6 7 8 8 8 8 7 6 5 4 3 2 1 1 1], [3 2 1 1 1 1 2 3 4 5 6 7 8 8 8 8 7 6 5 4]}}; % Initialize cell_outlines here 
% cell_outlines{m} = {cell_i cell_number cell_xpos cell_ypos};

data_single = analyse_intensity_at_outlines(watershedded_labelled_image, microtubule_intensity_projection_image, cell_outlines);
% each cell outline gets for each contour pixel the following values:
%     x-, y-coordinates, curvature, normals of x, and y, smoothed anisotropy, orientation, localLEC (radius?), normalised anisotropy
data_single{:}