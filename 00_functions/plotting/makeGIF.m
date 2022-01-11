function makeGIF(fig,varargin)
%MAKEGIF makes a gif out of the passed figure handle
%
%   makeGIF(fig)
%   makeGIF(fig, GIFname, dt)
%   makeGIF(fig, GIFname, dt, overwrite)    
    

    if nargin > 1 
        GIFname = varargin{1};
    else 
        GIFname = "out.gif";
    end

    if nargin > 2
        dt      = varargin{2};
    else
        dt      = .1;
    end

    if (nargin > 3) && varargin{3} && exist(GIFname, 'file')
        delete(GIFname);
    end

    [imind, cm] = rgb2ind(frame2im(getframe(fig)), 256); 
    if exist(GIFname, 'file')
        imwrite(imind, cm, GIFname, 'gif', 'WriteMode', 'append', 'DelayTime', dt); 
    else 
        imwrite(imind, cm, GIFname, 'gif', 'Loopcount',inf, 'DelayTime', dt); 
    end 
 
end

