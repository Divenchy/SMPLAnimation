% Provided by ChatGPT
function [skinIndices, skinWeights] = LoadReadWeights(filename)
% LoadSkinWeights loads skinning weights from smpl_skin.txt.
%   [skinIndices, skinWeights] = LoadSkinWeights(filename)
%
% The file format:
%   - The first non-comment line contains three integers:
%         vertCount boneCount maxInfluences
%   - Each subsequent line corresponds to a vertex and contains
%         maxInfluences pairs: boneIndex weight boneIndex weight ...
%
% Note: bone indices in the file are 0-indexed; we convert them to MATLAB's 1-indexing.

    fid = fopen(filename, 'r');
    if fid == -1
        error('Cannot open file: %s', filename);
    end

    % Skip comment lines (lines starting with '#')
    line = fgetl(fid);
    while ischar(line) && ~isempty(line) && line(1) == '#'
        line = fgetl(fid);
    end

    % Read header: vertCount, boneCount, maxInfluences
    header = sscanf(line, '%d');
    if numel(header) < 3
        error('Header must contain vertCount, boneCount, and maxInfluences.');
    end
    vertCount = header(1);
    % boneCount = header(2);  % not used here, but available if needed
    maxInf = header(3);

    % Preallocate matrices.
    skinIndices = zeros(vertCount, maxInf);
    skinWeights = zeros(vertCount, maxInf);

    % For each vertex, read maxInf pairs.
    for v = 1:vertCount
        line = fgetl(fid);
        if ~ischar(line)
            error('Unexpected end of file at vertex %d.', v);
        end
        % Read numbers in this line.
        nums = sscanf(line, '%f');
        if numel(nums) ~= 2*maxInf
            error('Vertex %d: Expected %d numbers, got %d.', v, 2*maxInf, numel(nums));
        end
        % The odd-indexed tokens are bone indices; even-indexed are weights.
        skinIndices(v,:) = nums(1:2:end) + 1;  % convert to 1-indexing
        skinWeights(v,:) = nums(2:2:end);
    end

    fclose(fid);
end
