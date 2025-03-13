function VisualizeMesh(vertices, faces, color, titleName, varargin)
    % VisualizeMesh displays a 3D mesh using patch.
    %
  
    % Create an input parser object
    pi = inputParser;
    
    % Define a default scale value and a validation function
    % defaultScale = 0.05;
    % validScale = @(x) isnumeric(x) && isscalar(x) && (x > 0);
    defaultBones = [];
    validBones = @(x) isempty(x) || (isnumeric(x) && size(x,2)==7);
    
    % Add optional parameters
    addOptional(pi, 'bones', defaultBones, validBones);
    
    % Parse the inputs
    parse(pi, varargin{:});
    
    % Get the scale value
    bones = pi.Results.bones;
   
    % Create a new figure window
    fig = figure;
    hold on;
    grid on;
    
    % Draw the mesh using patch
    meshPatch = patch('Vertices', vertices, 'Faces', faces, ...
              'FaceColor', color, 'EdgeColor', 'none', 'FaceAlpha', 1.0);
    
    % Improve visualization: adjust the view and add lighting
    view(3);             % 3D view
    camlight('left'); % Add a light that follows the camera
    lighting phong;    % Use smooth lighting
    material shiny;       % Set material properties

    if ~isempty(bones)
        % Capture joint handles from drawJoints.
        hJoints = drawJoints(bones);
        % Set key press callback to toggle joint visibility.
        set(hJoints, 'Visible', 'off');
    end
    
    % Set a key press callback for toggling mesh transparency.
    set(fig, 'WindowKeyPressFcn', @(src, event) toggleTransparency(src, event, meshPatch, hJoints));

    ax = gca;
    set(ax, 'GridColor', [0.5 0.5 0.5], 'GridAlpha', 0.5);  % Customize grid appearance
    
    % Add labels and title (optional)
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    axis manual;          % Disable automatic axis sizing
    % Set axis range
    xlim([-1 1]);
    ylim([-1.4 0.8]);
    zlim([-1 1]);  % Adjust this as needed for your mesh
    title(titleName);
    hold off;
end


% Created with ChatGPT
function toggleTransparency(~, event, patchHandle, jointHandles)
    % toggleTransparency toggles the mesh transparency when a key is pressed.
    % For example, pressing 't' toggles between transparent (0.5) and opaque (1).
    
    currentAlpha = get(patchHandle, 'FaceAlpha');
    
    % Toggle transparency of mesh
    if strcmpi(event.Key, 't')
        if abs(currentAlpha - 1.0) < eps  % currently opaque
            set(patchHandle, 'FaceAlpha', 0.5);
        else
            set(patchHandle, 'FaceAlpha', 1.0);
        end

        % Check visibility of the first handle.
        currentVis = get(jointHandles(1), 'Visible');
        if strcmp(currentVis, 'on')
            newVis = 'off';
        else
            newVis = 'on';
        end
        % Set the visibility for all joint handles.
        set(jointHandles, 'Visible', newVis);
        disp(['Joint visibility set to ' newVis]);

    end
   

end


