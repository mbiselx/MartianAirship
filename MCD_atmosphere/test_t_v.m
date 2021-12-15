%% paternoster
clc 
close all
clear

addpath("Ls0_-73deg\")

season = "Ls = 0°";
make_gif = true;
dt = .3;

%% test
Dims = readtable("Dimensions.csv", "ReadRowNames", true);


    lat  = linspace(Dims{1,1}, Dims{1,2}, Dims{1,3});
    lon  = linspace(Dims{2,1}, Dims{2,2}, Dims{2,3});
    z    = linspace(Dims{3,1}, Dims{3,2}, Dims{3,3});
    t    = linspace(Dims{4,1}, Dims{4,2}, Dims{4,3});
    date = linspace(Dims{5,1}, Dims{5,2}, Dims{5,3});

Temperatures = reshape(readmatrix("Temperatures.csv").', ...
                       Dims{1,3}, Dims{2,3}, Dims{3,3}, Dims{4,3});

MeridWind = reshape(readmatrix("MeridWind.csv").', ...
                       Dims{1,3}, Dims{2,3}, Dims{3,3}, Dims{4,3});

ZonalWind = reshape(readmatrix("ZonalWind.csv").', ...
                       Dims{1,3}, Dims{2,3}, Dims{3,3}, Dims{4,3});

VertWind = reshape(readmatrix("VertWind.csv").', ...
                       Dims{1,3}, Dims{2,3}, Dims{3,3}, Dims{4,3});

disp("done")


%% plot wind over time

n = 5;
v_exg = 50;
deg2m = 2*pi*3389e3/360/v_exg;
[X, Y] = meshgrid(deg2m*lat(1:n:end), z(1:n:end));

fig = figure(1);
fig.WindowState = 'maximized';
colormap jet
filename = 'Wind_Slice.gif';
xlim([deg2m*min(lat), deg2m*max(lat)])
ylim([min(z), max(z)])
axis equal manual
for ti = 1:length(t)
    pcolor(deg2m*lat, z, reshape(Temperatures(:,1,:,ti), Dims{1,3}, Dims{3,3}).'); hold on
    quiver(X, Y, reshape(MeridWind(1:n:end,:,1:n:end,ti)/v_exg, size(X,2), size(X,1)).', ...
                 reshape(-VertWind(1:n:end,:,1:n:end,ti), size(X,2), size(X,1)).', ...
                 'k', 'LineWidth', 1.5), hold off
    shading flat
    c = colorbar('eastoutside');
    c.Label.String = 'Temp. [K]';
    caxis([170, 250])
    title(sprintf("%s, Winds at longitude = %.1f °, time = %.1f h", season, lon(1), t(ti)))
    xlabel(sprintf("longitude [m/%d]", v_exg)), ylabel("altitude [m]")
    drawnow
    if make_gif
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

%%
    ti = find(abs(t-12)<.4);
    pcolor(deg2m*lat, z, reshape(Temperatures(:,1,:,ti), Dims{1,3}, Dims{3,3}).'); hold on
    quiver(X, Y, reshape(MeridWind(1:n:end,:,1:n:end,ti)/v_exg, size(X,2), size(X,1)).', ...
                 reshape(-VertWind(1:n:end,:,1:n:end,ti), size(X,2), size(X,1)).', ...
                 'k', 'LineWidth', 1.5), hold off
    shading flat
    c = colorbar('eastoutside');
    c.Label.String = 'Temp. [K]';
    caxis([170, 250])
    title(sprintf("%s, Winds at longitude = %.1f °, time = %.1f h", season, lon(1), t(ti)))
    xlabel(sprintf("longitude [m/%d]", v_exg)), ylabel("altitude [m]")
    drawnow



%% plot temperature evolution over height

% fig = figure(2);
% colormap jet
% filename = 'Temperature.gif';
% for ti = 1:length(t)
%     pcolor(lon, lat, Temperatures(:,:,:,ti));
%     shading flat
%     axis equal tight
%     c = colorbar('eastoutside');
%     c.Label.String = 'Temp. [K]';
%     caxis([170, 250])
%     title(sprintf("%s, Temperature at altitude = %.1f m, time = %.1f", season, z(1), t(ti)))
%     xlabel("longitude [°]"), ylabel("latitude [°]")
%     drawnow
%     if make_gif
%         % Capture the plot as an image 
%         [imind,cm] = rgb2ind(frame2im(getframe(fig)),256); 
%         % Write to the GIF File 
%         if ti == 1 
%             imwrite(imind,cm,filename, 'gif', 'Loopcount', inf, 'DelayTime', dt); 
%         else 
%             imwrite(imind,cm,filename, 'gif', 'WriteMode', 'append', 'DelayTime', dt); 
%         end 
%     end 
% end