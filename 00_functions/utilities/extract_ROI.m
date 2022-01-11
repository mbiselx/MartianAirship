function [ROI] = extract_ROI(img, varargin)
%EXTRACT_LOCAL_ROI from a map, extract a Region Of Interest (ROI)
% [ROI] = extract_local_ROI(img, roi_lat, roi_lon)
% [ROI] = extract_local_ROI(img, roi_lat, roi_lon, img_lat, img_lon)
    
    
    if nargin < 4
        img_lat = [- 90,  90];
        img_lon = [-180, 180];
    else 
        img_lat = varargin{3};
        img_lon = varargin{4};
    end
    
    lat_idx = round((1 - (varargin{1} - min(img_lat))/range(img_lat)) * size(img,1));
    lon_idx = round(     (varargin{2} - min(img_lon))/range(img_lon)  * size(img,2));

    lat_idx(lat_idx < 1) = 1;
    lon_idx(lon_idx < 1) = 1;
    lat_idx(lat_idx > size(img,1)) = size(img,1);
    lon_idx(lon_idx > size(img,2)) = size(img,2);

    ROI = img(min(lat_idx):max(lat_idx), min(lon_idx):max(lon_idx), :);

end

