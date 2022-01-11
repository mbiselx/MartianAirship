%% paternoster
clc
close all
clear

addpath("..")
set_path
data_path = '../00_data/atmospherics/';
save_path = '../99_plots/wind_slices/';

%% test readMCDdata

[data, names, lat, lon, alt, t, date] = readMCDdata([data_path, 'clim_aveEUV']);

for i = 1:length(names)
    if contains(names{i}, 'Temperatures')
        Temperatures = data{i};
    elseif contains(names{i}, 'MeridWind')
        MeridWind = data{i};
    elseif contains(names{i}, 'VertWind')
        VertWind = data{i};
    elseif contains(names{i}, 'ZonalWind')
        ZonalWind = data{i};
    end
end

disp("done")


%% plot slope wind over time 

n = 3;
m = 5;
deg2m = 2*pi*3389e3/360;
Lsi = 1;
[X, Y] = meshgrid(deg2m*lat(1:n:end), alt(1:m:end));

fig = figure(1);
fig.WindowState = 'maximized';
colormap jet

filename = [save_path, sprintf('WindSlice_Ls%d.gif', date(Lsi))];
dt       = 0.2; 

for ti = 1:length(t)
    pcolor(deg2m*lat, alt, ...
            reshape(Temperatures(:,1,:,ti, Lsi), length(lat), length(alt)).'); 
    hold on
    quiver(X, Y, ...
            reshape(MeridWind(1:n:end,:,1:m:end,ti,Lsi), size(X,2), size(X,1)).', ...
            reshape(-VertWind(1:n:end,:,1:m:end,ti,Lsi), size(X,2), size(X,1)).', ...
            'k', 'LineWidth', 1.5), hold off
    shading flat
    c = colorbar('eastoutside');
    c.Label.String = 'Temp. [K]';
    caxis([170, 250])

    title(sprintf("Winds & Temp. at lon = %.1f °, time = %.1f h, Ls = %.0f °.", lon(1), t(ti), date(Lsi)))
    xlabel("latitude [°]"), ylabel("altitude [m]")

    xticks(deg2m * lat(end:-20:1))
    xticklabels(lat(end:-20:1))

    axis equal manual
    xlim([deg2m*min(lat), deg2m*max(lat)])
    ylim([min(alt), max(alt)])


    drawnow
    if exist('filename', 'var')
        % Capture the plot as an image 
        [imind,cm] = rgb2ind(frame2im(getframe(fig)),256); 
        % Write to the GIF File 
        if ti == 1 
            imwrite(imind,cm,filename, 'gif', 'Loopcount', inf, 'DelayTime', dt); 
        else 
            imwrite(imind,cm,filename, 'gif', 'WriteMode', 'append', 'DelayTime', dt); 
        end 
    end 
end
fig.WindowState = 'normal';

%%
disp("done")
