% /src/routineFive
function routineFive()
%   ROUTINEFive performs task 5

addpath(genpath('../lib'));

%% Load input data (base mesh, skeletons, and skin weights)
% MATLAB uses index starting at 1
[baseMesh, blendMeshes, skeletons, skinIndices, skinWeights, boneHierarchy, numBonesHier] = LoadInputs;
[mocapFrames, frameCount, boneCount] = LoadMocap(fullfile('..','input','smpl_quaternions_mosh_cmu_7516.txt'));

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
    beta2BoneTransforms, beta2BoneTransformsCur] = BoneTransforms(skeletons, beta1Skel, beta2Skel, 19, 0.0);

%% Apply skinning.
baseMesh = SkinMesh(baseMesh, skinIndices, skinWeights, boneTransforms, boneBindTransforms);
betaMesh1 = SkinMesh(betaMesh1, skinIndices, skinWeights, beta1BoneTransformsCur, beta1BoneTransforms);
betaMesh2 = SkinMesh(betaMesh2, skinIndices, skinWeights, beta2BoneTransformsCur, beta2BoneTransforms);


%% Prepare for Video Writing
videoFile = fullfile('..','output5','animation.mp4');
vWriter = VideoWriter(videoFile, 'MPEG-4');  % or 'MPEG-4'
vWriter.FrameRate = 24;  % adjust as desired
open(vWriter);

%% Create figures for animation
% Create a figure for each mesh variant (if you want them separate)
figBase = figure('Name','Base Mesh Animation');
% Create initial patch objects (and joint visuals if needed)

% Base mesh:
axesBase = axes('Parent', figBase);
hold(axesBase, 'on');
hold on;
meshPatchBase = patch('Parent', axesBase, ...
    'Vertices', baseMesh.v, 'Faces', baseMesh.f.v, ...
    'FaceColor', [0.3, 0.5, 1.0], 'EdgeColor', 'none', 'FaceAlpha', 1.0);
% axis(axesBase, 'equal');
view(axesBase, 3);
camlight(axesBase, 'left');
lighting(axesBase, 'phong');
material(axesBase, 'shiny');
ax = gca;
ax.Clipping = 'off';
% Set axis range
xlim([-1 1]);
ylim([-1.4 0.8]);
zlim([-1.2 1]);  % Adjust this as needed for your mesh
grid on;
hold off;


%% Animation Loop (update existing patch objects)

% Precompute relative translations from the bind pose of the meshes.
bindRelTransforms = cell(boneCount, 1);
beta1RelTransforms = cell(boneCount, 1);
beta2RelTransforms = cell(boneCount, 1);
for b = 1:boneCount
    if isempty(boneHierarchy(b).parent)
        bindRelTransforms{b} = baseBones(b,5:7)';
        beta1RelTransforms{b} = beta1Skel.data(b,5:7)';
        beta2RelTransforms{b} = beta2Skel.data(b,5:7)';
    else
        pIdx = boneHierarchy(b).parent;
        bindRelTransforms{b} = baseBones(b,5:7)' - baseBones(pIdx,5:7)';
        beta1RelTransforms{b} = beta1Skel.data(b,5:7)' - beta1Skel.data(pIdx,5:7)';
        beta2RelTransforms{b} = beta2Skel.data(b,5:7)' - beta2Skel.data(pIdx,5:7)';
    end
end

%% Genrating frames (Animation Loop)
% Help from ChatGPT in setting up animation loop
fileIdxBase = 0;
totalFrames = 3 * frameCount;
for f = 1:totalFrames
    % Process mocap frame data as before to compute new absolute transforms.

    frameData = mocapFrames{mod(f-1, frameCount) + 1};
    quatData = frameData(4:end);
    relTransforms_base = cell(boneCount, 1);
    relTransforms_beta1 = cell(boneCount, 1);
    relTransforms_beta2 = cell(boneCount, 1);
    for b = 1:boneCount
        q = quatData((b-1)*4 + (1:4));
        q = q(:)';  % ensure row vector
        R = quat2rotm([q(4), q(1:3)]);

        t_rel = bindRelTransforms{b};
        t1_rel = beta1RelTransforms{b};
        t2_rel = beta2RelTransforms{b};

        % Use relative offset computed from bind pose.
        relTransforms_base{b}  = [R, t_rel; 0 0 0 1];
        relTransforms_beta1{b} = [R, t1_rel; 0 0 0 1];
        relTransforms_beta2{b} = [R, t2_rel; 0 0 0 1];
    end

    absTransforms_base = RecalcAbsT(relTransforms_base, boneHierarchy);
    absTransforms_beta1 = RecalcAbsT(relTransforms_beta1, boneHierarchy);
    absTransforms_beta2 = RecalcAbsT(relTransforms_beta2, boneHierarchy);

    % Skin the meshes using updated transforms
    baseMeshA = SkinMesh(baseMesh, skinIndices, skinWeights, absTransforms_base, boneBindTransforms);
    betaMesh1A = SkinMesh(betaMesh1, skinIndices, skinWeights, absTransforms_beta1, beta1BoneTransforms);
    betaMesh2A = SkinMesh(betaMesh2, skinIndices, skinWeights, absTransforms_beta2, beta2BoneTransforms);

    % Update the patch objects with the new vertices
    if fileIdxBase < 160
        set(meshPatchBase, 'Vertices', baseMeshA.v);
        writeObj(fullfile('..','output5', sprintf('frame%03d.obj', fileIdxBase)), baseMeshA);
    end
    if (fileIdxBase > 159)
        set(meshPatchBase, 'Vertices', betaMesh1A.v);
        set(meshPatchBase, 'FaceColor', [0.8, 0.3, 0.0]);
        writeObj(fullfile('..','output5', sprintf('frame%03d.obj', fileIdxBase)), betaMesh1A);
    end
    if fileIdxBase > 319
        set(meshPatchBase, 'Vertices', betaMesh2A.v);
        set(meshPatchBase, 'FaceColor', [0.8, 0.7, 0.0]);
        writeObj(fullfile('..','output5', sprintf('frame%03d.obj', fileIdxBase)), betaMesh2A);
    end

    drawnow;

    % Capture the frame.
    frame = getframe(figBase);
    writeVideo(vWriter, frame);
    fileIdxBase = fileIdxBase + 1; % Increase file index, zero-indexing
end
close(vWriter);
close(figBase);

fprintf('Animation video written to %s\n', videoFile);
end