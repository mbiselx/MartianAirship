% clear 
% close all
clc

addpath("functions\")

% syms P T v real
% syms D rho real
% syms c real
% 
% eta = 2 / ( 1 + sqrt(1 + 8*T/(pi*rho*D^2*v^2)) );
% 
% eta = 2 / ( 1 + sqrt(1 + T/(c*v^2)) );
% 
% eqn = simplify([T*v == eta * P])
% 
% sol = solve(eqn, T, 'Real', true, 'ReturnConditions', true);
% sol.T = simplify(sol.T)



D=1:0.2:8;          %[m]    Prop diameter
V=1:1:50;           %[m/s]  Free stream velocity
T=200;              %[N]    Total Thrust
rho=0.017;          %[kg/m3]Density
eta=zeros(length(D), length(V));    %froude efficiency
eta2=zeros(length(D), length(V));    %froude efficiency
for i_D=1:length(D)
    S=pi*D(i_D)^2/4;
    for i_V=1:length(V)
        a=T/(2*rho*S*V(i_V)^2);
        a=(-1+sqrt(1+4*a))/2;
        eta(i_D, i_V)=1/(1+a)*100;

        P = T*V(i_V)/(eta(i_D, i_V)/100);
        [~, eta(i_D, i_V)] = Thrust(P, V(i_V), D(i_D), 200);

        a2=T/2/(2*rho*S*V(i_V)^2);
        a2=(-1+sqrt(1+4*a2))/2;
        eta2(i_D, i_V)=1/(1+a2)*100;

        P = T/2*V(i_V)/(eta2(i_D, i_V)/100);
        [~, eta2(i_D, i_V)] = Thrust(P, V(i_V), D(i_D), 200);

        a4=T/4/(2*rho*S*V(i_V)^2);
        a4=(-1+sqrt(1+4*a4))/2;
        eta4(i_D, i_V)=1/(1+a4)*100;
    end
end
figure()
tiledlayout(2,2)
nexttile
[X,Y]=meshgrid(V,D);
contour(X,Y,eta, 'ShowText', 'on')
xline(10, '--')
xlabel('Free-stream Velocity V [m/s]')
ylabel('Propeller Diameter D [m]')
legend('Efficiency', 'Airship airspeed')
title(['Ideal efficiency \eta_i [%] of a propeller with 200N Thrust' ])
nexttile
contour(X,Y,eta2, 'ShowText', 'on')
xline(10, '--')
xlabel('Free-stream Velocity V [m/s]')
ylabel('Propeller Diameter D [m]')
legend('Efficiency', 'Airship airspeed')
title(['Ideal efficiency \eta_i [%] of a propeller with 100N Thrust' ])
nexttile
contour(X,Y,eta4, 'ShowText', 'on')
xline(10, '--')
xlabel('Free-stream Velocity V [m/s]')
ylabel('Propeller Diameter D [m]')
legend('Efficiency', 'Airship airspeed')
title(['Ideal efficiency \eta_i [%] of a propeller with 50N Thrust' ])

