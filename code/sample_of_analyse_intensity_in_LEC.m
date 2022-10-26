%-------------------------------------------------------------------------------
% Project   : Shapenet
% Author    : Timon W. Matz
% Language  : matlab
% CreateTime: 02 Okt 2022
% Function  : Example file how to call analyse_microtubule_in_LEC
%-------------------------------------------------------------------------------

is_intensity_type_stripe = true;
is_intensity_type_gradient = false;
plot_contour_on_labelled_image = false;

watershedded_labelled_image = [0 0 1 1 1 1 0 0; 0 1 1 1 1 1 1 0; 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1; 0 1 1 1 1 1 1 0; 0 0 1 1 1 1 0 0]; % Initialize watershedded_labelled_image here
if is_intensity_type_stripe
    fprintf("8x8 round cell with anisotropy in center from top to bottom")
    microtubule_intensity_projection_image = [0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0; 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1; 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0];
elseif is_intensity_type_gradient
    fprintf("8x8 round cell with anisotropy with gradient from top to bottom")
    microtubule_intensity_projection_image = [0 0 3 4 5 6 0 0; 0 2 3 4 5 6 7 0; 1 2 3 4 5 6 7 8; 1 2 3 4 5 6 7 8; 1 2 3 4 5 6 7 8; 1 2 3 4 5 6 7 8; 0 2 3 4 5 6 7 0; 0 0 3 4 5 6 0 0];
else
    fprintf("8x8 round cell with random intensity")
    microtubule_intensity_projection_image = randi([0, 255], 8, 8); % Initialize microtubule_intensity_projection_image here
end
cell_outlines = {{1, 1, [1 2 3 4 5 6 7 8 8 8 8 7 6 5 4 3 2 1 1 1], [3 2 1 1 1 1 2 3 4 5 6 7 8 8 8 8 7 6 5 4]}, {2, 2, [1 2 3 4 5 6 7 8 8 8 8 7 6 5 4 3 2 1 1 1], [3 2 1 1 1 1 2 3 4 5 6 7 8 8 8 8 7 6 5 4]}}; % Initialize cell_outlines here 
% cell_outlines{m} = {cell_i cell_number cell_xpos cell_ypos};

[all_cell_labels, all_anisotropy_values, all_orientation_values] = analyse_intensity_in_LEC(watershedded_labelled_image, microtubule_intensity_projection_image, cell_outlines, plot_contour_on_labelled_image);

print_out_anisotropy_and_orientation(all_cell_labels, all_anisotropy_values, all_orientation_values)
