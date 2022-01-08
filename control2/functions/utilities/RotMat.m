function R = RotMat(varargin)
% R = RotMat(theta)         : 2D rotation matrix
% R = RotMat(theta, DIM)    : 3D rotation matrix around dim

    s = sin(varargin{1});
    c = cos(varargin{1});

    if nargin == 1 % 2D rotation matrix
        R = [ c  s ;
             -s  c];
    elseif nargin == 2
        switch(varargin{2})
            case 1
                R = [ 1  0  0 ;
                      0  c  s ;
                      0 -s  c];
            case 2
                R = [ c  0 -s ;
                      0  1  0 ;
                      s  0  c];
            case 3
                R = [ c  s  0 ;
                     -s  c  0 ;
                      0  0  1];
             otherwise
            error("invalid rotation axis %d. rotation axis must be 1, 2 or 3", ax);
        end
    else
        error("invalid number of input angles")
    end

end