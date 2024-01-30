%% CEN TMS: RESTING STATE EEG AND ERP ANALYSIS PIPELINE
% <<< INSERT DESCRIPTION >>
% The pipeline below processes source data, supplied in a fieldtrip
% structure and saved as .mat, to generate resting state eeg (rs-eeg) and
% erp data
%
% These tasks:
%   2-back task
%   Stroop

%% Add paths to toolboxes/dependencies


restoredefaultpath
addpath '/Users/echo/Library/Application Support/MathWorks/MATLAB Add-Ons/Collections/fieldtrip-20191213';
addpath '/Users/echo/Library/CloudStorage/OneDrive-UNSW/Brain_Stimulation/EEG_training/scripts'/'ica check'/;


%% Loop through subjets and process data one at a time 
FIELDTRIP     = 0;
DIR_SRC       = '/Volumes/CEN/CEN_EEG_ANALYSE';

%% read and save raw data into fieldtrip

% Load Data
VAR     = 'data';
INFOLD  = '0-polybench';
OUTFOLD = '1-rawdata'; 

 load(fullfile('cen_participants.mat'))

for p = 1:height(cen_participants)
    if cen_participants.rawdata(p)==0
        % Generate eeg filename
        file        = string(cen_participants.filename_eeg(p));
        filename    = fullfile(DIR_SRC,INFOLD,strcat(file, '.DATA.Poly5'));
        
        % Read data into fieldtrip format from Poly5
        data        = cen_readTMSi(filename);
        
        % Save output
        fullpath1 = fullfile(DIR_SRC,OUTFOLD, file);
        save(fullpath1, VAR, '-v7.3');

        % Update participant file to say process is completed
        cen_participants.rawdata(p) = 1;
        save cen_participants.mat cen_participants
    end
end

%% line noise removal and filtering

% Load Data
VAR     = 'preproc';
INFOLD  = '1-rawdata';
OUTFOLD = '2-preproc'; 

% Participants
load(fullfile('cen_participants.mat'));

for p = 1:height(cen_participants)
    if cen_participants.preproc(p)==0
        % Generate eeg filename
        file        = string(cen_participants.filename_eeg(p));
        filename    = fullfile(DIR_SRC,INFOLD,strcat(file,'.mat'));

        % Load eeg data
        load(filename);
        
        % Line noise removal/filtering of EEG 
        preproc     = cen_preprocess(data);
        
        % Save output
        fullpath1 = fullfile(DIR_SRC,OUTFOLD,file);
        save(fullpath1,VAR,'-v7.3');

        % Update participant file to say process is completed
        cen_participants.preproc(p) = 1;
        save cen_participants.mat cen_participants
    end
end
    
%% generate rseeg and erp events

% Load Data
VAR     = 'events';
INFOLD  = '2-preproc';
OUTFOLD = '3-events'; 

% Participants
load(fullfile('cen_participants.mat'));

for p = 1:height(cen_participants)
    if cen_participants.events(p)==0
        % Generate eeg filename
        file        = string(cen_participants.filename_eeg(p));
        filename    = fullfile(DIR_SRC,INFOLD,strcat(file,'.mat'));

        % Load eeg data
        load(filename);
        
        % Generate rseeg and erp events 
        events     = cen_events_errorcorrection(preproc);
        
        % Save output
        fullpath1 = fullfile(DIR_SRC,OUTFOLD,file);
        save(fullpath1,VAR,'-v7.3');

        % Update participant file to say process is completed
        cen_participants.events(p) = 1;
        save cen_participants.mat cen_participants
    end
end

    
%% segment the data into trials/epochs

% Load Data
VAR     = 'trials';
INFOLD  = '3-events';
OUTFOLD = '4-trials'; 

% Participants
load(fullfile('cen_participants.mat'));

for p = 1:height(cen_participants)
    if cen_participants.trials(p)==0
        % Generate eeg filename
        file        = string(cen_participants.filename_eeg(p));
        filename    = fullfile(DIR_SRC,INFOLD,strcat(file,'.mat'));

        % Load eeg data
        load(filename);
        
        % Segment the data into trials
        trials     = cen_trials(events);
        
        % Save output
        fullpath1 = fullfile(DIR_SRC,OUTFOLD,file);
        save(fullpath1,VAR,'-v7.3');

        % Update participant file to say process is completed
        cen_participants.trials(p) = 1;
        save cen_participants.mat cen_participants
    end
end
  
%% visual inspection and trial/channel rejection

 % Load Data
VAR     = 'reject';
INFOLD  = '4-trials';
OUTFOLD = '5-reject'; 

% Participants
load(fullfile('cen_participants.mat'));

 for p = 1:height(cen_participants)
    if cen_participants.reject(p)==0
        % Generate eeg filename
        file        = string(cen_participants.filename_eeg(p));
        filename    = fullfile(DIR_SRC,INFOLD,strcat(file,'.mat'));

        % Load eeg data
        load(filename);

        % Selectively run this line to remove noisy channels
        % trials      = cen_remochannel(trials)
        
        % Visual inspection and trial/channel rejection
        reject      = cen_cleaning(trials);
        
        % Save output
        fullpath1   = fullfile(DIR_SRC,OUTFOLD,file);
        save(fullpath1,VAR,'-v7.3');

        % Update participant file to say process is completed
        cen_participants.reject(p) = 1;
        save cen_participants.mat cen_participants
    end
end

%% interpolate removed channels

% Load Data
VAR      = 'interp';
INFOLD1  = '4-trials';
INFOLD2  = '5-reject';
OUTFOLD  = '6-interp'; 

% Participants
load(fullfile('cen_participants.mat'));

for p = 1:height(cen_participants)
    if cen_participants.interp(p)==0
        % Generate eeg filename
        file        = string(cen_participants.filename_eeg(p));
        filename1    = fullfile(DIR_SRC,INFOLD1,strcat(file,'.mat'));
        filename2    = fullfile(DIR_SRC,INFOLD2,strcat(file,'.mat'));

        % Load eeg data
        load(filename1);
        load(filename2);
        
        % interpolate removed channels
        interp  = cen_interp(reject,trials);

        % Save output
        fullpath1   = fullfile(DIR_SRC,OUTFOLD,file);
        save(fullpath1,VAR,'-v7.3');

        % Update participant file to say process is completed
        cen_participants.interp(p) = 1;
        save cen_participants.mat cen_participants
    end
end

   
%% ica cleaning

% Load Data
VAR      = 'ica';
INFOLD   = '6-interp'; 
OUTFOLD  = '7-ica'; 

% Participants
load(fullfile('cen_participants.mat'));

for p = 1:height(cen_participants)
    if cen_participants.ica(p)==0
        % Generate eeg filename
        file        = string(cen_participants.filename_eeg(p));
        filename    = fullfile(DIR_SRC,INFOLD,strcat(file,'.mat'));

        % Load eeg data
        load(filename);

        % ica cleaning
        ica   = cen_ica(interp);
        
        % Save output
        fullpath1   = fullfile(DIR_SRC,OUTFOLD,file);
        save(fullpath1,VAR,'-v7.3');

        % Update participant file to say process is completed
        cen_participants.ica(p) = 1;
        save cen_participants.mat cen_participants
    end
end

%% inspect ica components for rejection - addpath for icacheck
    
% Load Data
VAR      = 'comps';
INFOLD   = '7-ica';
OUTFOLD  = '8-comps'; 

% Participants
load(fullfile('cen_participants.mat'));

for p = 1:height(cen_participants)
    if cen_participants.comps(p)==0
        % Generate eeg filename
        file        = string(cen_participants.filename_eeg(p));
        filename    = fullfile(DIR_SRC,INFOLD,strcat(file,'.mat'));

        % Load eeg data
        load(filename);

        % Inspect ica components for rejection
        comps   = cen_inspectica(ica);
        
        % Save output
        fullpath1   = fullfile(DIR_SRC,OUTFOLD,file);
        save(fullpath1,VAR,'-v7.3');

        % Update participant file to say process is completed
        cen_participants.comps(p) = 1;
        save cen_participants.mat cen_participants
    end
end

%% reject ica components

% Load Data
VAR      = 'postica';
INFOLD1  = '6-interp';
INFOLD2  = '8-comps';
OUTFOLD  = '9-postica'; 

% Participants
load(fullfile('cen_participants.mat'));

for p = 1:height(cen_participants)
    if cen_participants.postica(p)==0
        % Generate eeg filename
        file        = string(cen_participants.filename_eeg(p));
        filename1    = fullfile(DIR_SRC,INFOLD1,strcat(file,'.mat'));
        filename2    = fullfile(DIR_SRC,INFOLD2,strcat(file,'.mat'));

        % Load eeg data
        load(filename1);
        load(filename2);
        
        % Reject ica components
        postica = cen_rejectica(interp,comps);

        % Save output
        fullpath1   = fullfile(DIR_SRC,OUTFOLD,file);
        save(fullpath1,VAR,'-v7.3');

        % Update participant file to say process is completed
        cen_participants.postica(p) = 1;
        save cen_participants.mat cen_participants
    end
end

%% rereferencing to common average
    %reref   = cen_avg_reref(postica);
    % rereferencing using regularised electrode standardisation technique
    %reref   = cen_rest_reref(postica);

% Load Data
VAR      = 'reref';
INFOLD   = '9-postica';
OUTFOLD  = '10-reref'; 

% Participants
load(fullfile('cen_participants.mat'));

for p = 1:height(cen_participants)
    if cen_participants.reref(p)==0
        % Generate eeg filename
        file        = string(cen_participants.filename_eeg(p));
        filename    = fullfile(DIR_SRC,INFOLD,strcat(file,'.mat'));

        % Load eeg data
        load(filename);

        % rereferencing using regularised electrode standardisation technique
        reref   = cen_rest_reref(postica);
        
        % Save output
        fullpath1   = fullfile(DIR_SRC,OUTFOLD,file);
        save(fullpath1,VAR,'-v7.3');

        % Update participant file to say process is completed
        cen_participants.reref(p) = 1;
        save cen_participants.mat cen_participants
    end
end


    %% erp - nback
    VAR      = 'nback_erp';
    INFOLD   = '10-reref';
    OUTFOLD  = '11-nback_erp';  
    
    % Participants
    load(fullfile('cen_participants.mat'));

 for p = 1:height(cen_participants)
    if cen_participants.nback_erp(p)==0
        % Generate eeg filename
        file        = string(cen_participants.filename_eeg(p));
        filename    = fullfile(DIR_SRC,INFOLD,strcat(file,'.mat'));

        % Load eeg data
        load(filename);

        % erp
        nback_erp   = cen_nback_erp(reref);
        
        % Save output
        fullpath1   = fullfile(DIR_SRC,OUTFOLD,file);
        save(fullpath1,VAR,'-v7.3');

        % Update participant file to say process is completed
        cen_participants.nback_erp(p) = 1;
        save cen_participants.mat cen_participants
    end
end
    %% erp - stroop
    VAR      = 'stroop_erp';
    INFOLD   = '10-reref';
    OUTFOLD  = '12-stroop_erp';  
    
    % Participants
    load(fullfile('cen_participants.mat'));

 for p = 1:height(cen_participants)
    if cen_participants.stroop_erp(p)==0
        % Generate eeg filename
        file        = string(cen_participants.filename_eeg(p));
        filename    = fullfile(DIR_SRC,INFOLD,strcat(file,'.mat'));

        % Load eeg data
        load(filename);

        % erp
        stroop_erp   = cen_stroop_erp(reref);
        
        % Save output
        fullpath1   = fullfile(DIR_SRC,OUTFOLD,file);
        save(fullpath1,VAR,'-v7.3');

        % Update participant file to say process is completed
        cen_participants.stroop_erp(p) = 1;
        save cen_participants.mat cen_participants
    end
end




