function [slope] = get_slope(Z, mpp)
%GET_SLOPE Summary of this function goes here

    % get slope
    [dZx, dZy] = gradient(Z);       % [m / pix]
    dZ = sqrt(dZx.^2 + dZy.^2)/mpp; % [m / m]
    slope = atand(dZ);              % [°]

end

