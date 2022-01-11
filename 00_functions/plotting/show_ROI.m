function h = show_ROI(img, lat, lon, scale)
%PLOT_ROI Summary of this function goes here
%   Detailed explanation goes here

    if ~exist('scale', 'var') || isempty(scale) || ~scale 
        h = image(img);
    else
        h = imagesc(img);
    end

    rectangle;                            % for aesthetics, a rectagle that surrounds the plot
    
    yf = scalefactor_ROI(lat);
    y_tix_sp = yf*size(img,1)/range(lat); % [px/°]
    yticks(0:y_tix_sp:size(img,1));
    yticklabels(max(lat) :-yf: min(lat))
    ylabel("latitude [°]")
    
    xf = scalefactor_ROI(lon);
    x_tix_sp = xf*size(img,2)/range(lon); % [px/°]
    xticks(0:x_tix_sp:size(img,2));
    xticklabels(min(lon) :xf: max(lon))
    xlabel("longitude [°]")
    
    axis equal tight
    grid on

end

