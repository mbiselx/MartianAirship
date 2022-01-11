function plot_PotentialField(E, isoval, lat, lon, alt)
%PLOT_POTENTIALFIELD Summary of this function goes here


shading flat

alphamap('rampdown')
alphamap('increase',.3)
colormap(flipud(copper))

isosurface(E, isoval)
% patch(isocaps(E, isoval), 'FaceColor','interp', 'EdgeColor','none', 'FaceAlpha','interp');
patch(isocaps(E, isoval), 'FaceColor','interp', 'EdgeColor','none');

view(3)
axis equal tight

% alpha('color')

lightangle(45,30);
lighting gouraud

c = colorbar('southoutside');
c.Label.String = 'Potential [a. u.]';

[Y, X, Z]      = size(E);

yf = scalefactor_ROI(lat);
y_tix_sp = yf*Y/range(lat); % [px/°]
yticks((0:y_tix_sp:Y));
yticklabels(min(lat) :yf: max(lat))
ylabel("latitude [°]")

xf = scalefactor_ROI(lon);
x_tix_sp = xf*X/range(lon); % [px/°]
xticks((0:x_tix_sp:X));
xticklabels(min(lon) :xf: max(lon))
xlabel("longitude [°]")

z_tix_sp = 7;
zticks(1:z_tix_sp:Z);
zticklabels(min(alt) + (1:z_tix_sp:Z)*round(range(alt)/Z))
zlabel("altitude [m]")

end
