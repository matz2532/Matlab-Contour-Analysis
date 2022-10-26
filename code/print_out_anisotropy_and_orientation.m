function print_out_anisotropy_and_orientation(all_cell_labels, all_anisotropy_values, all_orientation_values)

if length(all_cell_labels) > 1
    for i = 1:length(all_cell_labels)
        current_cell = all_cell_labels{i};
        anisotropy = all_anisotropy_values{i};
        orientation = all_orientation_values{i};
        fprintf("The cell %d with anisotropy of %f and orientation of %f\n", current_cell, anisotropy, round(orientation, 1));
    end
else
    fprintf("The cell %d with anisotropy of %f and orientation of %f\n", all_cell_labels, all_anisotropy_values, round(all_orientation_values, 1));
end

end

