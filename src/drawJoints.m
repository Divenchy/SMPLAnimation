% Edited to return a handle of joints in order to toggle visibility
function hJoints = drawJoints(skelData)
    % skelData is a 24x7 matrix, where each row is:
    % [q_x, q_y, q_z, q_w, t_x, t_y, t_z]
    %
    % scale is a scalar to set the length of the drawn axes.
    
    % If you don't have quat2rotm, you can implement your own conversion.
    % Here we assume that rotations are stored as [q_x, q_y, q_z, q_w].
    
    numJoints = size(skelData, 1);
    hJoints = gobjects(2*numJoints,1); % Preallocate handles for points and text labels.
    handleIdx = 1;
   
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title('Skeleton Joints with Local Frames');
    axis equal;
    
    for i = 1:numJoints
        q = skelData(i, 1:4);
        t = skelData(i, 5:7);
        % Convert quaternion to rotation matrix.
        % MATLAB's quat2rotm expects [w, x, y, z]
        R = quat2rotm([q(4), q(1:3)]);
        % Draw the joint frame at the translation position.
        hFrame = drawJointFrame(t, R);
        hJoints(handleIdx:handleIdx+2) = hFrame;
        handleIdx = handleIdx + 3;
        % Optionally, also mark the joint with a point:
        hJoints(handleIdx) = scatter3(t(1), t(2), t(3), 20, 'k', 'filled');
        handleIdx = handleIdx + 1;
        hJoints(handleIdx) = text(t(1)+0.005, t(2)+0.005, t(3)+0.005, num2str(i-1), 'Color', 'k', 'FontSize', 10);
        handleIdx = handleIdx + 1;
    end
   
end
