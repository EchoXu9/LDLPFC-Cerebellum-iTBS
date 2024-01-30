function data = cen_events(data)

%% Parameters
MARKER      = strcmp(data.label,'Marker');

% NBACK
% 254 - correct hit to target
% 253 - correct response to non-target
% 252 - false alarm to target/non-tartet
% 251 - target stimulus
% 250 - non-target stimulus

% RESTING STATE
% 248 - start of resting state
% 247 - end of resting state

% STROOP
% 244 - congruent
% 243 - incongruent
% 246 - hit
% 245 - false alarm

%% Find trigger values
i               = [];
trigger         = data.trial{1}(MARKER,:);
trigger(trigger == 0) = 1;
trigger(1)      = 100;                      % set initial trigger to value 100
trigger(2)      = 101;
trigger(end)    = 100;                      % set final trigger to end value 100   
dif_trigger     = [0,diff(trigger)~=0];     % is 1 when value changes
trigger         = trigger.*dif_trigger;     % set trigger to 0 if it doesn't change
i               = find(trigger);            % indices of triggers

event_data      = [];
event_data(:,1) = trigger(i);                    % Value of the amplifier (252:255)
event_data(:,2) = i;                             % Sample location of the events
event_data(:,3) = i/data.fsample;                % Time of event in seconds
event_data(:,4) = [diff(event_data(:,2)); 0];    % Duration of events in samples
event_data(:,5) = event_data(:,4)/data.fsample;  % Duration of events in seconds

short_trls      = event_data(:,5) < 1e-03;
short_trls(1)   = 0;
event_data(short_trls,:) = [];

%% Categorise events
% RESTING STATE
event_data(event_data(:,5) > 270 & event_data(:,5) < 330 & event_data(:,1) == 248,6) = 1; % Resting state

% NBACK
event_data(event_data(1:end-1,1) == 251 & event_data(2:end,1) == 254,6) = 2; % Hit targets
event_data(event_data(1:end-1,1) == 250 & event_data(2:end,1) == 253,6) = 3; % Hit non-targets
event_data(event_data(1:end-1,1) == 251 & event_data(2:end,1) == 252,6) = 4; % FA targets
event_data(event_data(1:end-1,1) == 250 & event_data(2:end,1) == 252,6) = 5; % FA non-targets
event_data((event_data(1:end-1,1) == 251 | event_data(1:end-1,1) == 250) & ...
    (event_data(2:end,1) == 251 | event_data(2:end,1) == 250)) = 6; % Miss

% STROOP
event_data(event_data(1:end-1,1) == 244 & event_data(2:end,1) == 246,6) = 7; % Cong Hit
event_data(event_data(1:end-1,1) == 244 & event_data(2:end,1) == 245,6) = 8; % Cong FA
event_data(event_data(1:end-1,1) == 243 & event_data(2:end,1) == 246,6) = 9; % Incong Hit
event_data(event_data(1:end-1,1) == 243 & event_data(2:end,1) == 245,6) = 10; % Incong FA

%% Create Events list
TRIGGERS = 1:10;
TYPE = {'RS-EEG',...
    'NBACK HIT TARGET','NBACK HIT NONTARGET',...
    'NBACK FA TARGET','NBACK FA NONTARGET','MISS',...
    'STROOP HIT CONG','STROOP FA CONG',...
    'STROOP HIT INCONG','STROOP FA INCONG'};

event_index = find(event_data(:,6));
for n = 1:length(event_index)
    [~,j] = intersect(TRIGGERS,event_data(event_index(n),6));
    data.event(n).type      = TYPE{j};                       % event type (hit etc...)
    data.event(n).value     = event_data(event_index(n),1);  % trigger value
    data.event(n).sample    = event_data(event_index(n),2);  % sample index
    data.event(n).timestamp = event_data(event_index(n),3);  % time of event
    data.event(n).sampdur   = event_data(event_index(n),4);  % duration (samples)
    data.event(n).duration  = event_data(event_index(n),5);  % duration (seconds)
end

end