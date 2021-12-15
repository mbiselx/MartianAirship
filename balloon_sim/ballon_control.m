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
syms me mg ms mn md     % masses of envelope, gas, solar cells, nacelle and link
syms x z                % position of the balloon
syms an ab theta        % attitudes of nacelle and balloon, angle of the pendulum swing between balloon and nacelle

% balloon mass
mb     = me + mg + ms;

% balloon geometry
O = [x;0;z];
B = O +  rb*[sin(ab);    0; cos(ab)];  
D = B + d/2*[sin(theta); 0; cos(theta)]; % mass of the link
A = B +  d *[sin(theta); 0; cos(theta)];
N = A + h/2*[sin(an);    0; cos(an)];

% intertia of nacelle around itself
In     = 1/12 * mn * (3*rn^2 + h^2);

% intertia of nacelle around B
InB    = In + mn*simplify((N-B).'*(N-B)); % approximative

% intertias around origin
Is0    = 2/3*ms*rb^2;       % solar
Ie0    = 2/3*me*rb^2;       % envelope
Ig0    = 2/5*mg*rb^2;       % gas (approximated as a solid!! this is super wrong)
Ib0    = Is0 + Ie0 + Ig0;   % balloon !! incorrect, bc we don't take into account that the CoM is higher than 0/0/0, due to solar cells

% Forces / other TODO!!!
syms  v_air

F_w  = drag_force(v_air); % drag force actig on the balloon
F_prop = F_w;             % propulsion power 


%% dynamics 

syms  dx  dz  dan  dab  dtheta
syms ddx ddz ddan ddab ddtheta

% velocities at points
dO = diff(O, x)*dx + diff(O, z)*dz + diff(O, ab)*dab + diff(O, theta)*dtheta + diff(O, an)*dan;
dB = diff(B, x)*dx + diff(B, z)*dz + diff(B, ab)*dab + diff(B, theta)*dtheta + diff(B, an)*dan;
dD = diff(D, x)*dx + diff(D, z)*dz + diff(D, ab)*dab + diff(D, theta)*dtheta + diff(D, an)*dan;
dA = diff(A, x)*dx + diff(A, z)*dz + diff(A, ab)*dab + diff(A, theta)*dtheta + diff(A, an)*dan;
dN = diff(N, x)*dx + diff(N, z)*dz + diff(N, ab)*dab + diff(N, theta)*dtheta + diff(N, an)*dan;

% kinetic energies
Tb = .5 * mb * (dO.'*dO) + .5 * Ib0 * dab^2; % balloon kinetic energy 
Tl = .5 * md * (dD.'*dD);                    % rigid tether kinetic energy as a point mass?? dumb
Tn = .5 * mn * (dN.'*dN) + .5 * In  * dan^2; % nacelle 
T  = simplify(Tb+Tl+Tn);

% potential energies 
rho_atm = @(z) (1.684e-06*O(3)+1.429e-2);
Vol_b = 4/3*pi*rb^3; % Volume of balloon
Vol_n = h*pi*rn^2;
Vb = -mb*g*O(3) + .5*O(3).*(rho_atm(O(3)) + rho_atm(0))*g*Vol_b; % TODO: make buoyancy less stupid?  
Vl = -md*g*D(3);
Vn = -mn*g*N(3);% + .5*N(3).*(rho_atm(N(3)) + rho_atm(0))*g*Vol_n;
V  = simplify(Vb+Vl+Vn);

% lagrangian
L = T - V;

% lagrangian equation of motion 
dLdq  = [ diff(L, x);
          diff(L, z);
          diff(L, ab);
          diff(L, theta);
          diff(L, an)]; 

dLddq = [ diff(L, dx);
          diff(L, dz);
          diff(L, dab);
          diff(L, dtheta);
          diff(L, dan)];

dLddq_dt = diff(dLddq,  x)* dx + diff(dLddq,  z)* dz + diff(dLddq,  ab)* dab + diff(dLddq,  theta)* dtheta + diff(dLddq,  an)* dan + ...
           diff(dLddq, dx)*ddx + diff(dLddq, dz)*ddz + diff(dLddq, dab)*ddab + diff(dLddq, dtheta)*ddtheta + diff(dLddq, dan)*ddan;

Eq = dLddq_dt - dLdq;

% calculate matrices 
G       =  subs(Eq, {dx, ddx, dz, ddz, dab, ddab, dtheta, ddtheta, dan, ddan}, {zeros(1,10)}); % gravity

M(:, 1) = (subs(Eq, {dx,      dz, ddz, dab, ddab, dtheta, ddtheta, dan, ddan}, {zeros(1,9)})-G)./ddx;
M(:, 2) = (subs(Eq, {dx, ddx, dz,      dab, ddab, dtheta, ddtheta, dan, ddan}, {zeros(1,9)})-G)./ddz;
M(:, 3) = (subs(Eq, {dx, ddx, dz, ddz, dab,       dtheta, ddtheta, dan, ddan}, {zeros(1,9)})-G)./ddab;
M(:, 4) = (subs(Eq, {dx, ddx, dz, ddz, dab, ddab, dtheta,          dan, ddan}, {zeros(1,9)})-G)./ddtheta;
M(:, 5) = (subs(Eq, {dx, ddx, dz, ddz, dab, ddab, dtheta, ddtheta, dan,     }, {zeros(1,9)})-G)./ddan;

C(:, 1) = (subs(Eq, {    ddx, dz, ddz, dab, ddab, dtheta, ddtheta, dan, ddan}, {zeros(1,9)})-G)./dx;
C(:, 2) = (subs(Eq, {dx, ddx,     ddz, dab, ddab, dtheta, ddtheta, dan, ddan}, {zeros(1,9)})-G)./dz;
C(:, 3) = (subs(Eq, {dx, ddx, dz, ddz,      ddab, dtheta, ddtheta, dan, ddan}, {zeros(1,9)})-G)./dab;
C(:, 4) = (subs(Eq, {dx, ddx, dz, ddz, dab, ddab,         ddtheta, dan, ddan}, {zeros(1,9)})-G)./dtheta;
C(:, 5) = (subs(Eq, {dx, ddx, dz, ddz, dab, ddab, dtheta, ddtheta,      ddan}, {zeros(1,9)})-G)./dan;

G = simplify(G, 'Steps', 50);
M = simplify(M, 'Steps', 50);
C = simplify(C, 'Steps', 50);

assert(~any(simplify(M * [ddx;ddz;ddab;ddtheta;ddan] + C * [dx;dz;dab;dtheta;dan] + G - Eq)), "there's a problem in the equation - Check C(q, dq) ~= C(q)*dq")

matlabFunction(M, 'File', 'functions/eval_M_tmp');
matlabFunction(C, 'File', 'functions/eval_C_tmp');
matlabFunction(G, 'File', 'functions/eval_G_tmp');

disp("done")

%% steady-state

Zss_v = vpa(simplify(solve(diff(V, z)/g == 0, [x,z,ab, theta, an]).z, 'Steps', 50), 3)
Zss_l = vpa(simplify(solve(-G == zeros(5,1),  [x,z,ab, theta, an]).z, 'Steps', 50), 3)


% set_parameters
% 
% Zss_num = vpa(subs(Zss_v, {sym('me'), sym('mg'), sym('md'), sym('mn'), sym('ms'), sym('rb'), sym('rn'), sym('h'), sym('d')}, ...
%                           {     me,        mg,        md,        mn,        ms,        rb,        rn,        h,        d} ), 3)
% Zss_num = vpa(subs(Zss_l, {sym('me'), sym('mg'), sym('md'), sym('mn'), sym('ms'), sym('rb'), sym('rn'), sym('h'), sym('d')}, ...
%                           {     me,        mg,        md,        mn,        ms,        rb,        rn,        h,        d} ), 3)



%% 
disp("done")