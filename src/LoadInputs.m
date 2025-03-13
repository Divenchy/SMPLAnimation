function [baseMesh, blendMeshes, ...
            skeletons, skinIndices, skinWeights, boneHierarchy, numBonesHier] = LoadInputs

    if exist('../meshes.mat', 'file')
        load('../meshes.mat', 'baseMesh', 'blendMeshes');
    else
        [baseMesh, blendMeshes] = LoadReadMeshes();
        save('../meshes.mat', 'baseMesh', 'blendMeshes');
    end
    
    if exist('../skeletons.mat', 'file')
        load('../skeletons.mat', 'skeletons');
    else
        skelFilenames = arrayfun(@(n) fullfile('..', 'input', sprintf('smpl_skel%02d.txt', n-1)), 1:11, 'UniformOutput', false);
        skeletons = LoadReadSkelTxt(skelFilenames);
        save('../skeletons.mat', "skeletons");
    end

    if exist('../skinWeights.mat', 'file')
        load('../skinWeights.mat', 'skinIndices', 'skinWeights');
    else
        [skinIndices, skinWeights] = LoadReadWeights(fullfile('..', 'input', 'smpl_skin.txt'));
        save('../skinWeights.mat', 'skinIndices', 'skinWeights');
    end

    if exist('../boneHierarchy.mat', 'file')
        load('../boneHierarchy.mat', 'boneHierarchy', 'numBonesHier');
    else
        [boneHierarchy, numBonesHier] = LoadHierarchyTxt(fullfile('..', 'input', 'smpl_hierarchy.txt'));
        save('../boneHierarchy.mat', 'boneHierarchy', 'numBonesHier');
end