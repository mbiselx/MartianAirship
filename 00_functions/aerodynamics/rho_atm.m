function out = rho_atm(z)
    % takes MOLA altitude as input
    
    if nargin < 1
        z = -3000;
    end

    p = [4.19E-18, -2.67E-14, 5.94E-11, -9.85E-07, 1.23E-02];

    if (size(z,1) == 1)
        out = polyval(p, z);
    else
        out = polyval(p, z(end,:));
    end

end
