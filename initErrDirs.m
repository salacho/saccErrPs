function [dirs] = initErrDirs
%
% This function defines directory and path initializations for code.
%
% The function determines appropriate Code and Data directories to use for 
% given hostname you are running Matlab on. Users must add list of appropriate 
% directories below w/in a switch case for their own hostname.
% 
% OUTPUT: 
%
%   dirs:           Struct containing list of directory names needed to run 
%                   the data analysis code:
%     Code:         Dir w/ data analysis code.
%     DataIn:       Dir where 'raw' datafiles are to be read from.
%     DataOut:      Dir where analyzed datafiles and figures are to be written to 
%
% This code is pretty simmilar to the one used in the BlackRock to npl
% (init2npl.m) dataConversion code set by Scot Brincat.

% Determine hostname of system 
[~,host]= system('hostname');
host      = deblank(host);

%% Set appropriate directories for code, data input and output, based on system hostname.

[~,host] = system('hostname');
host     = deblank(host);

switch host
    case 'Miller-PC'
        dirs.DataIn     = '\\millerlab.mit.edu\common\bciproject\cvm\mat';  %Add path where all sessions are located
        dirs.Code       = 'H:\Salachos_backup\Code\chronicRecord';          %Add dirs where all code is located
        dirs.DataOut    = 'C:\Users\Andres\Documents\Data\chico\mat';       %Add path where all processed data will be saved
    case 'Scott-Analysis';
        dirs.DataIn     = '\\millerlab.mit.edu\common\bciproject\cvm\mat';  %Add path where all sessions are located
        dirs.Code       = 'C:\Users\sbrincat\analysis\cvm\offlineBCI';      %Add dirs where all code is located
        dirs.DataOut    = 'C:\Users\sbrincat\data\cvm\crunch\offlineBCI';   %Add path where all processed data will be saved
    case 'MISHA-DESK'
        dirs.DataIn     = '\\millerlab.mit.edu\common\bciproject\cvm\mat';  %Add path where all sessions are located
        dirs.Code       = 'C:\Users\Andres\Documents\Code\chronicRecord';   %Add dirs where all code is located
        dirs.DataOut    = 'D:\Analysis\dlysac\ErrRPs';                      %Add path for chronic Recording analysis to be saved 
        dirs.BCIparams  = '\\millerlab.mit.edu\common\bciproject\cvm\raw';  %Add path where all BCIparams are located
        dirs.PTB        = 'C:\Users\Andres\Documents\MATLAB\toolbox\Psychtoolbox'; % Add path to PsychToolbox
    case 'Salachos-Carbon';
        dirs.Code       = '/Users/Salacho/Documents/BU/Miller Lab/chronicRecord';   % Dir w/ data analysis Code
        dirs.DataIn     = 'C:\Users\salacho\Documents\Data\dlySaccErrPs';        % Dir w/ raw datafiles
        dirs.DataOut    = '/Users/Salacho/Documents/BU/Miller Lab/data/analyzed'; 	% Dir to output analyzed datafiles and figures to
    case 'Salachos-CNS'
        dirs.Code       = 'C:\Users\salacho\Documents\Code\dlySaccErrPs';      % Dir w/ data analysis Code
        dirs.helpers       = 'C:\Users\salacho\Documents\Code\helpers';      % Dir w/ helpers analysis Code
        dirs.DataIn     = 'Z:\data\common\bciproject\cvm\mat';                  % Dir w/ datafiles. Mapping server using SFTP Net Drive
        dirs.DataOut    = 'C:\Users\salacho\Documents\Analysis\dlySaccErrPs';  % Local Dir to output analyzed datafiles and figures too
        dirs.BCIparams  = 'Z:\data\common\bciproject\cvm\raw';                  %Add path where all BCIparams are located
        dirs.PTB        = 'C:\Users\salacho\Documents\MATLAB\toolbox\Psychtoolbox'; % Add path to PsychToolbox
        dirs.chronux    = 'C:\Users\salacho\Documents\MATLAB\toolbox\chronux';            % Add path to chronux toolbox
        addpath(dirs.helpers)
    otherwise
        disp('No paths have been estalished')
end

% Set up path so code is accessible to Matlab
addpath(dirs.DataIn);               % Add dir w/ your Data path
addpath(genpath(dirs.Code));        % Add dir w/ your code path
addpath(genpath(dirs.PTB));         % Add dir w/PsychToolbox code
addpath(genpath(dirs.chronux));     % Add dir w/chronux code
