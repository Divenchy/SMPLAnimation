function [hierarchy, numBonesHier] = LoadHierarchyTxt(hierarchyFile)


 % Open the file.
    fid = fopen(hierarchyFile, 'r');
    if fid == -1
        error('Cannot open hierarchy file: %s', hierarchyFile);
    end

    % Skip comment lines that start with '#' 
    line = fgetl(fid);
    while ischar(line) && ~isempty(line) && line(1)=='#'
        line = fgetl(fid);
    end

    % The first non-comment line should be the number of bones.
    numBonesHier = str2double(line);
    if isnan(numBonesHier)
        error('Could not parse the number of bones.');
    end

    % Preallocate hierarchy structure.
    hierarchy(numBonesHier).child = [];  % preallocate structure array

    % Read each subsequent line.
    for i = 1:numBonesHier
        line = fgetl(fid);
        if ~ischar(line)
            error('Unexpected end of file when reading hierarchy.');
        end
        tokens = strsplit(strtrim(line));
        % Expected tokens: {childIdx, parentIdx, rotationOrder, boneName}
        childIdx = str2double(tokens{1});
        parentIdx = str2double(tokens{2});
        boneName = tokens{4};

        % Convert from 0-indexed (in file) to 1-indexed (MATLAB)
        childIdxMAT = childIdx + 1;
        if parentIdx == -1
            parentIdxMAT = [];  % root has no parent
        else
            parentIdxMAT = parentIdx + 1;
        end

        hierarchy(childIdxMAT).child = childIdxMAT;
        hierarchy(childIdxMAT).parent = parentIdxMAT;
        hierarchy(childIdxMAT).name = boneName;
    end
    fclose(fid);
end