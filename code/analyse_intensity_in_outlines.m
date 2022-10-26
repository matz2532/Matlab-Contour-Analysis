%-------------------------------------------------------------------------------
% Author    : René Schneieder (Original); Timon W. Matz (adapted by)
% Language  : matlab
% CreateTime: 02 Okt 2022
% Function  : This function is used to extract information (orientation and  anisotropy) of microtubule
%             intensities of the largest empty circle in the given contour outlines
% Needed Add-Ons:  Curve Fitting Toolbox, Image Processing Toolbox, Statistics and Machine Learning Toolbox
%-------------------------------------------------------------------------------

function [all_cell_labels, all_anisotropy_values, all_orientation_values] = analyse_intensity_in_outlines(watershedded_labelled_image, intensity_projection_image, cell_outlines, boarder_to_ignore)
% boarder_to_ignore should be a positive integer >= 0 

%% Define the size of the contour margin (in pixels)
MARGIN_START = 1;                           %margin begins 1 pixel from the contour (towards inside)
MARGIN_END = 8;                             %margin ends 8 pixels from the contour (towards inside)
MARGIN = MARGIN_END - MARGIN_START +1;      %total depth of margin
SE = strel("diamond", boarder_to_ignore);


[rows, columns] = size(watershedded_labelled_image); 
STOMATA_ALL = zeros(rows, columns);

%% Generate a mask to exclude walls around stomata
se = strel('disk', MARGIN_END+1);
STOMATA_ALL_DILATED = imdilate(STOMATA_ALL, se);
MIP_Image_Opt_2 = intensity_projection_image .* imcomplement(STOMATA_ALL_DILATED);
    
%% Create operators for orientation and anisotropy measurements (this
% part is based on the Fiji-script from FibrilTool by Arezki Boudaoud
% et al., Nature Protocols, 2014)
    imgI = MIP_Image_Opt_2;
    thresh = 2;

% Compute gradient in x- and y-direction
    x = imtranslate(imgI, [-0.5, 0], 'cubic');
    x1 = imtranslate(x, [1, 0]);
    X = imsubtract(x, x1);
    y = imtranslate(imgI, [0, -0.5], 'cubic');
    y1 = imtranslate(y, [0, 1]);
    Y = imsubtract(y, y1);

% Compute norm of gradient in g
    g = immultiply(X,X);
    gp = immultiply(Y,Y);
    G = sqrt(imadd(g, gp));
    % set the effect of the gradient to 1/255 when too low ; threshold = thresh
    G(G<=thresh) = 255;

% Normalize "x" and "y" to components of normal
    x_norm = imdivide(X,G);
    y_norm = imdivide(Y,G);

% Compute nxx, nxy, nyy
    nxx = immultiply(x_norm,x_norm);
    nxy = immultiply(x_norm,y_norm);
    nyy = immultiply(y_norm,y_norm);

all_cell_labels = {};
all_anisotropy_values = {};
all_orientation_values = {};

% needs: watersheded image, cell outlines
for i = 1:length(cell_outlines);    
    
    %% Define the cell's outline
    cell = watershedded_labelled_image(round(mean(cell_outlines{1,i}{1,4})), round(mean(cell_outlines{1,i}{1,3})));
    contour = watershedded_labelled_image == cell;
    contour = imerode(contour, SE);
    contour_0 = bwboundaries(bwperim(bwmorph(contour, 'spur', Inf)));

    % create circle outline
    segment_x = contour_0{1}(:,2); 
    segment_y = contour_0{1}(:,1);

    % create anisotropy and orienation
    [anisotropy, orienation] = calculate_anisotropy_and_orientation(segment_x, segment_y, nxx, nxy, nyy);

    all_cell_labels{i} = cell;
    all_anisotropy_values{i} = anisotropy;
    all_orientation_values{i} = orienation;

end

end
