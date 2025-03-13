function [boneBindTransforms, boneTransforms, ...
            beta1BoneTransforms, beta1BoneTransformsCur,...
            beta2BoneTransforms, beta2BoneTransformsCur] = ...
    BoneTransforms(skeletons, beta1Skel, beta2Skel, boneIdx, translationY)

    baseBones = skeletons{1}.data; % q(x, y, z, w) p(x, y, z)
    numBones = size(baseBones,1);

    % Initialize a cell array to hold each bone's transformation matrix
    boneBindTransforms = cell(numBones, 1);
    boneTransforms = cell(numBones, 1);
    beta1BoneTransforms = cell(numBones, 1);
    beta1BoneTransformsCur = cell(numBones, 1);
    beta2BoneTransforms = cell(numBones, 1);
    beta2BoneTransformsCur = cell(numBones, 1);

    % For each bone, create the 4x4 transformation matrix (rotation is identity)
    for i = 1:numBones
        t = baseBones(i, 5:7)';  % Ensure column vector
        T = [eye(3), t; 0 0 0 1];
        boneTransforms{i} = T;
        boneBindTransforms{i} = T;
    end

    for i = 1:numBones
        t = beta1Skel(1).data(i, 5:7)';
        T = [eye(3), t; 0 0 0 1];
        beta1BoneTransforms{i} = T;
        beta1BoneTransformsCur{i} = T;
    end

    for i = 1:numBones
        t = beta2Skel(1).data(i, 5:7)';
        T = [eye(3), t; 0 0 0 1];
        beta2BoneTransforms{i} = T;
        beta2BoneTransformsCur{i} = T;
    end


    % Update L_Elbow transform.
    L_Elbow = boneIdx;  % adjust index as needed.
    T_current = boneTransforms{L_Elbow};
    T1_current = beta1BoneTransformsCur{L_Elbow};
    T2_current = beta2BoneTransformsCur{L_Elbow};
    T_current(2,4) = T_current(2,4) + translationY;  % translate 0.05 up in Y.
    T1_current(2,4) = T1_current(2,4) + translationY;  % translate 0.05 up in Y.
    T2_current(2,4) = T2_current(2,4) + translationY;  % translate 0.05 up in Y.
    boneTransforms{L_Elbow} = T_current;
    beta1BoneTransformsCur{L_Elbow} = T1_current;
    beta2BoneTransformsCur{L_Elbow} = T2_current;
end