function P = orbital_period(a, m)
% a     : semimajor axis of the orbit
% m     : mass at the focal point of the orbit
% P     : orbital period in [s]

    constants % get physical constants

    P = 2*pi*sqrt(a.^3 / (G * m));

end

