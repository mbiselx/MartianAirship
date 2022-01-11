function [varargout] = readMCDdata(path)
%READMCDDATA Summary of this function goes here
%   [data, names, lat, lon, alt, t, date] = readMCDdata(path)
%       param:      path    : path to the directory containting the .csv data
%                               e.g. path = './data/scenario1'
%       returns:    data    : a cell array containing the data for one MCD
%                               variable per cell
%                   names   : a cell array containing the names of the
%                               variables stored in the 'data' cell array
%                   lat     : a vector containing the latitude range
%                   lon     : a vector containing the longitude range
%                   alt     : a vector containing the altitude range
%                   t       : a vector containing the time range
%                   date    : a vector containing the dates

% $Author: Michael Biselx $     $Date: 15-11-2021$      $Revision: 0.1 $ 
% Copyright: no? 


    % read dimensions
    path = [convertStringsToChars(path), '\'];
    Dims = readtable([path, 'Dimensions.csv'], "ReadRowNames", true);

    lat  = linspace(Dims{1,1}, Dims{1,2}, Dims{1,3});
    lon  = linspace(Dims{2,1}, Dims{2,2}, Dims{2,3});
    alt  = linspace(Dims{3,1}, Dims{3,2}, Dims{3,3});
    t    = linspace(Dims{4,1}, Dims{4,2}, Dims{4,3});
    date = linspace(Dims{5,1}, Dims{5,2}, Dims{5,3});

    % read files present in directory -- assume they're all .csv files
    files = dir(path);
    data = cell(size(files));
    name = cell(size(files));

    f = 0;
    for i = 1:length(files)
        if ~files(i).isdir && ~strcmp(files(i).name, 'Dimensions.csv') % ignore folders and the 'Dimensions' file
            f = f+1;
            data{f} = reshape(readmatrix([path, files(i).name]).', ...
                       Dims{1,3}, Dims{2,3}, Dims{3,3}, Dims{4,3}, Dims{5,3});
            name{f} = files(i).name;
        end
    end

    % output
    varargout = {data(1:f), name(1:f), lat, lon, alt, t, date};

end

