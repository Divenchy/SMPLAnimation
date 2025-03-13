function [betaMesh1,betaMesh2] = CalcBlendDeltas(baseMesh, blendMeshes, beta1arr, beta2arr)
%CALCBLENDDELTAS Helper function that calculates the delta blends

deltaMeshes = cellfun(@(mesh) struct('v', mesh.v - baseMesh.v, 'f', mesh.f), blendMeshes, 'UniformOutput', false);

betaMesh1 = baseMesh;
betaMesh2 = baseMesh;

for mesh = 1:length(deltaMeshes)
    % vertices
    betaMesh1.v = betaMesh1.v + (beta1arr(mesh) * deltaMeshes{mesh}.v);
    betaMesh2.v = betaMesh2.v + (beta2arr(mesh) * deltaMeshes{mesh}.v);
end

end

