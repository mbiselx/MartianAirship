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
roi_lat = [-15, -11]; 
roi_lon = [-59, -67]; 
% roi_lat = [-14, -12]; 
% roi_lon = [-62, -64]; 
% roi_lat = [-13, -12]; 
% roi_lon = [-61.5, -63]; 
% roi_lat = [-13, -12]; 
% roi_lon = [-62, -63]; 
Z = extract_ROI(heightmap, roi_lat, roi_lon);
[Y, X]  = size(Z);

% goal = [-12.7, -62.7, -1000]; % lat/lon/alt
goal = [-12.5, -62.2, 2000]; % lat/lon/alt
goal_idx(1) = (goal(1) - min(roi_lat))/range(roi_lat)*Y;
goal_idx(2) = (goal(2) - min(roi_lon))/range(roi_lon)*X;

disp("Region of interest extracted. Starting calculation")

%% display ROI map
% figure(1)
% colormap jet
% plot_ROI(Z, roi_lat, roi_lon);
% c = colorbar('eastoutside');
% c.Label.String = 'altitude [°]';
% title("Region of Interest")
% 
% 
% %% display altitude
% figure(2)
% colormap jet
% surf_ROI(Z, Z, mpp, roi_lat, roi_lon);
% rotate3d on
% c = colorbar('eastoutside');
% c.Label.String = 'altitude [m]';
% 
% 
% %% display slope
% figure(3)
% colormap jet
% surf_ROI(Z, get_slope(Z,mpp), mpp, roi_lat, roi_lon);
% rotate3d on
% c = colorbar('eastoutside');
% c.Label.String = 'slope [°]';


%% for reference

if ~exist('texturemap', 'var') || isempty(texturemap)
    disp("loading texture map")
    texturemap = imread("../data/mars45s315.png");
end

correction_val_lat = -.2;   % HACK
correction_val_lon = .03;   % HACK
lat_idx = round((-roi_lat-correction_val_lat)/90 * size(texturemap,1));
lon_idx = round((90 + roi_lon + correction_val_lon)/90 * size(texturemap,2));
vis = texturemap(min(lat_idx):max(lat_idx), min(lon_idx):max(lon_idx), :);
disp("Texture extracted. Starting calculation")

figure(4), clf
surf_ROI_texture(Z, vis, mpp, roi_lat, roi_lon)
title("Terrain visualisation")
rotate3d on

hold on
plot3(mpp*X*(goal(2)-min(roi_lon))/range(roi_lon), mpp*Y*(max(roi_lat)-goal(1))/range(roi_lat), goal(3), 'rx', ...
    'MarkerSize', 10, 'LineWidth', 2)


return

%% calculate obstacle potential

ZZ = flip(Z,1);

[Al, Ah]    = bounds(ZZ, 'all');
A           = ceil(range(ZZ, 'all')/mpp);
z_idx       = max(1, ceil((ZZ-Al)/mpp));
goal_idx(3) = (goal(3) - Al)/range(Z, 'all')*A;

E_obs = zeros(Y, X, A);

SD = 3000;
for x = 1:X
    for y = 1:Y 
        E_obs(y, x, 1:z_idx(y,x)) = Inf;
        E_obs(y, x, z_idx(y,x):A) = max(0, -log((0:(A-z_idx(y,x)))*mpp/SD));

    end
end
E_obs = smooth3(E_obs);

isoval = .01;

figure(5), clf
title("Potential Field due to Terrain")
plot_PotentialField(E_obs, isoval, roi_lat, roi_lon, [Al, Ah])
hold on
plot3(goal_idx(2), goal_idx(1), goal_idx(3), 'rx', ...
    'MarkerSize', 10, 'LineWidth', 2)


%% goal potential

E_goal = zeros(Y, X, A);
for x = 1:X
    for y = 1:Y 
        for a = 1:A
%         E_goal(y,x,a) = vecnorm([y,x,a] - goal_idx);
        E_goal(y,x,a) = vecnorm([y,x,a] - goal_idx).^2;
        end
    end
end
E_goal = smooth3(E_goal);
E_gp = E_goal/14000;

isoval = .05;

figure(6), clf
title("Potential Field leading to goal")
plot_PotentialField(E_gp, isoval, roi_lat, roi_lon, [Al, Ah])
hold on
plot3(goal_idx(2), goal_idx(1), goal_idx(3), 'rx', ...
    'MarkerSize', 10, 'LineWidth', 2)


%% combine the two 

E = smooth3(E_obs + E_goal/14000)/20;
[~, idx] = min(E, [], 'all');
[y, x, a] = ind2sub(size(E), idx);

isoval = .01;

figure(7), clf
title("Potential Field leading to goal")
plot_PotentialField(E, isoval, roi_lat, roi_lon, [Al, Ah])
hold on
plot3(x, y, a, 'gx', ...
    'MarkerSize', 11, 'LineWidth', 2.2)
plot3(goal_idx(2), goal_idx(1), goal_idx(3), 'rx', ...
    'MarkerSize', 10, 'LineWidth', 2)



%% wind potential

v_air = [-2; 5; -1];

E_wind = zeros(Y, X, A);
for x = 1:X
    for y = 1:Y 
        for a = 1:A
        E_wind(y,x,a) = [y,x,a] * v_air;
        end
    end
end
E_wind = smooth3(E_wind/1000);

isoval = .01;

figure(8), clf
title("Potential Field due to wind")
plot_PotentialField(E_wind, isoval, roi_lat, roi_lon, [Al, Ah])
grid on
hold on
plot3(goal_idx(2), goal_idx(1), goal_idx(3), 'rx', ...
    'MarkerSize', 10, 'LineWidth', 2)

%% add wind potential

E_w = smooth3(E + E_wind/100)*1.1;

[e, idx] = min(E_w, [], 'all');
[y, x, a] = ind2sub(size(E_w), idx);

isoval = .01;

figure(9), clf
title("Potential Field leading to goal (including wind)")
plot_PotentialField(E_w, isoval, roi_lat, roi_lon, [Al, Ah])
hold on
plot3(x, y, a, 'gx', ...
    'MarkerSize', 12, 'LineWidth', 2.2)
plot3(goal_idx(2), goal_idx(1), goal_idx(3), 'rx', ...
    'MarkerSize', 10, 'LineWidth', 2)


