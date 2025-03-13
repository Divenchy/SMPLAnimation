% ChatGPT helped with visualization of joints
function hFrame = drawJointFrame(jointPos, R)
    % drawJointFrame draws a coordinate frame at a joint position.
    %
    % jointPos : 1x3 vector [x, y, z] of the joint position.
    % R        : 3x3 rotation matrix (local orientation at the joint).
    % scale    : scalar determining the length of the axes.
    
    origin = jointPos;
    xAxis = origin + 0.05 * R(:,1)';
    yAxis = origin + 0.05 * R(:,2)';
    zAxis = origin + 0.05 * R(:,3)';
    
    % Draw axes (red=x, green=y, blue=z)
    h1 = plot3([origin(1) xAxis(1)], [origin(2) xAxis(2)], [origin(3) xAxis(3)], 'r-', 'LineWidth', 1);
    h2 = plot3([origin(1) yAxis(1)], [origin(2) yAxis(2)], [origin(3) yAxis(3)], 'g-', 'LineWidth', 1);
    h3 = plot3([origin(1) zAxis(1)], [origin(2) zAxis(2)], [origin(3) zAxis(3)], 'b-', 'LineWidth', 1);

    hFrame = [h1; h2; h3];
end
