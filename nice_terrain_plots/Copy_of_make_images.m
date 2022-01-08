%% paternoster

clc
close all
addpath("functions")


%% define region of interest
roi_lat = [-16, -3];
roi_lon = [-86, -54];


%% load z data

if ~exist('heightmap', 'var') || isempty(heightmap)
    disp("loading height map")
    heightmap = imread("../data/Mars_MGS_MOLA_DEM_mosaic_global_463m.tif");
    mpp = 463;  % resolution is 463 meters per pixel
end

Z = extract_ROI(heightmap, roi_lat, roi_lon);

%% load texture data

if ~exist('texturemap', 'var') || isempty(texturemap)
    disp("loading texture map")
    texturemap = imread("../data/mars45s315.png");
end

correction_val_lat = -.22;   % HACK : to fix discrepancy
correction_val_lon =  .03;   % HACK : needs to be hand-tuned for each ROI

C = extract_local_ROI(texturemap, ...
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
    r1 = annotate_ROI(C, roi_lat, roi_lon, rect_lat, rect_lon);
nexttile
    colormap('jet')
    h2 = plot_ROI(double(Z), roi_lat, roi_lon);
    r2 = annotate_ROI(Z, roi_lat, roi_lon, rect_lat, rect_lon);
    c = colorbar('eastoutside');
    c.Label.String = 'MOLA altitude [°]';



