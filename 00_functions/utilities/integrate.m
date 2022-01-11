function [A] = integrate(x, dt, i)
%INTEGRATE trapezoid integration function
    if ~exist('dt', 'var') || isempty(dt)
        dt = 1;
    end

    switch size(x,2)
        case 0
            A = 0;
        case 1
            A = x * dt;
        otherwise
            if exist('i', 'var')
                if i > 1
                    A = (.5*(x(:,i) + x(:,i-1))*dt);
                else
                    A = x(:,i)*dt;
                end
            else
                A   = sum(x,2)*dt;
            end
    end
end

