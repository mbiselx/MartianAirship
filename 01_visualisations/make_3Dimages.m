%% paternoster

clc
close all
addpath("..")
set_path
data_path = '../00_data/';

%% define region of interest
% roi_lat = [-14, -12];
% roi_lon = [-62, -64];
roi_lat = [-12, -13];
roi_lon = [-63, -62];
% roi_lat = [-12.5, -9.5];
% roi_lon = [-71.5, -68.5];


%% load z data

if ~exist('heightmap', 'var') || isempty(heightmap)
    disp("loading height map")
    heightmap   = imread([data_path, 'elevation_maps/Mars_MGS_MOLA_DEM_mosaic_global_463m.tif']);
    mpp         = 463;  % resolution is 463 meters per pixel
end

Z = extract_ROI(heightmap, roi_lat, roi_lon);


%% load texture data

if ~exist('texturemap2', 'var') || isempty(texturemap2)
    disp("loading texture map")
    texturemap2  = imread([data_path, 'texture_maps/016vallesmarineris.jpg']);
end

C = extract_ROI(texturemap2, roi_lat, roi_lon, [-20 0], [-90 -50]);


%% plot terrain(requires image processing toolbox)

figure()
textured_surf_ROI(Z, C, mpp, roi_lat, roi_lon)
% axis off
