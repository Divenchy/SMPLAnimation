function  skeletons = LoadReadSkelTxt(filenames)

% Read all skeleton files
skeletons = cell(length(filenames), 1);
for i = 1:length(filenames)
    fid = fopen(filenames{i}, 'r');
    if (fid == -1)
        error('Cannot open file: %s', filenames{i});
    end

    % Skip comment lines (lines that start with '#')
    line = fgetl(fid);
    while ischar(line) && ~isempty(line) && line(1)=='#'
        line = fgetl(fid);
    end

    % Now the line should be the header containing frameCount and boneCount.
    headerVals = sscanf(line, '%f');  % Uses ' ' as delim
    if numel(headerVals) < 2
        error('Header does not contain frameCount and boneCount.');
    end
    frameCount = headerVals(1);
    boneCount = headerVals(2);

    % For task 2, assume there's only one frame.
    % Each bone has 7 numbers: 4 for the quaternion and 3 for the translation.
    totalNumbers = boneCount * 7;

    % Read the rest of the data (all numbers)
    data = fscanf(fid, '%f');
    fclose(fid);

    if numel(data) < totalNumbers
        error('Not enough data: expected %d numbers for %d bones.', totalNumbers, boneCount);
    end

    % Reshape data so that each row corresponds to a bone.
    % Each bone: [q_x, q_y, q_z, q_w, t_x, t_y, t_z]
        skeletonData = reshape(data(1:boneCount*7), [7, boneCount])';
    skeletons{i} = struct('frameCount', frameCount, ...
                              'boneCount', boneCount, ...
                              'data', skeletonData);
end

% Display for verification:
%fprintf('Read %d bones.\n', length(skeletons));
%disp(skeletons{1}.data);

end

