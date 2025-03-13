% Created with heavy help from ChatGPT
function [relTransforms, absTransforms] = CalcRelativeAndUpdateAndAbs(baseSkeleton, hierarchy, numBones, boneIdx, translationY)

% Compute relative transforms.
% For each bone, relative transform = T_rel = [I, (t_child - t_parent); 0 0 0 1]
relTransforms = cell(numBones,1);
for i = 1:numBones
    % Get absolute translation for this bone (column 5:7)
    t_abs = baseSkeleton(i, 5:7)';  % 3x1 vector
    if isempty(hierarchy(i).parent)
        % Root: relative translation is the same as absolute.
        t_rel = t_abs;
    else
        parentIdx = hierarchy(i).parent;
        t_parent = baseSkeleton(parentIdx, 5:7)';
        t_rel = t_abs - t_parent;
    end
    relTransforms{i} = [eye(3), t_rel; 0 0 0 1];
end

% After computing relTransforms:
% (relTransforms{i} is a 4x4 matrix of the form [I, t_rel; 0 0 0 1])
T_rel = relTransforms{boneIdx};
T_rel(2,4) = T_rel(2,4) + translationY;
% Store the updated relative transform.
relTransforms{boneIdx} = T_rel;

% Reconstruct absolute transforms by traversing from the bone back to the root.
absTransforms = cell(numBones,1);
for i = 1:numBones
    T_abs = eye(4);
    current = i;
    % Traverse up the hierarchy until the root is reached.
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