function out = rho_atm(z)
    
    if nargin < 1
        z = -3000;
    end

    p = [4.19E-18, -2.67E-14, 5.94E-11, -9.85E-07, 1.23E-02];

    if (size(z,1) == 1)
        out = polyval(p, z);
    else
        out = polyval(p, z(end,:));
    end

    % if (size(z,1) == 1)
    %     out = 1.23E-02 + -1.19E-06 * z + 7.31E-11 .* z.^2;
    % else
    %     out = 1.23E-02 + -1.19E-06 * z(end,:) + 7.31E-11 .* z(end,:).^2;
    % end
end
