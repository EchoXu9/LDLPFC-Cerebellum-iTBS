function data = cen_events_errorcorrection(data)

%% Parameters
MARKER      = strcmp(data.label,'Marker');

%% Triggers
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
% 244/252 - congruent
% 243/251 - incongruent
% 246/254 - hit
% 245/253 - false alarm

%%
trigger_data    = data.trial{1}(MARKER,:);
diff_signal     = [0 diff(trigger_data)];

%% Fix trigger values corrupted by 8-bit shift
% Identify negative deflections as well as positives
neg_change = find(diff_signal <= -6 & diff_signal > -250); % or neg_change = find(diff_signal == -8);
any_change = find(diff_signal > 0);

% Exclude negative changes associated with resting state signal
neg_change(trigger_data(neg_change) == 248) = [];

% Find samples between a large neg deflection and the return to normal
neg_eight_end = zeros(1,length(neg_change));
for n = 1:length(neg_change)
    next_change = find(any_change > neg_change(n));
    neg_eight_end(n) = any_change(next_change(1));
end

% Create a fixed trigger data variable
fixed_trigger_data = trigger_data;

for n2 = 1:length(neg_change)
    fixed_trigger_data(neg_change(n2):neg_eight_end(n2)-1) = fixed_trigger_data(neg_change(n2):neg_eight_end(n2)-1) + 8;
end

% Identify low trigger values and fix by adding 8
low_vals = find(fixed_trigger_data < 247);
fixed_trigger_data(low_vals) = fixed_trigger_data(low_vals) + 8;

%% Plot fixed and original data (with deflection to see the change)
figure; 
plot(fixed_trigger_data,'color','black')
hold on
plot(trigger_data-40)

%% Find trigger values
i               = [];
trigger         = fixed_trigger_data;
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

%% 
% RESTING STATE
event_data(event_data(:,5) > 270 & event_data(:,5) < 330 & event_data(:,1) == 248,6) = 1; % Resting state

% identify split between task trials
task_split = find(event_data(:,1) == 255 & event_data(:,5) > 110);
task_split = task_split(end); 

% identify congruent stroop hits with 8-bit error
error_cong_hit = find(event_data(1:end-1,1) == 252 & event_data(2:end,1) == 254); % Cong Hit

% adjust values with 8-bit shift
if sum(error_cong_hit > task_split) == length(error_cong_hit)
    % stroop occurs after the task split; adjust post split with '-8'
    post_index = find(event_data(task_split+1:end,1) ~= 255);
    post_index = post_index + task_split; 
    
    event_data(post_index,1) = event_data(post_index,1) - 8;
    
elseif sum(error_cong_hit < task_split) == length(error_cong_hit)
    % stroop occurs before the task split
    task_split2 = find(event_data(:,1) == 255 & event_data(:,5) > 20);
    task_split2 = task_split2(1);
    
    pre_index   = find(event_data(task_split2+1:task_split,1) ~= 255);
    pre_index   = pre_index + task_split2;
    
    event_data(pre_index,1) = event_data(pre_index,1) - 8;
else 
    error('something went wrong, check the data')
    
end

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
event_data(event_data(1:end-1,1) == 244 & event_data(2:end,1) == 255,6) = 11; % Cong Miss
event_data(event_data(1:end-1,1) == 243 & event_data(2:end,1) == 255,6) = 12; % Incong Miss

%% Create Events list
TRIGGERS = 1:12;
TYPE = {'RS-EEG',...
    'NBACK HIT TARGET','NBACK HIT NONTARGET',...
    'NBACK FA TARGET','NBACK FA NONTARGET','MISS',...
    'STROOP HIT CONG','STROOP FA CONG',...
    'STROOP HIT INCONG','STROOP FA INCONG',...
    'STROOP MISS CONG','STROOP MISS INCONG'};

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

%% Plot fixed trigger labels
SCATTER_SIZE    = 10;
RS_TRIGGERS     = contains({data.event.type},'RS');
NBACK_TRIGGERS  = contains({data.event.type},'NBACK');
STROOP_TRIGGERS = contains({data.event.type},'STROOP');

hold on
scatter([data.event(RS_TRIGGERS).sample],[data.event(RS_TRIGGERS).value],SCATTER_SIZE,[0.8941,0.1020,0.1098],'filled')
scatter([data.event(NBACK_TRIGGERS).sample],[data.event(NBACK_TRIGGERS).value],SCATTER_SIZE,[0.2157,0.4941,0.7216],'filled')
scatter([data.event(STROOP_TRIGGERS).sample],[data.event(STROOP_TRIGGERS).value],SCATTER_SIZE,[0.3020,0.6863,0.2902],'filled')

legend({'fixed trigger','original shifted','RS','NBACK','STROOP'},'Location','southeast')

%%
end

