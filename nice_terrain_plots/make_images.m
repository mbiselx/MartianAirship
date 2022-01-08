%% paternoster

clc
close all
addpath("functions")


%% define region of interest
% roi_lat = [-13, -8];
% roi_lon = [-80, -65];
roi_lat = [-20.35, -0];
roi_lon = [-90, -50];


%% load z data

if ~exist('heightmap', 'var') || isempty(heightmap)
    disp("loading height map")
    heightmap = imread("../data/Mars_MGS_MOLA_DEM_mosaic_global_463m.tif");
    mpp = 463;  % resolution is 463 meters per pixel
end

Z = extract_ROI(heightmap, roi_lat, roi_lon);

%% load texture data

if ~exist('texturemap1', 'var') || isempty(texturemap1)
    disp("loading texture map 1")
    texturemap1 = imread("../data/mars45s315.png");
end

correction_val_lat = -.22;   % HACK : to fix discrepancy
correction_val_lon =  .03;   % HACK : needs to be hand-tuned for each ROI

% % C1 = extract_local_ROI(texturemap1, ...
% %                       roi_lat + correction_val_lat, ...
% %                       roi_lon + correction_val_lon, ...
% %                       [-90 -.1], [-90 0]);
C1 = extract_local_ROI(texturemap1, ...
                      roi_lat, ...
                      roi_lon, ...
                      [-90 0], [-90 0]);

%% load texture data 2

if ~exist('texturemap2', 'var') || isempty(texturemap2)
    disp("loading texture map 2")
    texturemap2 = imread("../data/016vallesmarineris.jpg");
end

correction_val_lat = -.22;   % HACK : to fix discrepancy
correction_val_lon =  .03;   % HACK : needs to be hand-tuned for each ROI

% C2 = extract_local_ROI(texturemap2, ...
%                       roi_lat, ...
%                       roi_lon, ...
%                       [-20 0], [-90 -50]);
C2 = texturemap2;

%%
rect_lat = [-13, - 8];
rect_lon = [-80, -65];

fig1 = figure(1);
tiledlayout(2,1)
nexttile
    h1 = show_ROI(C1, roi_lat, roi_lon);
%     r1 = annotate_ROI(C1, roi_lat, roi_lon, rect_lat, rect_lon);
nexttile
    h2 = show_ROI(C2, roi_lat, roi_lon);



