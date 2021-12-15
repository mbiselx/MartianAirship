%% paternoster

clc
close all
clear

addpath('data')
addpath('functions')

%% define simplified balloon geometry
% assumption: non-inertial body frame is located in the center of the 
%             balloon (for simplicity), with the X-axis positive in the
%             direction of travel and the Z-axis positive in the direction
%             of the gravity vector. 

syms g rho_atm P_atm    % surface gravity, atmospheric density, pressure
syms rb d h rn          % balloon radius, length of nacelle link, height and radius of nacelle
syms me mg ms mn ml     % masses of envelope, gas, solar cells, nacelle and link
syms an ab theta        % attitudes of nacelle and balloon, angle of the pendulum swing between balloon and nacelle

% balloon mass
mb     = me + mg + ms;

% balloon geometry
O = [0;0;0];
B = O +  rb*[sin(ab);    0; cos(ab)];  
L = B + d/2*[sin(theta); 0; cos(theta)]; % mass of the link
A = B +  d *[sin(theta); 0; cos(theta)];
N = A + h/2*[sin(an);    0; cos(an)];

% intertia of nacelle around itself
In     = 1/12 * mn * (3*rn^2 + h^2);

% intertia of nacelle around B
InB    = In + mn*simplify((N-B).'*(N-B)); % approximative

% intertias around origin
Is0    = 2/3*ms*rb^2;       % solar
Ie0    = 2/3*me*rb^2;       % envelope
Ig0    = 2/5*mg*rb^2;       % gas (approximative)
Ib0    = Is0 + Ie0 + Ig0;   % balloon
In0    = In + mn*simplify(N.'*N); % approximative

% other 
syms  v_air

% Forces
Fg_n = [ 0; 0; g*mn];   % weight of nacelle
Fg_l = [ 0; 0; g*ml];   % weight of the link
Fg_b = [ 0; 0; g*mb];   % weight of balloon
Fa_b = [ 0; 0; -rho_atm*g*4/3*pi*rb^3]; % buoyancy of the balloon (buoyancy of nacelle is neglected)

F_w  = drag_force(v_air); % drag force actig on the balloon
F_prop = Fw;            % propulsion power 


%% dynamics 

syms  dan  dab  dtheta
syms ddan ddab ddtheta

% velocities at points
dB = diff(B, an)*dan + diff(B, ab)*dab + diff(B, theta)*dtheta;
dL = diff(L, an)*dan + diff(L, ab)*dab + diff(L, theta)*dtheta;
dA = diff(A, an)*dan + diff(A, ab)*dab + diff(A, theta)*dtheta;
dN = diff(N, an)*dan + diff(N, ab)*dab + diff(N, theta)*dtheta;

% kinetic energies
Tb = .5 * Ib0 * dab^2;    % balloon kinetic energy (inertia)
Tl = .5 * ml * (dL.'*dL); % link kinetic energy ? 
Tn = .5 * mn * (dN.'*dN) + .5 * In * dan^2; %  nacelle 
T  = simplify(Tb+Tl+Tn);

% potential energies 
Vb = 0;
Vl = -ml*g*L(3);
Vn = -mn*g*N(3);
V  = simplify(Vb+Vl+Vn);

% lagrangian
L = T - V;

% lagrangian equation of motion 
dLdq  = [ diff(L, ab);
          diff(L, theta);
          diff(L, an)]; 

dLddq = [diff(L, dab);
         diff(L, dtheta);
         diff(L, dan)];

dLddq_dt = diff(dLddq,  ab)* dab + diff(dLddq,  theta)* dtheta + diff(dLddq,  an)* dan + ...
           diff(dLddq, dab)*ddab + diff(dLddq, dtheta)*ddtheta + diff(dLddq, dan)*ddan;

Eq = dLddq_dt - dLdq;

% calculate matrices 
G = subs(Eq, {dab, ddab, dtheta, ddtheta, dan, ddan}, {zeros(1,6)}); % gravity

M(:, 1) = (subs(Eq, {dab,       dtheta, ddtheta, dan, ddan}, {zeros(1,5)})-G)./ddab;
M(:, 2) = (subs(Eq, {dab, ddab, dtheta,          dan, ddan}, {zeros(1,5)})-G)./ddtheta;
M(:, 3) = (subs(Eq, {dab, ddab, dtheta, ddtheta, dan,     }, {zeros(1,5)})-G)./ddan;

C(:, 1) = (subs(Eq, {     ddab, dtheta, ddtheta, dan, ddan}, {zeros(1,5)})-G)./dab;
C(:, 2) = (subs(Eq, {dab, ddab,         ddtheta, dan, ddan}, {zeros(1,5)})-G)./dtheta;
C(:, 3) = (subs(Eq, {dab, ddab, dtheta, ddtheta,      ddan}, {zeros(1,5)})-G)./dan;

G = simplify(G, 'Steps', 50);
M = simplify(M, 'Steps', 50);
C = simplify(C, 'Steps', 50);

assert(~any(simplify(M * [ddab;ddtheta;ddan] + C * [dab;dtheta;dan] + G - Eq)), "there's a problem in the equation")

matlabFunction(M, 'File', 'functions/eval_M_tmp');
matlabFunction(C, 'File', 'functions/eval_C_tmp');
matlabFunction(G, 'File', 'functions/eval_G_tmp');





% liftable_mass = subs((Fa_b + Fg_b)/g, {sym('g'), sym('me'), sym('mg'), sym('r'), sym('rho_atm')}, {g, me, mg, r, rho_atm});
% vpa(liftable_mass, 6)
disp("done")