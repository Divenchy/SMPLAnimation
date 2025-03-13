function [ mocapFrames, frameCount, boneCount] = LoadMocap(mocapFile)
    fid = fopen(mocapFile, 'r');
    if fid == -1
        error('Cannot open mocap file: %s', mocapFile);
    end

    % Skip comment lines.
    line = fgetl(fid);
    while ischar(line) && ~isempty(line) && line(1)=='#'
        line = fgetl(fid);
    end

    % First non-comment line: frameCount and boneCount.
    header = sscanf(line, '%f');
    frameCount = header(1);
    boneCount = header(2);
    
    % Each frame: 3 (root translation) + 4*boneCount numbers.
    numNumbersPerFrame = 3 + 4*boneCount;
    mocapFrames = cell(frameCount, 1);
    for f = 1:frameCount
        frameData = fscanf(fid, '%f', numNumbersPerFrame);
        if numel(frameData) < numNumbersPerFrame
            error('Not enough data in frame %d', f);
        end
        mocapFrames{f} = frameData;
    end
    fclose(fid);
end
