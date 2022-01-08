function r = annotate_ROI(img, roi_lat, roi_lon, an_lat, an_lon)
%ANNOTATE_ROI Summary of this function goes here
%   Detailed explanation goes here

[Y, X, Z] = size(img);

lat_idx = (1-(an_lat - min(roi_lat))/range(roi_lat)) * Y;
lon_idx =    (an_lon - min(roi_lon))/range(roi_lon)  * X;

r = rectangle('Position',[min(lon_idx), min(lat_idx), range(lon_idx), range(lat_idx)], ...
              'EdgeColor', 'k', 'LineWidth', 2);

end

