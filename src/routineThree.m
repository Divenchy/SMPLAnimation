% /src/routineThree
function routineThree(varargin)
%   ROUTINEThree performs task 3 

    addpath(genpath('../lib'));

    % Parse optional args
    p = inputParser;

    defaultVisBase = false;
    defaultVisMesh1 = false;
    defaultVisMesh2 = false;

    validVis = @(x) islogical(x) && isscalar(x);

    addOptional(p, 'visBase', defaultVisBase, validVis);
    addOptional(p, 'visMesh1', defaultVisMesh1, validVis);
    addOptional(p, 'visMesh2', defaultVisMesh2, validVis);

    parse(p, varargin{:});

    visBase = p.Results.visBase;
    visMesh1 = p.Results.visMesh1;
    visMesh2 = p.Results.visMesh2;

    %% Load input data (base mesh, skeletons, and skin weights)
    % MATLAB uses index starting at 1
    [baseMesh, blendMeshes, skeletons, skinIndices, skinWeights, boneHierarchy, numBonesHier] = LoadInputs;

    %% Blend shape calculations
    % Beta sets
    beta1 = [-1.711935 2.352964 2.285835 -0.073122 1.501402 -1.790568 -0.391194 2.078678 1.461037 2.297462];
    beta2 = [1.573618 2.028960 -1.865066 2.066879 0.661796 -2.012298 -1.107509 0.234408 2.287534 2.324443];

    % Calculate deltax_b = x_b - x_0
    [betaMesh1, betaMesh2] = CalcBlendDeltas(baseMesh, blendMeshes, beta1, beta2);
    % Calculate the skeleton deltas
    [beta1Skel, beta2Skel] = CalcBonesDelta(skeletons, beta1, beta2); % Returns a skeleton for each

    % Get Base
    baseBones = skeletons{1}.data; % q(x, y, z, w) p(x, y, z)

    %% Calculate Transforms
    [boneBindTransforms, boneTransforms, ...
     beta1BoneTransforms, beta1BoneTransformsCur,...
     beta2BoneTransforms, beta2BoneTransformsCur] = BoneTransforms(skeletons, beta1Skel, beta2Skel, 19, 0.2);

    % Constructs and initial relative transforms cell (4x4 Matrix) and then
    % update the translation of a bone (e.g L_Elbow 0.2 up in Y-axis, then
    % finally calculate the abs transformations
    [relTransforms, absTransforms] = CalcRelativeAndUpdateAndAbs(baseBones, boneHierarchy, numBonesHier, 19, 0.2);
    [relTransforms1, absTransforms1] = CalcRelativeAndUpdateAndAbs(beta1Skel.data, boneHierarchy, numBonesHier, 19, 0.2);
    [relTransforms2, absTransforms2] = CalcRelativeAndUpdateAndAbs(beta2Skel.data, boneHierarchy, numBonesHier, 19, 0.2);

    % Apply skinning.
    baseMesh = SkinMesh(baseMesh, skinIndices, skinWeights, absTransforms, boneBindTransforms);
    betaMesh1 = SkinMesh(betaMesh1, skinIndices, skinWeights, absTransforms1, beta1BoneTransforms);
    betaMesh2 = SkinMesh(betaMesh2, skinIndices, skinWeights, absTransforms2, beta2BoneTransforms);

    %% Export meshes to output1
    outputFile = fullfile('..', 'output3', 'frame000.obj');
    writeObj(outputFile, baseMesh);
    outputFile = fullfile('..', 'output3', 'frame001.obj');
    writeObj(outputFile, betaMesh1);
    outputFile = fullfile('..', 'output3', 'frame002.obj');
    writeObj(outputFile, betaMesh2);

    %% Visualize Base Mesh, B1 Mesh, and B2 Mesh
    if (visBase)
        % VisualizeMesh(baseMesh.v, baseMesh.f.v, [0.3, 0.5, 1.0], "Base Mesh", baseBones);
    end
    if (visMesh1)
        % VisualizeMesh(betaMesh1.v, betaMesh1.f.v, [0.8, 0.3, 0.0], "Beta1 Mesh", beta1Skel.data);
    end
    if visMesh2
        % VisualizeMesh(betaMesh2.v, betaMesh2.f.v, [0.8, 0.7, 0.0], "Beta2 Mesh", beta2Skel.data);
    end
end

