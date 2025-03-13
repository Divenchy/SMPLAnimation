% Created with heavy help from ChatGPT

function [relTransforms, absTransforms] = CalcRelativeRotationsAndAbs(skelData, hierarchy, numBones, boneIdx, extraQuat)
% CalcRelativeRotationsAndAbs computes the relative and absolute transforms for bones,
%   extraQuat : 1x4 vector representing the extra rotation as a quaternion [q_x, q_y, q_z, q_w].
%
% Returns:
%   relTransforms : cell array of 4x4 relative transforms.
%   absTransforms : cell array of 4x4 absolute transforms.

    % Preallocate cell array for relative transforms.
    relTransforms = cell(numBones, 1);
    
    for i = 1:numBones
        % Compute relative translation:
        t_abs = skelData(i, 5:7)';  % absolute translation as a 3x1 vector
        if isempty(hierarchy(i).parent)
            % For the root, relative translation equals the absolute translation.
            t_rel = t_abs;
        else
            parentIdx = hierarchy(i).parent;
            t_parent = skelData(parentIdx, 5:7)';
            t_rel = t_abs - t_parent;
        end
        
        % Determine the rotation for this bone.
        if i == boneIdx
            % For the designated bone (e.g., the shoulder), use the extra rotation.
            % Convert extraQuat from [q_x, q_y, q_z, q_w] to MATLAB's [q_w, q_x, q_y, q_z].
            R = quat2rotm([extraQuat(4), extraQuat(1:3)]);
        else
            % Otherwise, assume no rotation (i.e., the identity rotation).
            R = eye(3);
        end
        
        % Form the relative transformation for bone i.
        relTransforms{i} = [R, t_rel; 0 0 0 1];
    end

    % Now compute absolute transforms by traversing the hierarchy.
    absTransforms = cell(numBones, 1);
    for i = 1:numBones
        T_abs = eye(4);
        current = i;
        while true
            T_abs = relTransforms{current} * T_abs;
            if isempty(hierarchy(current).parent)
                break;
            end
            current = hierarchy(current).parent;
        end
        absTransforms{i} = T_abs;
    end
end
