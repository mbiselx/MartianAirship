function Ff = drag_force(v_air)
%DRAG_FORCE approximated worst-case drag force

    p = [0.0006, -0.0275, 0.4552, -2.9762, 6.0844, 13.364, -3.3806];
    
    if isnumeric(v_air)
        Ff = polyval(p, v_air);
    else
        Ff = p * [v_air.^6; v_air.^5; v_air.^4; v_air.^3; v_air.^2; v_air; 1];
    end

end

