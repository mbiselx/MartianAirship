clc 
clear 

addpath("..")
set_path
% data_path = '00_data/';
data_path = '../00_data/';

airship_generator;
mars_generator;

clear
data_path = '00_data/';

load([data_path, 'airship.mat'])
load([data_path, 'mars.mat'])