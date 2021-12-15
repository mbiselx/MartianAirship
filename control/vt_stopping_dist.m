close all
clc
clear

addpath("functions\utilities\")
addpath("functions\parameters")
addpath("functions\aerodynamics")
addpath("functions\plotting")

%% set parameter

airship_params

v_air       = [0; 0; 0];       % [m/s]

T_vent      = 60^2;
T_sim       = 5000;
dt          = .1;

integrate   = @(x, i) (.5*(x(:,i) + x(:,i-1))*dt);


lh = [];
ll = {};
h = -1000:-1000:-4000;

for i  = 1:length(h)

    t        = 0:dt:T_sim;
    p        = zeros(3, length(t));
    peq      = zeros(3, length(t));
    v        = zeros(3, length(t));
    a        = zeros(3, length(t));
    Fa       = zeros(3, length(t));
    FG       = zeros(3, length(t));

    p(:,1)   = [0; 0; -h(i)];
    peq(:,1) = [0; 0; -h(i)];
    v(:,1)   = v_air;

    m_bb0    = 4/3*pi*r_bb^3*rho_atm(h(i));
    FG(:,1)  =  Fg(m+m_bb0);
    Fa(:,1)  = -Fg(m+m_bb0);
    fa       =  Fa(:,1)/rho_atm(h(i));

    for j = 2:length(t)


        m_bb  = max(0, (1-t(j-1)/T_vent) * m_bb0);
        Fa(:,j) = fa * rho_atm(-p(3,j-1));
        Fd      = dragForce(v_air - v(:,j-1), p(:,j-1));
%         Fd      = 0;
        FG(:,j) = Fg(m + m_bb);
        F       = FG(:,j) + Fa(:,j) + Fd; 

        a(:,j)  = F/(m + m_bb + m_a);
        v(:,j)  = v(:,j-1) + integrate(a, j);
        p(:,j)  = p(:,j-1) + integrate(v, j);

        % calculate equilibrium position 
        % rho_atm(x) == -FG(3,end)/fa(3)
        [~, idx] = min(abs(rho_atm((-p(3,j)-2000):20:(-p(3,j)+2000)) + FG(3,j)/fa(3)));
        heq = (-p(3,j)-2000) + 20*idx;
        [~, idx] = min(abs(rho_atm((heq-40):.1:(heq+40)) + FG(3,j)/fa(3) ));
        peq(3,j) = -(heq-40 + .1*idx);
%         rho_atm(-peq(3,j)) + FG(3,j)/fa(3)
    end



    figure(1)
    C = colororder;
    subplot(3,1,1)
%         plot(t, -a(3,:)), hold on
%         xlabel("time [s]"), ylabel("acceleration [m / s^2]")
        plot(t, FG(3,:), "Color", C(i,:)), hold on
        plot(t, -Fa(3,:),"Color", C(i,:)), hold on
        xlabel("time [s]"), ylabel("Force [N]")
        grid on
        axis tight
    subplot(3,1,2)
        plot(t, -v(3,:), "Color", C(i,:)), hold on
        xlabel("time [s]"), ylabel("velocity [m / s]")
        grid on
        axis tight
    subplot(3,1,3)
        lh = [lh, plot(t, -p(3,:)-h(i), "Color", C(i,:))]; hold on
        ll = [ll, {sprintf("%d m", h(i))}];
        xlabel("time [s]"), ylabel("elevation [m]")
        grid on
        axis tight

%     figure(2)
%     yyaxis left 
%         plot(-p(3,:)-h(i), t, '-', "Color", C(i,:)), hold on
%         ylabel("time of flight")
%     yyaxis right
%         plot(-p(3,:)-h(i), rho_atm(-p(3,:)) - rho_atm(h(i)), '-', "Color", C(i,:)), hold on
%         ylabel("\rho_{atm}")
%         xlabel("elevation [m]")

    figure(3)
    plot3(t, -p(3,:)  -h(i), rho_atm(h(i)) - rho_atm(-p(3,:)),   '-',  "Color", C(i,:) ), hold on
    plot3(t, -peq(3,:)-h(i), rho_atm(h(i)) - rho_atm(-peq(3,:)), '--', "Color", C(i,:) ), hold on
    xlabel("time of flight"), ylabel("elevation [m]"), zlabel("\rho_{atm}")

end





legend(lh, ll, 'location', 'southeast')
% sgtitle(sprintf("Stopping distance/time for %d N propulsion", T0))
