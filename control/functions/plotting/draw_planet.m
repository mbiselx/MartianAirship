function draw_planet(varargin)
% function draw_planet(planet, position)

    planet = varargin{1};
    if nargin > 1 
        position = varargin{2};
    else
        position = zeros(3,1);
    end

% resolution magic number: big is more resolution, but more computing (so slower)
    N = 30;

% prepare the surface of the ellipsoid 
    theta = linspace(-pi/2, pi/2, N+1)' .* ones(N+1);
    R = 1 ./ sqrt(1-planet.e^2*(cos(theta).^2));

    [X, Y, Z] = ellipsoid(position(1), position(2), position(3), ...
                          planet.r,  planet.r,  planet.r*sqrt(1-planet.e^2), N);

    surf(X, Y, Z, R )
    title(planet.name)

    colormap(planet.cmap)
    shading flat;
    axis equal
%     axis('equal', 'off')
    grid off;
    rotate3d on;

end

