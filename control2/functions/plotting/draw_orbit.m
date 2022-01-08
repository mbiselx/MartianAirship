function draw_orbit(varargin)
% function draw_orbit(orbit, plt_opt)


if nargin > 1
    plt_opt = varargin{2};
else
    plt_opt = '--b';
end

plot3(varargin{1}(1,:), ...
      varargin{1}(2,:), ...
      varargin{1}(3,:), plt_opt)
axis equal
set(gca,'xtick',[], 'ytick',[], 'ztick',[])

end

