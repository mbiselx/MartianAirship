function fig = visualize(O, q)
%VISUALIZE Summary of this function goes here
%   Detailed explanation goes here

    set_parameters

    fig = figure(100);
    fig.Name = "Simulation";
    
    % plot balloon
    plot( O(1)+rb*cos(0:(pi/40):(2*pi)), ...
         -O(2)+rb*sin(0:(pi/40):(2*pi)), 'b', 'LineWidth', 3);
    hold on
    plot( O(1)+rb*sin(q(1))*[-1, 1], ...
         -O(2)+rb*cos(q(1))*[ 1,-1], 'bo', 'MarkerSize', 4, 'LineWidth', 3)
    
    % plot tether
    plot( O(1)+rb*sin(q(1))+[0,  d*sin(q(2))], ...
         -O(2)-rb*cos(q(1))+[0, -d*cos(q(2))], 'k', 'LineWidth', 2)
    
    % plot nacelle
    nacelle = [-rn rn rn -rn -rn rn; 
                 0  0 -h  -h   0  0];
    nacelle = [cos(q(3)) -sin(q(3)); sin(q(3)), cos(q(3))] * nacelle + [O(1) + rb*sin(q(1)) + d*sin(q(2)); -O(2) - rb*cos(q(1)) - d*cos(q(2))];
    plot(nacelle(1,:), nacelle(2,:), 'k', 'LineWidth', 3)
    
    hold off
    
    axis equal 
    grid on
    axis([O(1)-rb-5, O(1)+rb+5, -O(2)-rb-d-h-1, -O(2)+rb+1,])

    drawnow
    
end

