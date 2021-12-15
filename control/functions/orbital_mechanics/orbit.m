function varargout = orbit(body, T)
% [Op3D, Op2D] = orbit(body, T [yr])
    

    % step 1: correct params for time T
    a    = body.A    + T/100*body.Adot;
    e    = body.E    + T/100*body.Edot;
    i    = body.I    + T/100*body.Idot;
    RAAN = body.RAAN + T/100*body.RAANdot;
    LP   = body.LP   + T/100*body.LPdot;
    L0   = body.L0   + T/100*body.L0dot;

    % step 2: compute mean anomaly
    omega = LP - RAAN;
    M     = L0 - LP;

    % step 3: iteratively solve for initial excentric anomaly
    preE = M;           
    E = e .* sin(preE) + M;
    cnt = 0;
    while (any(abs(E - preE) > 1e-12) && (cnt < 100))
        preE = E;
        E = e.*sin(preE) + M;
        cnt = cnt+1;
    end

    % step 4: Compute the body's orbital coordinates in its orbital plane
    Op2 = a .* [(cos(E) - e);
                sqrt(1 - e.^2).*sin(E); 
                zeros(size(E))];

    % step 5: orbital plane in J2000 reference system
    Op3 = [ ( cos(omega).*cos(RAAN) - sin(omega).*sin(RAAN).*cos(i)).*Op2(1,:) + ...
            (-sin(omega).*cos(RAAN) - cos(omega).*sin(RAAN).*cos(i)).*Op2(2,:); 
            ( cos(omega).*sin(RAAN) + sin(omega).*cos(RAAN).*cos(i)).*Op2(1,:) + ...
            (-sin(omega).*sin(RAAN) + cos(omega).*cos(RAAN).*cos(i)).*Op2(2,:); 
              sin(omega).*sin(i).*Op2(1,:) + ...
              cos(omega).*sin(i).*Op2(2,:)]; 

    varargout = {Op3, Op2};

end

