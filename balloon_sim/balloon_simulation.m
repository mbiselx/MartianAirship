%% paternoster

clc
close all
clear

addpath('data')
addpath('functions')

%% simulate 

% initial conditions
X  = [0; 660];
q  = [deg2rad(10); deg2rad(0); deg2rad(0)]; % [ab, theta, an] 
dX = [0; 0];
dq = [0; 0; 0];

tmax = 30;
dt = 1;
tspan = 0:dt:tmax;
y0 = [X; q; dX; dq];
disp("solving")
options = odeset('RelTol',1e-5);
[Tout, Yout] = ode45(@(t, y) eqns(t, y, y0), tspan, y0, options);
disp("done solving!")

%%

filename = 'test.gif';
make_gif = false%true
for t = 1:length(Tout)
    fig = visualize(Yout(t,1:2), Yout(t,3:5));
    if make_gif == true
        % Capture the plot as an image 
        [imind,cm] = rgb2ind(frame2im(getframe(fig)),256); 
        % Write to the GIF File 
        if t == 1 
            imwrite(imind,cm,filename, 'gif', 'Loopcount',inf, 'DelayTime', dt); 
        else 
            imwrite(imind,cm,filename, 'gif','WriteMode','append', 'DelayTime', dt); 
        end 
    end 
end

disp("done")