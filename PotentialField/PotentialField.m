%% paternoster

clc
close all
% clear
addpath("functions")


%% load data

if ~exist('heightmap', 'var') || isempty(heightmap)
    disp("loading height map")
    heightmap = imread("../data/Mars_MGS_MOLA_DEM_mosaic_global_463m.tif");
end
mpp = 463;  % resolution is 463 meters per pixel
%imshow(heightmap)


%% select region of interest
% roi_lat = [-17,  -9]; % [-17, -3]
% roi_lon = [-73, -56]; % [-80, -56]
roi_lat = [-14, -12]; 
roi_lon = [-62, -64]; 
% roi_lat = [-13, -12]; 
% roi_lon = [-62, -63]; 
Z = extract_ROI(heightmap, roi_lat, roi_lon);
[Y, X]  = size(Z);

goal = [-12.7, -62.7, -1000]; % lat/lon/alt
goal_idx(1) = (goal(1) - min(roi_lat))/range(roi_lat)*size(Z,2);
goal_idx(2) = (goal(2) - min(roi_lon))/range(roi_lon)*size(Z,1);

disp("Region of interest extracted. Starting calculation")

%% display ROI map
figure(1)
colormap jet
plot_ROI(Z, roi_lat, roi_lon);
c = colorbar('eastoutside');
c.Label.String = 'altitude [°]';
title("Region of Interest")


%% display altitude
figure(2)
colormap jet
% colormap copper
surf_ROI(Z, Z, mpp, roi_lat, roi_lon);
rotate3d on
c = colorbar('eastoutside');
c.Label.String = 'altitude [m]';


%% display slope
figure(3)
colormap jet
surf_ROI(Z, get_slope(Z,mpp), mpp, roi_lat, roi_lon);
rotate3d on
c = colorbar('eastoutside');
c.Label.String = 'slope [°]';


%% for reference

if ~exist('texturemap', 'var') || isempty(texturemap)
    disp("loading texture map")
    texturemap = imread("../data/mars45s315.png");
end

correction_val = -.2;
lat_idx = round((-roi_lat-correction_val)/90 * size(texturemap,1));
lon_idx = round((90 + roi_lon)/90 * size(texturemap,2));
vis = texturemap(min(lat_idx):max(lat_idx), min(lon_idx):max(lon_idx), :);
disp("Texture extracted. Starting calculation")

figure(9), clf
surf_ROI_texture(Z, vis, mpp, roi_lat, roi_lon)
title("Terrain visualisation")
rotate3d on

hold on
plot3(mpp*X*(goal(2)-min(roi_lon))/range(roi_lon), mpp*Y*(max(roi_lat)-goal(1))/range(roi_lat), goal(3), 'rx', ...
    'MarkerSize', 10, 'LineWidth', 2)




%% calculate obstacle potential

% ZZ = flip(Z,1);
% 
% Alow    = min(ZZ, [], 'all');
% A       = ceil(range(ZZ, 'all')/mpp);
% z_idx   = max(1, ceil((ZZ-Alow)/mpp));
% goal_idx(3) = (goal(3) - Alow)/range(Z, 'all')*A;
% 
% E_obs = zeros(X, Y, A);
% 
% SD = 7000;
% for x = 1:X
%     for y = 1:Y 
%         E_obs(x, y, 1:z_idx(x,y)) = Inf;
%         E_obs(x, y, z_idx(x,y):A) = max(0, -log((0:(A-z_idx(x,y)))*mpp/SD));
% 
%     end
% end
% E_obs = smooth3(E_obs);
% 
% isoval = 1;
% 
% figure(4), clf
% shading flat
% alphamap('vup')
% % alphamap('rampup')
% alphamap('rampdown')
% alphamap('increase',.3)
% colormap jet
% colormap(flipud(copper))
% isosurface(E_obs, isoval)
% patch(isocaps(E_obs, isoval), 'FaceColor','interp', 'EdgeColor','none', 'FaceAlpha','interp');
% view(3)
% alpha('color')
% axis equal tight
% c = colorbar('southoutside');
% c.Label.String = 'Potential [a. u.]';
% title("Potential Field due to Terrain")
% 
% hold on,
% plot3(goal_idx(2), goal_idx(1), goal_idx(3), 'rx', ...
%     'MarkerSize', 10, 'LineWidth', 2)
% 
% lightangle(45,30);
% lighting gouraud
% 
% y_tix_sp = Y/range(roi_lat)*.2; % [px/°]
% yticks((0:y_tix_sp:Y));
% yticklabels(linspace(min(roi_lat), max(roi_lat), numel((0:y_tix_sp:Y))))
% ylabel("latitude [°]")
% 
% x_tix_sp = X/range(roi_lon)*.2; % [px/°]
% xticks((0:x_tix_sp:X));
% xticklabels(linspace(min(roi_lon), max(roi_lon), numel((0:x_tix_sp:X))))
% xlabel("longitude [°]")
% 
% x_tix_sp = 7;
% zticks(1:x_tix_sp:A);
% zticklabels((1:x_tix_sp:A)*mpp + Alow)
% zlabel("altitude [m]")
% 
% 
% 
% %% goal potential
% 
% E_goal = zeros(X, Y, A);
% for x = 1:X
%     for y = 1:Y 
%         for a = 1:A
%         E_goal(x,y,a) = vecnorm([x,y,a] - goal_idx);
% %         E_goal(x,y,a) = vecnorm([x,y,a] - goal_idx).^2;
%         end
%     end
% end
% E_goal = smooth3(E_goal);
% E_gp = E_goal/45;
% 
% isoval = 1;
% % isoval = 2000;
% figure(5), clf
% shading flat
% % alphamap('vup')
% alphamap('rampdown')
% alphamap('increase',.3)
% colormap jet
% colormap(flipud(copper))
% isosurface(E_gp, isoval)
% patch(isocaps(E_gp, isoval), 'FaceColor','interp', 'EdgeColor','none', 'FaceAlpha','interp');
% view(3)
% alpha('color')
% axis equal tight
% c = colorbar('southoutside');
% c.Label.String = 'Potential [a. u.]';
% title("Potential Field leading to goal")
% 
% hold on,
% plot3(goal_idx(2), goal_idx(1), goal_idx(3), 'rx', ...
%     'MarkerSize', 10, 'LineWidth', 2)
% 
% lightangle(45,30);
% lighting gouraud
% 
% y_tix_sp = Y/range(roi_lat)*.2; % [px/°]
% yticks((0:y_tix_sp:Y));
% yticklabels(linspace(min(roi_lat), max(roi_lat), numel((0:y_tix_sp:Y))))
% ylabel("latitude [°]")
% 
% x_tix_sp = X/range(roi_lon)*.2; % [px/°]
% xticks((0:x_tix_sp:X));
% xticklabels(linspace(min(roi_lon), max(roi_lon), numel((0:x_tix_sp:X))))
% xlabel("longitude [°]")
% 
% x_tix_sp = 7;
% zticks(1:x_tix_sp:A);
% zticklabels((1:x_tix_sp:A)*mpp + Alow)
% zlabel("altitude [m]")
% 
% %% combine the two 
% 
% E = smooth3(E_obs + E_goal/50)/1.3;
% 
% isoval = 1;
% 
% figure(6), clf
% shading flat
% % alphamap('vup')
% % alphamap('rampup')
% alphamap('rampdown')
% alphamap('increase',.3)
% colormap jet
% colormap(flipud(copper))
% isosurface(E, isoval)
% patch(isocaps(E, isoval), 'FaceColor','interp', 'EdgeColor','none', 'FaceAlpha','interp');
% view(3)
% alpha('color')
% axis equal tight
% c = colorbar('southoutside');
% c.Label.String = 'Potential [a. u.]';
% title("Combined Potential Field")
% 
% hold on,
% plot3(goal_idx(2), goal_idx(1), goal_idx(3), 'rx', ...
%     'MarkerSize', 10, 'LineWidth', 2)
% 
% lightangle(45,30);
% lighting gouraud
% 
% y_tix_sp = Y/range(roi_lat)*.2; % [px/°]
% yticks((0:y_tix_sp:Y));
% yticklabels(linspace(min(roi_lat), max(roi_lat), numel((0:y_tix_sp:Y))))
% ylabel("latitude [°]")
% 
% x_tix_sp = X/range(roi_lon)*.2; % [px/°]
% xticks((0:x_tix_sp:X));
% xticklabels(linspace(min(roi_lon), max(roi_lon), numel((0:x_tix_sp:X))))
% xlabel("longitude [°]")
% 
% x_tix_sp = 7;
% zticks(1:x_tix_sp:A);
% zticklabels((1:x_tix_sp:A)*mpp + Alow)
% zlabel("altitude [m]")
% 





%% plot volume
% close(figure(5))
% pcolor3(E_obs)
% % pcolor3(E_obs, 'alphalim', [0, .5])
% colormap(flipud(gray))
% axis equal tight 
% y_tix_sp = Y/range(roi_lat)*.2; % [px/°]
% yticks((0:y_tix_sp:Y));
% yticklabels(linspace(max(roi_lat), min(roi_lat), numel((0:y_tix_sp:Y))))
% ylabel("latitude [°]")
% 
% x_tix_sp = X/range(roi_lon)*.2; % [px/°]
% xticks((0:x_tix_sp:X));
% xticklabels(linspace(min(roi_lon), max(roi_lon), numel((0:x_tix_sp:X))))
% xlabel("longitude [°]")
% 
% x_tix_sp = 7;
% zticks(1:x_tix_sp:A);
% zticklabels((1:x_tix_sp:A)*mpp + Alow)
% zlabel("altitude [m]")
% 
% c = colorbar('eastoutside');
% c.Label.String = 'potential [°]';



