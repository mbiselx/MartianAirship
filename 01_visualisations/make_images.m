%% paternoster

clc
close all
addpath("../00_functions/topography/")
data_path = '../00_data/';

%% define region of interest
roi_lat = [-16, -3];
roi_lon = [-86, -54];


%% load z data

if ~exist('heightmap', 'var') || isempty(heightmap)
    disp("loading height map")
    heightmap   = imread([data_path, 'elevation_maps/Mars_MGS_MOLA_DEM_mosaic_global_463m.tif']);
    mpp         = 463;  % resolution is 463 meters per pixel
end

Z = extract_ROI(heightmap, roi_lat, roi_lon);

%% load texture data

if ~exist('texturemap1', 'var') || isempty(texturemap1)
    disp("loading texture map")
    texturemap1  = imread([data_path, 'texture_maps/mars45s315.png']);
end

correction_val_lat = -.22;   % HACK : to fix discrepancy
correction_val_lon =  .03;   % HACK : needs to be hand-tuned for each ROI

C = extract_ROI(texturemap1, ...
                      roi_lat + correction_val_lat, ...
                      roi_lon + correction_val_lon, ...
                      [-90 0], [-90 0]);

%%
rect_lat = [-13, - 8];
rect_lon = [-80, -65];

fig1 = figure(1);
tiledlayout(2,1)
nexttile
    h1 = show_ROI(C, roi_lat, roi_lon);
    r1 = ROI_box(C, roi_lat, roi_lon, rect_lat, rect_lon);
nexttile
    colormap('jet')
    h2 = show_ROI(double(Z), roi_lat, roi_lon, true);
    r2 = ROI_box(Z, roi_lat, roi_lon, rect_lat, rect_lon);
    c = colorbar('eastoutside');
    c.Label.String = 'MOLA altitude [°]';



