function out = dragTorque(Omega, Omega_dot, dt, r)

    if nargin < 2
        Omega_dot = 0;
    end
    if nargin < 3
        dt = 1;
    end
    if nargin < 4
        r  =23;
    end


    dyn_visc = 1.23E-05; % [Pa s]
    kin_visc = 1.23E-05 / 1.5e-2; % [s]

    quasisteady_torque = - 8   * dyn_visc * r^3 * pi * Omega;

    k_max = min( length(Omega_dot), floor(100/dt)); % save computing time and hope that after 100 s history is irrelevant
    vtt = kin_visc*dt*(k_max:-1:1);
    acceleration_torque = -8/3 * dyn_visc * r^3 * sqrt(pi) * ...
                            sum(Omega_dot(end-k_max+1:end) .* (r./sqrt(vtt) - ...
                            sqrt(pi) .* exp(vtt./r^2) .* erfc(sqrt(vtt)./r) ) )*dt;

    out = [0; quasisteady_torque + acceleration_torque; 0];
end
