function [anisotropy, orient_abs] = calculate_anisotropy_and_orientation(segment_x, segment_y, nxx, nxy, nyy)
%CALCULATEANISOTROPYANDORIENTATION Summary of this function goes here
%   Detailed explanation goes here    

%% Anisotropy/Orientation Measurements (Fibril Tool)

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
end

