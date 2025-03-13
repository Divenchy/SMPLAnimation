% Created with the help of ChatGPT
function AnimateObjFiles(objFolder, totalFrames)
    % Preload all meshes into a cell array.
    disp('Preloading OBJ files...');
    allMeshes = cell(totalFrames,1);
    for f = 0:(totalFrames-1)
        objFile = fullfile(objFolder, sprintf('frame%03d.obj', f));
        if ~exist(objFile, 'file')
            error('File %s not found.', objFile);
        end
        allMeshes{f+1} = readObj(objFile);
    end
    disp('Preloading complete.');

    % Create a figure and patch.
    fig = figure('Name','Animation Viewer');
    ax = axes('Parent', fig);
    hold(ax, 'on');
    grid(ax, 'on');
    xlabel(ax, 'X'); ylabel(ax, 'Y'); zlabel(ax, 'Z');
    axis(ax, 'equal');
    view(ax, 3);
    camlight(ax, 'left');
    lighting(ax, 'gouraud');
    material(ax, 'shiny');
    
    % Use the first frame to create the patch.
    mesh0 = allMeshes{1};
    meshPatch = patch('Parent', ax, 'Vertices', mesh0.v, 'Faces', mesh0.f.v, ...
                        'FaceColor', [0.3, 0.5, 1.0], 'EdgeColor', 'none', 'FaceAlpha', 1.0);
    
    % Set axis limits if desired.
    xlim(ax, [-1 1]); ylim(ax, [-1.4 0.8]); zlim(ax, [-1 1]);
    
    % Animation loop.
    frameRate = 24;
    pauseTime = 1 / frameRate;
    disp('Starting animation...');
    while ishandle(fig)
        for f = 1:totalFrames
            mesh = allMeshes{f};
            set(meshPatch, 'Vertices', mesh.v);
            drawnow;
            pause(pauseTime);
        end
    end
end
