%% paternoster

clc
close all
clear

addpath('data')
addpath('functions')


%% estimate lift
set_parameters;


rho_atm = @(z) (1.684e-06*z+1.429e-2);
V = @(z) (-(me+mg+ms+md+mn)*g*z + .5*z.*(rho_atm(z) + rho_atm(0))*g*4/3*pi*rb^3);

figure, 
subplot(2,1,1), 
plot(-1000:7000, V(-1000:7000)), hold on
[v, h] = min(V(-1000:7000));
h = h - 1000;
plot(h,v,'rx')
subplot(2,1,2), 
plot(-1000:7000, rho_atm(-1000:7000))