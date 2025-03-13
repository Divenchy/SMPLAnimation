% /src/routineSix
function routineSix()
%    ROUTINESix performs task 6 Combined Output
addpath(genpath('../lib'));

%% Load input data (base mesh, skeletons, and skin weights)
% MATLAB uses index starting at 1
[baseMesh, blendMeshes, skeletons, skinIndices, skinWeights, boneHierarchy, numBonesHier] = LoadInputs;
[mocapFrames, frameCount, boneCount] = LoadMocap(fullfile('..','input','smpl_quaternions_mosh_cmu_7516.txt'));
[mocapFrames_, frameCount_, boneCount_] = LoadMocap(fullfile('..', 'input', 'smpl_quaternions_mosh_cmu_8806.txt'));

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
videoFile = fullfile('..','output6','animation.mp4');
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
fileIdxBase = 0;
totalFrames = 470;
seg1Frames = 95;
seg2Frames = 145; % Went from baseMesh to beta1Mesh
seg3Frames = 210;
seg4Frames = 260; % Mocap transition
seg5Frames = 340;
seg6Frames = 390; % Going from beta1Mesh to beta2Mesh
seg7Frames = 470;

% For this task going to keep transforming a single mesh (baseMesh as foundation)
anim1Frames = 1;
anim2Frames = 1;
for f = 1:totalFrames

    disp("Frame" +f);
    quatData = [];
    % Process mocap frame data as before to compute new absolute transforms.
    % Set which mocapdata to use depening on frame index
    if f < seg1Frames
        frameData = mocapFrames{anim1Frames};
        quatData = frameData(4:end);
        meshCase = 'base';
        % After loading frame data update for next loop
        anim1Frames = anim1Frames + 1;
    elseif f < seg2Frames+1
        % Morph between meshes
        frameData = mocapFrames{anim1Frames};
        quatData = frameData(4:end);
        meshCase = 'interpBaseToBeta1';
        interpAlpha = (f - seg1Frames) / (50 - 1);  % 0 to 1
    elseif f < seg3Frames+1
        % Finish the rest of mocap 7516
        frameData = mocapFrames{anim1Frames};
        quatData = frameData(4:end);
        meshCase = 'beta1Mocap1';
        anim1Frames = anim1Frames + 1;
    elseif f < seg4Frames+1
        alphaMocap = (f - 210) / (50 - 1);
        alphaMocap = min(max(alphaMocap, 0), 1);
        meshCase = 'mocapTransition';
        quatData = [];
    elseif f < seg5Frames+1 % 80 frames long
        frameData = mocapFrames_{anim2Frames};
        quatData = frameData(4:end);
        meshCase = 'beta1Mocap2';
        anim2Frames = anim2Frames + 1;
    elseif f < seg6Frames+1 % 50 frames long
        meshCase = 'interpBeta1ToBeta2';
        % Morph between meshes
        frameData = mocapFrames_{anim2Frames};
        quatData = frameData(4:end);
        interpAlpha = (f - seg5Frames) / (50 - 1);  % 0 to 1
    else
        meshCase = 'beta2Mocap2';
        frameData = mocapFrames_{anim2Frames};
        quatData = frameData(4:end);
        anim2Frames = anim2Frames + 1;
    end

    relTransforms = cell(boneCount, 1);

    for b = 1:boneCount
        % Determine q
        if ~isempty(quatData)
            % Continue as usual
            q = quatData((b-1)*4 + (1:4));
            q = q(:)';
            R = quat2rotm([q(4), q(1:3)]);
        else
            % For segment 4, we need to interpolate rotations.
            % For each bone b in segment 4:

            % 2 hours spent cause matlab access so silly
            frameData_ = mocapFrames{anim1Frames};
            quatData_ = frameData_(4:end);
            frameData__ = mocapFrames_{1};
            quatData__ = frameData__(4:end);
            q1 = quatData_((b-1)*4 + (1:4));
            q2 = quatData__((b-1)*4 + (1:4));

            q_interp = (1 - alphaMocap) * q1 + alphaMocap * q2;
            q_interp = q_interp / norm(q_interp);
            q_interp = q_interp(:)';
            R = quat2rotm([q_interp(4), q_interp(1:3)]);
        end

        % Choose appropiate t_rel
        switch meshCase
            case {'base','interpBaseToBeta1'}
                t_rel = bindRelTransforms{b};
            case {'beta1Mocap1', 'beta1Mocap2','interpBeta1ToBeta2', 'mocapTransition'}
                t_rel = beta1RelTransforms{b};
            case 'beta2Mocap2'
                t_rel = beta2RelTransforms{b};
            otherwise
                t_rel = bindRelTransforms{b};
        end

        % Use relative offset computed from bind pose.
        relTransforms{b}  = [R, t_rel; 0 0 0 1];
    end

    absTransforms = RecalcAbsT(relTransforms, boneHierarchy);

    % Select how to skin
    switch meshCase
        case 'base'
            mesh = SkinMesh(baseMesh, skinIndices, skinWeights, absTransforms, boneBindTransforms);
            currentColor = [0.3, 0.5, 1.0];  % blue
            % Update fig
            set(meshPatchBase, 'Vertices', mesh.v, 'FaceColor', currentColor);
            writeObj(fullfile('..','output6', sprintf('frame%03d.obj', fileIdxBase)), mesh);
        case 'interpBaseToBeta1'
            % Compute both endpoints using current mocap frame.
            mesh_base = SkinMesh(baseMesh, skinIndices, skinWeights, absTransforms, boneBindTransforms);

            beta1Rel_transforms = cell(boneCount, 1);
            % Make the mesh for beta1 at this frame
            for b = 1:boneCount
                % Determine q

                q = quatData((b-1)*4 + (1:4));
                q = q(:)';
                R = quat2rotm([q(4), q(1:3)]);

                t_rel_beta1 = beta1RelTransforms{b};

                % Use relative offset computed from bind pose.
                beta1Rel_transforms{b}  = [R, t_rel_beta1; 0 0 0 1];
            end

            absTransforms_beta1 = RecalcAbsT(beta1Rel_transforms, boneHierarchy);
            betaMesh1A = SkinMesh(betaMesh1, skinIndices, skinWeights, absTransforms_beta1, beta1BoneTransforms);

            % Linear interpolation of vertices.
            mesh = mesh_base;
            interpAlpha = min(max(interpAlpha, 0), 1);
            mesh.v = (1 - interpAlpha)*mesh_base.v + interpAlpha*betaMesh1A.v;
            % Interpolate color from blue to red.
            currentColor = (1 - interpAlpha)*[0.3, 0.5, 1.0] + interpAlpha*[0.8, 0.3, 0.0];
            % Update fig
            set(meshPatchBase, 'Vertices', mesh.v, 'FaceColor', currentColor');
            writeObj(fullfile('..','output6', sprintf('frame%03d.obj', fileIdxBase)), mesh);
        case 'interpBeta1ToBeta2'
            % Compute both endpoints using current mocap frame.
            mesh_beta = SkinMesh(betaMesh1, skinIndices, skinWeights, absTransforms, beta1BoneTransforms);

            beta2Rel_transforms = cell(boneCount, 1);
            % Make the mesh for beta1 at this frame
            for b = 1:boneCount
                % Determine q

                q = quatData((b-1)*4 + (1:4));
                q = q(:)';
                R = quat2rotm([q(4), q(1:3)]);

                t_rel_beta2 = beta2RelTransforms{b};

                % Use relative offset computed from bind pose.
                beta2Rel_transforms{b}  = [R, t_rel_beta2; 0 0 0 1];
            end

            absTransforms_beta2 = RecalcAbsT(beta2Rel_transforms, boneHierarchy);
            betaMesh2A = SkinMesh(betaMesh2, skinIndices, skinWeights, absTransforms_beta2, beta2BoneTransforms);

            % Linear interpolation of vertices.
            mesh = mesh_beta;
            interpAlpha = min(max(interpAlpha, 0), 1);
            mesh.v = (1 - interpAlpha)*mesh_beta.v + interpAlpha*betaMesh2A.v;
            % Interpolate color from blue to red.
            currentColor = (1 - interpAlpha)*[0.8, 0.3, 0.0] + interpAlpha*[0.8, 0.7, 0.0];
            % Update fig
            set(meshPatchBase, 'Vertices', mesh.v, 'FaceColor', currentColor');
            writeObj(fullfile('..','output6', sprintf('frame%03d.obj', fileIdxBase)), mesh);
        case {'beta1Mocap1', 'mocapTransition', 'beta1Mocap2'}
            mesh = SkinMesh(betaMesh1, skinIndices, skinWeights, absTransforms, beta1BoneTransforms);
            currentColor = [0.8, 0.3, 0.0];  % red (orange tinge)
            % Update fig
            set(meshPatchBase, 'Vertices', mesh.v, 'FaceColor', currentColor);
            writeObj(fullfile('..','output6', sprintf('frame%03d.obj', fileIdxBase)), mesh);
        case 'beta2Mocap2'
            mesh = SkinMesh(betaMesh2, skinIndices, skinWeights, absTransforms, beta2BoneTransforms);
            currentColor = [0.8, 0.7, 0.0];  % red (orange tinge)
            % Update fig
            set(meshPatchBase, 'Vertices', mesh.v, 'FaceColor', currentColor);
            writeObj(fullfile('..','output6', sprintf('frame%03d.obj', fileIdxBase)), mesh);
    end

    drawnow;

    % Capture the frame.
    frame = getframe(figBase);
    writeVideo(vWriter, frame);
    fileIdxBase = fileIdxBase + 1; % Increase file index, zero-indexing
end

% Second segment
close(vWriter);
close(figBase);

fprintf('Animation video written to %s\n', videoFile);
end