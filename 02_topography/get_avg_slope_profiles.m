%% paternoster

clc
close all
clear

%% load data

heightmap = imread("../00_data/elevation_maps/Mars_MGS_MOLA_DEM_mosaic_global_463m.tif");
mpp = 463;  % resolution is 463 meters per pixel
%imshow(heightmap)

% select region of interest
roi = [[-80,-3]; [-56, -17]]; % rectagle defined by upper lon/lat and lower lon/lat in °
roi_idx = round([(-roi(:,2)+90)/180, (roi(:,1)+180)/360].*size(heightmap));
Z = double(heightmap(min(roi_idx(:,1)):max(roi_idx(:,1)), min(roi_idx(:,2)):max(roi_idx(:,2))));
imagesc(Z)
colormap gray
axis equal tight off

% set appropriate scale
x = mpp*(1:size(Z,2));
y = mpp*(1:size(Z,1));

%% calculate slope
% get slope
[dZx, dZy] = gradient(Z);       % [m / pix]
dZ = sqrt(dZx.^2 + dZy.^2)/mpp; % [m / m]
slope = atand(dZ);              % [°]

% plot 
figure
subplot(2,1,1)
    imagesc(Z)
    shading flat
    colormap jet
    c = colorbar('eastoutside');
    c.Label.String = 'Elevation [m]';
    axis equal tight off
subplot(2,1,2)
    imagesc(slope)
    shading flat
    colormap jet
    c = colorbar('eastoutside');
    c.Label.String = 'Slope [°]';
    axis equal tight off

%% calculate slope distribution

% categorize  terrain
flat_terrain = (slope < 5);

figure
    histogram2(slope(~flat_terrain), Z(~flat_terrain), 'DisplayStyle', 'tile');
    xlabel('slope [°]'), ylabel('altitude [m]')
    colormap jet
    c = colorbar('eastoutside', 'Ticks', [100, 2800], 'TickLabels', {'-', '+'});
    c.Label.String = 'counts';
    axis tight
    title("Slope distribution with height")

%% model the canyon slopes

s = [ 5, -3000;
     17, -1100;
     30,  3300;
      5,  4000];

hold on % add model to histogram 
l = plot(s(:,1), s(:,2), 'k', 'LineWidth', 4);
legend(l, "model")

dh = 100;
h = min(s(:,2)):dh:max(s(:,2));
ss = interp1(s(:,2), s(:,1), h); 
xx = cumsum([0, dh./tand(ss)]);

figure
    a = area(xx, [h, h(end)+dh], min(h)-800);
    a(1).FaceColor = [0.8500 0.3250 0.0980];
    xlabel('[m]'), ylabel('altitude [m]')
    axis equal tight
    title("average canyon slope profile")


%% balloon-accessible areas

max_alt = -3000; % [m] maximum altitude the balloon can hover at
SF      =   200; % [m] safety height to keep above ground level

% select region of interest (ROI)
roi = [[-73,-9]; [-56, -17]]; % rectagle defined by upper lon/lat and lower lon/lat in °
roi_idx = round([(-roi(:,2)+90)/180, (roi(:,1)+180)/360].*size(heightmap));
Z = double(heightmap(min(roi_idx(:,1)):max(roi_idx(:,1)), min(roi_idx(:,2)):max(roi_idx(:,2))));

% select only low altitudes in region of interest
Zlow = max_alt*ones(size(Z));
low  = (Z < max_alt);
Zlow(low) = Z(low);

% get slope in ROI
[dZx, dZy] = gradient(Z);                   % [m / pix]
slope = atand(sqrt(dZx.^2 + dZy.^2)/mpp);   % [°]
slope_low = zeros(size(Z));
slope_low(low) = slope(low); % [°]

% plot balloon-accessible ROI
figure
    subplot(2,1,1)
        imagesc(Zlow)
        shading flat
        colormap jet
        c = colorbar('eastoutside');
        c.Label.String = 'Elevation [m]';
        axis equal tight off
    subplot(2,1,2)
        imagesc(slope_low)
        shading flat
        colormap jet
        c = colorbar('eastoutside');
        c.Label.String = 'Slope [°]';
        axis equal tight off
    sgtitle("balloon-accessible areas")


% categorize terrain
low_flat = (slope_low < 5);
figure
    histogram2(slope_low(~low_flat), Zlow(~low_flat), 'DisplayStyle', 'tile');
    xlabel('slope [°]'), ylabel('altitude [m]')
    colormap jet
    c = colorbar('eastoutside', 'Ticks', [500, 10000], 'TickLabels', {'-', '+'});
    c.Label.String = 'counts';
    axis tight
    title("low slope / height distribution")

% model the canyon slopes
s = [ 5, -4850
     11, -4650;
     24, -4200;
     28, -3000];

hold on % add model to histogram 
l = plot(s(:,1), s(:,2), 'k', 'LineWidth', 4);
legend(l, "model")

dh = 100;
h = min(s(:,2)):dh:max(s(:,2));
ss = interp1(s(:,2), s(:,1), h); 
xx = cumsum([0, dh./tand(ss)]);

figure
a = area(xx, [h, h(end)+dh], min(h)-100);
    a(1).FaceColor = [0.8500 0.3250 0.0980];
    xlabel('[m]'), ylabel('altitude [m]')
    axis equal tight
    title("estimated low canyon slope profile")

%%
% %%
% [X, Y] = meshgrid(x, y);
%  
% figure('Name', 'Height Map')
% surf(X, Y, Z)
% rotate3d on
% shading flat
% colormap jet
% c = colorbar('southoutside');
% c.Label.String = 'Elevation [m]';
% axis equal tight off
% 
% 
% %%
% figure('Name', 'Slope Map')
% surf(X, Y, slope)
% rotate3d on
% shading flat
% colormap jet
% c = colorbar('southoutside');
% c.Label.String = 'Slope [°]';
% axis equal tight off


%% 
% figure()
% plot(Y(:,1), Z(:,floor(end/2))), hold on
% plot(Y(:,1), 1000*dZ(:,floor(end/2)))
% axis('equal')
% grid on


%%
disp("done")