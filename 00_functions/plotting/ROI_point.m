function h = ROI_point(img, mpp, roi_lat, roi_lon, roi_alt, point, style)
%ANNOTATE_ROI Summary of this function goes here
%   Detailed explanation goes here

[Y, X, Z] = size(img);

lat_idx = (1-(point(1) - min(roi_lat))/range(roi_lat)) * mpp * Y;
lon_idx =    (point(2) - min(roi_lon))/range(roi_lon)  * mpp * X;
% alt_idx =    (point(3) - min(roi_alt))/range(roi_alt)  * mpp * Z;
alt_idx = point(3);

if ~exist('style', 'var') || isempty(style)
    style = 'rx';
end

h = plot3(lon_idx, lat_idx, alt_idx, style, 'MarkerSize', 10, 'LineWidth', 2);

end

