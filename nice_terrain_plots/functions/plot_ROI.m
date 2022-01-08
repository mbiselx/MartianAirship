function h = plot_ROI(roi_img, lat, lon)
%PLOT_ROI Summary of this function goes here
%   Detailed explanation goes here

    h = imagesc(roi_img);
    rectangle
    
    yf = scalefactor(lat);
    y_tix_sp = yf*size(roi_img,1)/range(lat); % [px/°]
    yticks(0:y_tix_sp:size(roi_img,1));
    yticklabels(max(lat) :-yf: min(lat))
    ylabel("latitude [°]")
    
    xf = scalefactor(lon);
    x_tix_sp = xf*size(roi_img,2)/range(lon); % [px/°]
    xticks(0:x_tix_sp:size(roi_img,2));
    xticklabels(min(lon) :xf: max(lon))
    xlabel("longitude [°]")
    
    axis equal tight
    grid on

end

