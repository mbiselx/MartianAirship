function [ROI] = extract_local_ROI(img, roi_lat, roi_lon, local_lat, local_lon)
%EXTRACT_LOCAL_ROI from a local map, extract a Region Of Interest (ROI)
    
    lat_idx = round((1 - (roi_lat - min(local_lat))/range(local_lat)) * size(img,1));
    lon_idx = round(     (roi_lon - min(local_lon))/range(local_lon)  * size(img,2));

    ROI = img(min(lat_idx):max(lat_idx), min(lon_idx):max(lon_idx), :);

end

