function [ROI] = extract_ROI(img, lat, lon)
%EXTRACT_ROI from a global map, extract a Region Of Interest (ROI)
    
    lat_idx = round(( 90 - lat)/180 * size(img,1));
    lon_idx = round((180 + lon)/360 * size(img,2));
    
    ROI = double(img(min(lat_idx):max(lat_idx), min(lon_idx):max(lon_idx)));

end

