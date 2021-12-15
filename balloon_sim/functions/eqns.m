function dy = eqns(t, y, y0)

    X   = [y( 1); y( 2)];
    q   = [y( 3); y( 4); y( 5)];
    dX  = [y( 6); y( 7)];
    dq  = [y( 8); y( 9); y(10)];
    
%     q0 = [y0(1); y0(2); y0(3)];
%     dq0 = [y0(4); y0(5); y0(6)];
%     ddq0 = [y0(7); y0(8); y0(9)];

% eval_M(q)
% eval_G(X, q)
% eval_C(q, dq)

    % control model
    B = zeros(5,1);
    u = zeros(1,length(t));

    % differential eqn plant model
    dy = zeros(size(y));
    dy(1) = y( 6);
    dy(2) = y( 7);
    dy(3) = y( 8);
    dy(4) = y( 9);
    dy(5) = y(10);
    dy(6:10) = eval_M(q)\(-eval_C(q, dq)*[dX;dq] - eval_G(X, q) + B*u);

end

