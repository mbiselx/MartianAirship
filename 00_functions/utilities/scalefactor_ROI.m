function [xf] = scalefactor_ROI(x)
%SCALEFACTOR determines the scale of the graduations on a ROI plot

    xl = range(x);

    if xl < 1
        xf = .1;
    elseif xl < 2
        xf = .2;
    elseif xl < 8
        xf = 1;
    elseif xl < 20
        xf = 2;
    else
        xf = 5;
    end


end

