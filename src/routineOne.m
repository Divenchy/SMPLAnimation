% /src/routineOne
function routineOne(setVis)
%   ROUTINEONE Performs Task One. 

    addpath(genpath('../lib'));

    % Load input data (base mesh and skin weights)

    
    % (ChatGPT) If already read in a previous execution, use mat file to
    % cache
    % This is because matlab takes a good minute to execute, speeding up
    % development
    if exist('../meshes.mat', 'file')
        load('../meshes.mat', 'baseMesh', 'blendMeshes');
    else
        [baseMesh, blendMeshes] = LoadReadMeshes();
        save('../meshes.mat', 'baseMesh', 'blendMeshes');
    end


    %%%% Blend shape calculations
    % Beta sets
    beta1 = [-1.711935 2.352964 2.285835 -0.073122 1.501402 -1.790568 -0.391194 2.078678 1.461037 2.297462];
    beta2 = [1.573618 2.028960 -1.865066 2.066879 0.661796 -2.012298 -1.107509 0.234408 2.287534 2.324443];

    % Calculate deltax_b = x_b - x_0
    [betaMesh1, betaMesh2] = CalcBlendDeltas(baseMesh, blendMeshes, beta1, beta2);

    % Export meshes to output1
    outputFile = fullfile('..', 'output1', 'frame000.obj');
    writeObj(outputFile, baseMesh);
    outputFile = fullfile('..', 'output1', 'frame001.obj');
    writeObj(outputFile, betaMesh1);
    outputFile = fullfile('..', 'output1', 'frame002.obj');
    writeObj(outputFile, betaMesh2);

    % (ChatGPT) After reading and processing meshes for the first time:
    save('meshes.mat', 'baseMesh', 'blendMeshes');

    % Visualize Base Mesh, B1 Mesh, and B2 Mesh
    if (setVis)
        % VisualizeMesh(baseMesh.v, baseMesh.f.v, [0.3, 0.5, 1.0], "Base Mesh");
        % VisualizeMesh(betaMesh1.v, betaMesh1.f.v, [0.8, 0.3, 0.0], "Beta1 Mesh");
        % VisualizeMesh(betaMesh2.v, betaMesh2.f.v, [0.8, 0.7, 0.0], "Beta2 Mesh");
    end

end

