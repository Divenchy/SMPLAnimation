function [betaSkel1,betaSkel2] = CalcBonesDelta(skeletons, beta1arr, beta2arr)
%CALCBONESDELTAS Calculates the deltas between the bone translations

baseSkeleton = skeletons{1}.data; % [boneCount * 7]

beta1Bones = baseSkeleton(:, 5:7);
beta2Bones = baseSkeleton(:, 5:7);

% Loop over each blend skeleton (from 2 to end)
for i = 2:length(skeletons)
    % Compute the delta for translations
    delta = skeletons{i}.data(:, 5:7) - baseSkeleton(:, 5:7);
    % Update the new translations using the corresponding blend weight.
    beta1Bones = beta1Bones + beta1arr(i-1) * delta;
    beta2Bones = beta2Bones + beta2arr(i-1) * delta;
end


% init to base
betaSkel1 = skeletons{1};
betaSkel2 = skeletons{1};


betaSkel1.data(:, 5:7) = beta1Bones;
betaSkel2.data(:, 5:7) = beta2Bones;
end
