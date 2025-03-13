function [baseMesh,blendMeshes] = LoadReadMeshes()
%LOADREADMESHES Helper function that handles file loading and reading
%creating mesh objects

    % Load shape meshes
    baseMeshFile = fullfile('..', 'input', 'smpl_00.obj'); % Base mesh file
    % Cell array for blends
    blendshapeFiles = arrayfun(@(n) fullfile('..', 'input', sprintf('smpl_%02d.obj', n)), 1:10, 'UniformOutput', false);
    % Accessing cell array
    % firstFile = blendshapeFiles{1};

    % Looping
    % for i = 1:length(blendshapeFiles)
    %     currentFile = blendshapeFiles{i};   % Access the i-th file
    %     % For example, load the mesh from the file
    %     mesh = readObj(currentFile);
    %     % Process the mesh as needed
    % end

    % Or using cellfun
    % meshes = cellfun(@readObj, blendshapeFiles, 'UniformOutput', false);

    % Read mesh files
    baseMesh = readObj(baseMeshFile);
    blendMeshes = cellfun(@readObj, blendshapeFiles, 'UniformOutput', false);

end

