function h = surf_ROI(roi_h, roi_color, mpp, lat, lon)
%PLOT_ROI Summary of this function goes here
%   Detailed explanation goes here

    % prepare surface 
    [X, Y] = meshgrid(mpp*(1:size(roi_h,2)), mpp*(1:size(roi_h,1)));
    
    h = surf(X, Y, flip(roi_h,1), flip(roi_color,1));
    shading flat
    
    
    [Y, X] = size(roi_h);
    
    yf = scalefactor_ROI(lat);
    y_tix_sp = Y/range(lat)*yf;        % [px/°]
    yticks(mpp*(0:y_tix_sp:Y));
    yticklabels(min(lat) :yf: max(lat))
    ylabel("latitude [°]")
    
    xf = scalefactor_ROI(lon);
    x_tix_sp = X/range(lon)*xf; % [px/°]
    xticks(mpp*(0:x_tix_sp:X));
    xticklabels(min(lon) :xf: max(lon))
    xlabel("longitude [°]")
    
    zlabel("altitude [m]")
    
    axis equal tight
    grid on



end
