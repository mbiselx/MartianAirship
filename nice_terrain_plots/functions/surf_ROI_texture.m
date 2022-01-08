function surf_ROI_texture(Z, vis, mpp, lat, lon)
%PLOT_ROI_TEXTURE Summary of this function goes here

    [Y, X]      = size(Z);
    [XX, YY]    = meshgrid(mpp*(1:size(Z,2)), mpp*(1:size(Z,1)));
    [I, map]    = rgb2ind(vis,.1);
    warp(XX, YY, Z, I, map);
    
    [xlo, xhi]  = bounds(XX, "all");
    [ylo, yhi]  = bounds(YY, "all");
    zlo         = min(Z, [], 'all')-100;

    patch([XX(  1,  :), xhi, xlo], [YY(  1,  :), ylo, ylo], [Z(  1,  :), zlo, zlo], [0 0 0])
    patch([XX(end,  :), xhi, xlo], [YY(end,  :), yhi, yhi], [Z(end,  :), zlo, zlo], [0 0 0])
    patch([XX(  :,  1); xlo; xlo], [YY(  :,  1); yhi; ylo], [Z(  :,  1); zlo; zlo], [0 0 0])
    patch([XX(  :,end); xhi; xhi], [YY(  :,end); yhi; ylo], [Z(  :,end); zlo; zlo], [0 0 0])
    patch([xlo, xlo, xhi, xhi], [ylo, yhi, yhi, ylo], [zlo, zlo, zlo, zlo], [0 0 0])
    
    yf = scalefactor(lat);
    y_tix_sp = yf*Y/range(lat);        % [px/°]
    yticks(mpp*(0:y_tix_sp:Y));
    yticklabels(max(lat) :-yf: min(lat))
    ylabel("latitude [°]")
    
    xf = scalefactor(lon);
    x_tix_sp = xf*X/range(lon);         % [px/°]
    xticks(mpp*(0:x_tix_sp:X));
    xticklabels(min(lon) :xf: max(lon))
    xlabel("longitude [°]")
    
    zlabel("altitude [m]")
    
    axis equal tight

end

