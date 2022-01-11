%% paternoster
clc
close all
clear

addpath("..")
set_path
data_path = '../00_data/atmospherics/';

%% test readMCDdata

[data, names, lat, lon, alt, t, date] = readMCDdata([data_path, 'clim_aveEUV']);

for i = 1:length(names)
    if contains(names{i}, 'Temperatures')
        Temperatures = data{i};
    elseif contains(names{i}, 'Density')
        Density = data{i};
    elseif contains(names{i}, 'Pressures')
        Pressures = data{i};
    end
end

disp("done")


%% plot temperature over time

lat_idx = find(lat <= -11.2, 1);
lon_idx = find(lon <= -67, 1);
alt_idx = find(alt >= -3000, 1);

figure('Name', "Temperature Cycle")
hold on
h = [];
l = {};
for i = 1:length(date)
        h = [h, plot(t, reshape(Temperatures(lat_idx,lon_idx,alt_idx, :, i), length(t), 1, 1, 1), ...
            '- .', 'MarkerSize', 7)];
        l = [l, {sprintf("L_s = %.1f°", date(i))}];
end
hold off
legend(h, l)
xlabel("Martian hours [h]"), ylabel("Temp. [K]")
title(sprintf("Daily Temparature Cycle at %.1f°N/%.1f°E, %d m MOLA", lat(lat_idx), lon(lon_idx), alt(alt_idx)))

%% plot temperature over time

figure('Name', "Pressure Cycle")
hold on
h = [];
l = {};
for i = 1:length(date)
        h = [h, plot(t, reshape(Pressures(lat_idx,lon_idx,alt_idx, :, i), size(t)), ...
            '- .', 'MarkerSize', 7)];
        l = [l, {sprintf("L_s = %.1f°", date(i))}];
end
hold off
legend(h, l)
xlabel("Martian hours [h]"), ylabel("Pressure [Pa]")
title(sprintf("Daily Pressure Cycle at %.1f°N/%.1f°E, %d m MOLA", lat(lat_idx), lon(lon_idx), alt(alt_idx)))
