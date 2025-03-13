function A3(taskNumber) 
% A3 - Main function for Assignment 3
    %
    % Usage:
    %   A3(taskNumber)
    % where taskNumber is an integer between 1 and 6.

    % adding lib folder and src folder
    addpath(genpath('../lib'));

    % Check input validity
    if nargin < 1 || ~ismember(taskNumber, 1:6)
        error('Please provide a task number between 1 and 6, e.g., A3(1)');
    end

    % Create output folders if they don't exist
    for k = 1:6
        folderName = fullfile('..', sprintf('output%d', k));
        if ~exist(folderName, 'dir')
            mkdir(folderName);
        end
    end

    switch taskNumber
        case 1
            routineOne(true);
        case 2
            routineTwo(true, true, true);
        case 3
            routineThree(true, true, true);
        case 4
            routineFour(true, true, true);
        case 5
            routineFive();
        case 6
            routineSix();
        otherwise
            error('Task number not implemented');
    end

   
end
