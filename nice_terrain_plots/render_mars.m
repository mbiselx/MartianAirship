%% paternoster

clc
close all
addpath("functions")


%% define region of interest
roi_lat = [-14, -12];
roi_lon = [-62, -64];
roi_lat = [-12.5, -9.5];
roi_lon = [-71.5, -68.5];


%% load z data

if ~exist('heightmap', 'var') || isempty(heightmap)
    disp("loading height map")
    heightmap = imread("./data/Mars_MGS_MOLA_DEM_mosaic_global_463m.tif");
    mpp = 463;  % resolution is 463 meters per pixel
end

Z = extract_ROI(heightmap, roi_lat, roi_lon);

%% load texture data

if ~exist('texturemap', 'var') || isempty(texturemap)
    disp("loading texture map")
    texturemap = imread("./data/mars45s315.png");

end

correction_val_lat = -.22;   % HACK : to fix discrepancy
correction_val_lon =  .03;   % HACK : needs to be hand-tuned for each ROI

C = extract_local_ROI(texturemap, ...
                      roi_lat + correction_val_lat, ...
                      roi_lon + correction_val_lon, ...
                      [-90 0], [-90 0]);

%% plot terrain(requires image processing toolbox)

figure()
surf_ROI_texture(Z, C, mpp, roi_lat, roi_lon)
% axis off
