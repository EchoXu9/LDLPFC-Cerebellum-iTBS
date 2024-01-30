function trials = cen_trials(events)
% Segments the data into trials 

%% Create rsEEG trials
EEG             = find(strcmp({events.event.type},'RS-EEG'));
chs             = 1:length(events.label);

for s = 1:length(EEG)
    tempdata    = events;
    EEG_start   = tempdata.event(EEG(s)).sample;
    EEG_end     = tempdata.event(EEG(s)).sample + tempdata.event(EEG(s)).sampdur - 1;
    index       = EEG_start:EEG_end;

    % Amount of full 1sec segments that can be extracted from trial data
    total_secs  = floor(length(index)/tempdata.fsample);
    remainder   = length(index) - total_secs * tempdata.fsample;
    
    % Ignore first <1s remainder of data and keep the rest
    A = tempdata.trial{1}(chs,index((remainder + 1):end));
    B = mat2cell(A,length(chs),repmat(tempdata.fsample,total_secs,1));
    tempdata.trial          = B;

    C = tempdata.time{1}(1,index((remainder + 1):end));
    D = mat2cell(C,1,repmat(tempdata.fsample,total_secs,1));
    tempdata.time           = D;
    
    for t = 1:length(tempdata.trial)
        tempevent(t).type       = 'eeg';
        tempevent(t).value      = events.event(EEG).value;
        tempevent(t).sample     = index(remainder + 1) + ((t - 1) * tempdata.fsample);
        tempevent(t).timestamp  = tempdata.time{t}(1,1);
        tempevent(t).sampdur    = size(tempdata.trial{t},2);
        tempevent(t).duration   = tempevent(t).sampdur/tempdata.fsample;
    end
    
    tempdata.sampleinfo     = [];
    tempdata.sampleinfo(:,1)= index(remainder + 1):tempdata.fsample:EEG_end;
    tempdata.sampleinfo(:,2)= [(tempdata.sampleinfo(2:end,1) - 1); EEG_end];
    tempdata.event          = tempevent;
    tempdata.block          = 'RS-EEG';

    trials(s) = tempdata;    
end

%% N-BACK
PRE_STIM    = 0.5; % seconds
POST_STIM   = 1.5; % seconds

% Find blocks - last i_nback is the end of the session
nback_stimuli = find(contains({events.event.type},'NBACK HIT'));

% Get number of blocks in trials
row = length(trials);

% Initialise empty variables
temptrial   = [];
temptime    = [];
sampleinfo  = [];
tempdata    = [];

% Create n-back trials
for f = 1:length(nback_stimuli)
    index_start     = events.event(nback_stimuli(f)).sample - round((events.fsample * PRE_STIM));
    index_end       = events.event(nback_stimuli(f)).sample + round((events.fsample * POST_STIM)) - 1;
    temptrial{f}    = events.trial{1}(chs,index_start:index_end);
    temptime{f}     = -PRE_STIM:1/events.fsample:(POST_STIM - (1/events.fsample));  % data.time{1}(1,index_start:index_end);
    sampleinfo(f,:) = [index_start, index_end];
end

tempdata            = events;
tempdata.trial      = temptrial;
tempdata.time       = temptime;
tempdata.sampleinfo = [];
tempdata.sampleinfo = sampleinfo;
tempdata.event      = events.event(nback_stimuli);
tempdata.block      = 'NBACK';

trials(row + 1)   = tempdata;

%% STROOP
PRE_STIM    = 0.5; % seconds
POST_STIM   = 1.5; % seconds

% Find blocks - last i_nback is the end of the session
stroop_stimuli = find(contains({events.event.type},'STROOP HIT'));

% Get number of blocks in trials
row = length(trials);

% Initialise empty variables
temptrial   = [];
temptime    = [];
sampleinfo  = [];
tempdata    = [];

% Create stroop trials
for f = 1:length(stroop_stimuli)
    index_start     = events.event(stroop_stimuli(f)).sample - round((events.fsample * PRE_STIM));
    index_end       = events.event(stroop_stimuli(f)).sample + round((events.fsample * POST_STIM)) - 1;
    temptrial{f}    = events.trial{1}(chs,index_start:index_end);
    temptime{f}     = -PRE_STIM:1/events.fsample:(POST_STIM - (1/events.fsample));  % data.time{1}(1,index_start:index_end);
    sampleinfo(f,:) = [index_start, index_end];
end

tempdata            = events;
tempdata.trial      = temptrial;
tempdata.time       = temptime;
tempdata.sampleinfo = [];
tempdata.sampleinfo = sampleinfo;
tempdata.event      = events.event(stroop_stimuli);
tempdata.block      = 'STROOP';

trials(row + 1)   = tempdata;
