function outputMatrix = fixEpochs3dims(inputMatrix)
% function outputMatrix = fixEpochs3dims(inputMatrix)
% 
% For matrices that are expected to be 3 dims, [nChs x nTrials x nSamples]
% checks this is actually true and, if no, fixes dimensionality to match
% it. It the file only has [nChs x nSamples], it is turned in [nChs x 1 x nSamples], 
% if the file is empty do nothing.
%
%
% Author    : Andres
%
% Andres    : v.1   : init. 06 Nov 2014

if ~isempty(inputMatrix)                    % if empty do nothing let other code handle it!!
    matrixSz = size(inputMatrix);
    matrixDims = ndims(inputMatrix);
    if matrixDims == 2
        % Has two dimensions but is not empty. Fix
        outputMatrix = reshape(inputMatrix,[matrixSz(1),1,matrixSz(2)]); 
        disp('Two dims...adding the one in the middle!!')
    else
        outputMatrix = inputMatrix;         % already a 3 dims file
        disp('Already 3 dims...doing nothing')
    end
else
    outputMatrix = inputMatrix;             % leave the way it is, other code will handle it
    disp('Empty matrix, no dims...doing nothing')
 end
 
 
 
 