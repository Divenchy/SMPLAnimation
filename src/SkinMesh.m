% Provided by ChatGPT
function skinnedMesh = SkinMesh(baseMesh, skinIndices, skinWeights, boneTransforms, boneBindTransforms)
% SkinMesh computes a skinned mesh using linear blend skinning.
%
%   skinnedMesh = SkinMesh(baseMesh, skinIndices, skinWeights, boneTransforms, boneBindTransforms)
%
%   baseMesh         - structure with field .v (Nx3 vertices)
%   skinIndices      - (NxmaxInf) matrix of bone indices (1-indexed)
%   skinWeights      - (NxmaxInf) matrix of corresponding weights
%   boneTransforms   - cell array of 4x4 current bone transformation matrices
%   boneBindTransforms - cell array of 4x4 bind-pose bone transformation matrices
%
% For each vertex, the new position is computed as:
%   v_new = sum_j w_j * (T_cur_j * inv(T_bind_j)) * [v;1]

    N = size(baseMesh.v, 1);
    maxInf = size(skinIndices, 2);
    skinnedVertices = zeros(N, 3);

    for v = 1:N
        v_h = [baseMesh.v(v,:) 1]';  % Homogeneous coordinate (4x1)
        v_new = zeros(4,1);
        for j = 1:maxInf
            boneIdx = skinIndices(v, j);
            w = skinWeights(v, j);
            % Compute the skinning matrix for this bone.
            % NOTE: Equivalent to T_skin = boneTransforms{boneIdx} * inv(boneBindTransforms{boneIdx});
            T_skin = boneTransforms{boneIdx} / boneBindTransforms{boneIdx};
            % Accumulate the weighted transformed vertex.
            v_new = v_new + w * (T_skin * v_h);
        end
        % Convert back from homogeneous coordinates.
        skinnedVertices(v,:) = v_new(1:3)' / v_new(4);
    end

    skinnedMesh = baseMesh;
    skinnedMesh.v = skinnedVertices;
end
