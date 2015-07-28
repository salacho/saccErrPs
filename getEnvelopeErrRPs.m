function [envelopCorrEpochs,envelopCorrMean,envelopIncorrEpochs,envelopIncorrMean] = getEnvelopeErrRPs(corrEpochs,incorrEpochs)
% function [envelopCorrEpochs,envelopCorrMean,envelopIncorrEpochs,envelopIncorrMean] = getEnvelopeErrRPs(corrEpochs,incorrEpochs)
%
%
%
%
%
%
% 

% Averaged ErrRPs per channel 
corrMean = squeeze(mean(corrEpochs,2));
incorrMean = squeeze(mean(incorrEpochs,2));

%% Hilbert envelope

% Pre-allocating memory to vbles
% Correct epochs
[nChs,nTrials,nPoints] = size(corrEpochs);
envelopCorrEpochs = nan(nChs,nTrials,nPoints); 
envelopCorrMean = nan(nChs,nPoints); 
% Incorrect epochs
[nChs,nTrials,nPoints] = size(incorrEpochs);
envelopIncorrEpochs = nan(nChs,nTrials,nPoints);
envelopIncorrMean = nan(nChs,nPoints);

tStart = tic;       % start of analysis
% Calculating the envelope of the signals
for iCh = 1:nChs
    % Envelope for averaged epochs
    disp(sprintf('Calculating envelope for ch%i',iCh));
    envelopCorrMean(iCh,:) = abs(hilbert(corrMean(iCh,:)));                 % envelope for each channels (being each channel the average of all correct epochs) 
    envelopIncorrMean(iCh,:) = abs(hilbert(incorrMean(iCh,:)));             % envelope for each channels (being each channel the average of all incorrect epochs)
    
    % Envelope for each epoch
    if size(corrEpochs,2) >= size(incorrEpochs,2)                           % More correct than incorrect trials
        lastEpoc = size(incorrEpochs,2);
        for iEpoc = 1:lastEpoc                                              % Both correct and incorrect trials
            envelopCorrEpochs(iCh,iEpoc,:) = abs(hilbert(corrEpochs(iCh,iEpoc,:)));
            envelopIncorrEpochs(iCh,iEpoc,:) = abs(hilbert(incorrEpochs(iCh,iEpoc,:)));
        end
        for iEpoc = lastEpoc+1:size(corrEpochs,2)                           % Rest of correct epochs, incorrect ones are done 
            envelopCorrEpochs(iCh,iEpoc,:) = abs(hilbert(corrEpochs(iCh,iEpoc,:)));
        end
    else                                                                    % More incorrect than correct trials    
        lastEpoc = size(corrEpochs,2);                                      % Both correct and incorrect trials
        for iEpoc = 1:lastEpoc
            envelopCorrEpochs(iCh,iEpoc,:) = abs(hilbert(corrEpochs(iCh,iEpoc,:)));
            envelopIncorrEpochs(iCh,iEpoc,:) = abs(hilbert(incorrEpochs(iCh,iEpoc,:)));
        end
        for iEpoc = lastEpoc+1:size(incorrEpochs,2)                         % Rest of incorrect epochs, correct ones are finished
            envelopIncorrEpochs(iCh,iEpoc,:) = abs(hilbert(incorrEpochs(iCh,iEpoc,:)));
        end
    end
end
tElapsed = toc(tStart);
disp(sprintf('It took %0.2f mins. to calculate the envelopes for all epochs',tElapsed/60))
