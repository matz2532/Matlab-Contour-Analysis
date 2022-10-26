%-------------------------------------------------------------------------------
% Author    : René Schneieder (Original); Timon W. Matz (adapted by)
% Language  : matlab
% CreateTime: 02 Okt 2022
% Function  : This function is used to extract information (orientation and  anisotropy) of microtubule
%             intensities of the largest empty circle in the given contour outlines
% Needed Add-Ons:  Curve Fitting Toolbox, Image Processing Toolbox, Statistics and Machine Learning Toolbox
%-------------------------------------------------------------------------------

function data_single = analyse_intensity_at_outlines(watershedded_labelled_image, microtubule_intensity_projection_image, cell_outlines)

%% Define the size of the contour margin (in pixels)
MARGIN_START = 1;                           %margin begins 1 pixel from the contour (towards inside)
MARGIN_END = 8;                             %margin ends 8 pixels from the contour (towards inside)
MARGIN = MARGIN_END - MARGIN_START +1;      %total depth of margin


[rows, columns] = size(watershedded_labelled_image); 
STOMATA_ALL = zeros(rows, columns);

%% Generate a mask to exclude walls around stomata
se = strel('disk', MARGIN_END+1);
STOMATA_ALL_DILATED = imdilate(STOMATA_ALL, se);
MIP_Image_Opt_2 = microtubule_intensity_projection_image .* imcomplement(STOMATA_ALL_DILATED);

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

data_single = {};
% needs: watersheded image, cell outlines
for i = 1:length(cell_outlines);    
    
    %% Define the cell's outline
        %{
          contour_0 = bwboundaries(bwperim(contour));
        cell_xpos = contour_0{1}(:,2)';
        cell_ypos = contour_0{1}(:,1)';
        cell_outlines{m} = {cell_i cell_number cell_xpos cell_ypos};
        %}
        % watershedded_labelled_image is watersheded image
        cell = watershedded_labelled_image(round(mean(cell_outlines{1,i}{1,4})), round(mean(cell_outlines{1,i}{1,3})));
        contour = watershedded_labelled_image == cell;
        contour_0 = bwboundaries(bwperim(bwmorph(contour, 'spur', Inf)));

    % Create an intensity profile along contour (obtain coordinates cx_0, cy_0)
        [cx_0, cy_0, I_signal_0] = improfile(MIP_Image_Opt_2, contour_0{1}(:,2), contour_0{1}(:,1));
    
    % Generate smoothed cell outline using smooth() function; stitch three
    % full circumnavigations of the cell together to avoid end-effects
    % (take the middle of the three)
        cx_sgfilt = [cx_0(1:end-1)' cx_0(1:end-1)' cx_0(1:end-1)']';
        cx_smooth = smooth(cx_sgfilt);
        cy_sgfilt = [cy_0(1:end-1)' cy_0(1:end-1)' cy_0(1:end-1)']';
        cy_smooth = smooth(cy_sgfilt);
    
    % Measure curvature & normal vectors along smoothed contour
        Vertices = [cx_smooth cy_smooth];
        Normals = LineNormals2D(Vertices);
    
    %% Go along contour and fit a circle (to get the local radius/curvature)
    % Use a subset of the contour to define local environment (here: window = MARGIN)
        Curv = [];
        CrossProd = [];
        Window = MARGIN;
        Anisotropy = [];
        Orientation = [];
        localLEC_list = [];
        Aniso_Norm = [];
        th = 0:pi/50:2*pi;
    
        for index = length(cy_0):1:2*length(cy_0)-1
            sample_x = [];
            sample_y = [];
            inner_sample_x = [];
            inner_sample_y = [];
    
            %% Curvature determination
            %get the query positions (x,y) along the contour
            %include pixels before and after the focus position (MARGIN/2)
            %for improved circle fitting
                sample_x = cx_smooth(index-floor(Window/2):index+floor(Window/2));
                sample_y = cy_smooth(index-floor(Window/2):index+floor(Window/2));

                
            % Option to have fitted circle plotted (for checking the functionality of the script)
%                 plot(cx_sgfilt, cy_sgfilt, 'b')
%                 hold on
%                 plot(sample_x, sample_y, 'bo');
%                 hold on
                [xc, yc, R] = circfit(sample_x, sample_y);
%                 plot(xc, yc, 'rx')
%                 hold on
%                 th = 0:pi/50:2*pi;
%                 plot(R*cos(th)+xc, R*sin(th)+yc, 'r-');
%                 (1/R);
                Curv = [Curv' (1/R)']';
                s = [cx_sgfilt(index+1,1)-cx_sgfilt(index,1) cy_sgfilt(index+1,1)-cy_sgfilt(index,1) 0];    %Vector component parallel to path
                k = [xc-cx_sgfilt(index,1) yc-cy_sgfilt(index,1) 0];                                        %Vector component perpendicular to path (in image plane)  
                SP = cross(s,k);                                                                            %Out-of-plane vector component (cross product)
                CrossProd = [CrossProd' SP']';
%                 axis([330 540 70 280])
%                 close

            % Option to use an additional separation between the cell contour and the analysis marging
                AnticlinalWallDistance = 2;
        
            % Define the outline of the analysis box     
                outer_sample_x = cx_smooth(index-floor(2*Window/2):index+floor(2*Window/2)) - (MARGIN_START-1+AnticlinalWallDistance)*Normals(index-floor(2*Window/2):index+floor(2*Window/2),1);
                outer_sample_y = cy_smooth(index-floor(2*Window/2):index+floor(2*Window/2)) - (MARGIN_START-1+AnticlinalWallDistance)*Normals(index-floor(2*Window/2):index+floor(2*Window/2),2);
                inner_sample_x = outer_sample_x - 2*(MARGIN+AnticlinalWallDistance)*Normals(index-floor(2*Window/2):index+floor(2*Window/2),1);
                inner_sample_y = outer_sample_y - 2*(MARGIN+AnticlinalWallDistance)*Normals(index-floor(2*Window/2):index+floor(2*Window/2),2);
                hull_x = [outer_sample_x' inner_sample_x' outer_sample_x(1)];
                hull_y = [outer_sample_y' inner_sample_y' outer_sample_y(1)];
                K = convhull(hull_x, hull_y);
                
            %% Anisotropy/Orientation Measurements (Fibril Tool)
            % Prepare Fibril Tool measurements in analysis box
                segment_x = round(hull_x(K));
                segment_y = round(hull_y(K));
                segment_ROI = roipoly(MIP_Image_Opt_2, segment_x, segment_y).*MIP_Image_Opt_2;
                %segment_ROI(segment_ROI==0) = NaN;
                
            % Option to display the analysis box for each query point       
%                 imagesc(segment_ROI)
%                 hold on
%                 plot(cx_smooth(length(cy_0):1:2*length(cy_0)-1,1), cy_smooth(length(cy_0):1:2*length(cy_0)-1,1));
%                 hold on
%                 plot([cx_smooth(length(cy_0):1:2*length(cy_0)-1,1) cx_smooth(length(cy_0):1:2*length(cy_0)-1,1)-MARGIN*Normals(length(cy_0):1:2*length(cy_0)-1,1)]', [cy_smooth(length(cy_0):1:2*length(cy_0)-1,1) cy_smooth(length(cy_0):1:2*length(cy_0)-1,1)-MARGIN*Normals(length(cy_0):1:2*length(cy_0)-1,2)]');
%                 hold on
%                 plot(sample_x, sample_y, 'ro')
%                 hold on
%                 plot(inner_sample_x, inner_sample_y, 'rx')
%                 axis equal
%                 hold on
%                 plot(hull_x(K), hull_y(K), 'g-')
%                 hold on
%                 axis([340 570 170 370])
%                 close
        
            % Fibril Tool : Crop part of nxx, nxy, and nyy within ROI
                segment_nxx = roipoly(nxx, segment_x, segment_y).*nxx;
                segment_nxx(segment_nxx==0) = NaN;
                segment_nxy = roipoly(nxy, segment_x, segment_y).*nxy;
                segment_nxy(segment_nxy==0) = NaN;
                segment_nyy = roipoly(nyy, segment_x, segment_y).*nyy;
                segment_nyy(segment_nyy==0) = NaN;
        
            % Fibril Tool : Measure the mean value of nxx, nxy, and nyy in ROI
                xx = nanmean(sort(segment_nxx(:)));
                xy = nanmean(sort(segment_nxy(:)));
                yy = nanmean(sort(segment_nyy(:)));

            % Fibril Tool: Eigenvalues and eigenvector of texture tensor
                m = (xx + yy)/2;
                d = (xx - yy)/2;
                v1 = m + sqrt(xy * xy + d * d);
                v2 = m - sqrt(xy * xy + d * d);

            % Fibril Tool : Direction/Orientation rel. to image frame
                tn_abs = - atan((v2 - xx) / xy);
                orient_abs = rad2deg(tn_abs);
        
            % Fibril Tool : Anisotropy
                anisotropy = abs((v1-v2) / 2 / m);
        
            % Fibril Tool : Direction/Orientation rel. to contour normal
                n_vector = [-Normals(index,1) -Normals(index,2) 0];
                orient_abs_vector = [anisotropy*cos(tn_abs) -anisotropy*sin(tn_abs) 0];
                tn_rel = dot(n_vector, orient_abs_vector)/(norm(n_vector)*norm(orient_abs_vector));
                orient_rel = acosd(tn_rel);
                aniso_norm = abs(dot(n_vector/norm(n_vector), orient_abs_vector/norm(orient_abs_vector)))*norm(orient_abs_vector);
        
            % Option to display Fibril Tool measurements in analysis box
            % for each query point
%                 imagesc(segment_ROI)
%                 colormap gray
%                 hold on
%                 plot(cx_smooth(length(cy_0):1:2*length(cy_0)-1,1), cy_smooth(length(cy_0):1:2*length(cy_0)-1,1));
%                 hold on
%                 plot([cx_sgfilt(index) cx_sgfilt(index)-MARGIN*Normals(index,1)], [cy_sgfilt(index) cy_sgfilt(index)-MARGIN*Normals(index,2)], 'r')
%                 hold on
%                 plot([cx_sgfilt(index) cx_sgfilt(index)+100*anisotropy*cos(tn_abs)], [cy_sgfilt(index) cy_sgfilt(index)-100*anisotropy*sin(tn_abs)], 'g') 
                segment_ROI(segment_ROI == 0) = NaN;    
%                 imagesc(segment_ROI)
%                 colormap gray
%                 hold on
%                 plot(cx_smooth(length(cy_0):1:2*length(cy_0)-1,1), cy_smooth(length(cy_0):1:2*length(cy_0)-1,1));
%                 hold on
%                 plot([cx_smooth(length(cy_0):1:2*length(cy_0)-1,1) cx_smooth(length(cy_0):1:2*length(cy_0)-1,1)-MARGIN*Normals(length(cy_0):1:2*length(cy_0)-1,1)]', [cy_smooth(length(cy_0):1:2*length(cy_0)-1,1) cy_smooth(length(cy_0):1:2*length(cy_0)-1,1)-MARGIN*Normals(length(cy_0):1:2*length(cy_0)-1,2)]');
%                 hold on
%                 plot(sample_x, sample_y, 'ro')
%                 hold on
%                 plot(inner_sample_x, inner_sample_y, 'rx')
%                 axis equal
%                 hold on
%                 plot(hull_x(K), hull_y(K), 'g-')
%                 hold on
%                 axis([cx_smooth(index)-30 cx_smooth(index)+30 cy_smooth(index)-30 cy_smooth(index)+30])
%                 axis ij
%                 plot([cx_smooth(index) cx_smooth(index)+100*anisotropy*cos(tn_abs)], [cy_smooth(index) cy_smooth(index)-100*anisotropy * sin(tn_abs)], '-', 'LineWidth', 5)
%                 hold off

            %% local LEC determination
                inside_list = [];
                inside = 0;
                R = 1;
                while inside < 2
                    xc = cx_smooth(index,1)-(R)*Normals(index,1);
                    yc = cy_smooth(index,1)-(R)*Normals(index,2);
                    % Option to plot fitted circle
%                     plot(xc, yc, 'rx')
%                     hold on
%                     plot(R*cos(th)+xc, R*sin(th)+yc, 'r-');
%                     hold on
                    inside = sum(inpolygon(cx_smooth, cy_smooth, R*cos(th)+xc, R*sin(th)+yc));
                    inside_list = [inside_list inside];
                    R = R+1;
                end
                localLEC_list = [localLEC_list length(inside_list)];

            % Collect data into smoothed vectors    
            Anisotropy = [Anisotropy anisotropy];
            Orientation = [Orientation tn_rel]; %tn_rel = 1 --> anisotropy || normal; tn_rel ~ 0 --> anisotropy perpendicular to normal
            Aniso_Norm = [Aniso_Norm aniso_norm]; %normal component of anisotropy (normal to contour)

        end
        
        %% Collect measurements into vectors and smooth data
        Curv2 = (CrossProd./abs(CrossProd)).*Curv;
        Curv2 = smooth(Curv2(:,3));
        Anisotropy2 = smooth(Anisotropy);
        Orientation2 = smooth(abs(Orientation));
        localLEC2 = smooth(localLEC_list);
        Aniso_Norm2 = smooth(Aniso_Norm);
        data_single{i} = [cx_0 cy_0 Curv2 Normals(length(cy_0):1:2*length(cy_0)-1,1) Normals(length(cy_0):1:2*length(cy_0)-1,2) Anisotropy2 Orientation2 localLEC2 Aniso_Norm2];
end
end

