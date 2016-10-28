function ErrorInfo = createSpikeFileForm(ErrorInfo)
%
% Sets the structure for all spike-related files (nto for decoding since those could also have LFP data)
%
% INPUT
%
%
%
% Author : Andres. Following some guidelines used in createFileForm.m from offlineBCI (Scott Brincat)
% 
% Andres :  init    : 21 Oct 2014
% Andres :  


%% Get spike root filename
% Units lumped or not
if ErrorInfo.spikeInfo.lumpUnits, lumpStr = '-lumped';
else lumpStr = '-unlumped';
end
% Sorted or unsorted units
if ErrorInfo.spikeInfo.manSorted
    sortedStr = '-manSorted';
else
    switch ErrorInfo.spikeInfo.spikeType
        case 'sorted',      sortedStr = '-sorted';
        case 'unsorted',    sortedStr = '-unsorted';
        otherwise,          error('Spike type %s does not exist!!',ErrorInfo.spikeInfo.spikeType)
    end
end
% Channels with units only
if ErrorInfo.spikeInfo.useChnlsWithUnitsOnly, withUnitsStr = '-chsWithUnitsOnly';
else withUnitsStr = '';
end
% Root string to append to all files with these parameters
ErrorInfo.spikeInfo.txtRoot = sprintf('%s%s%s',withUnitsStr,sortedStr,lumpStr);


