function reref = cen_avg_reref(postica)

% Rereference
cfg             = [];
cfg.channel     = 'all';
cfg.refchannel  = 'all';
cfg.reref       = 'yes';
cfg.refmethod   = 'avg';
cfg.trials      = 'all';

for n = 1:length(postica)
    reref(n) = ft_preprocessing(cfg,postica(n));
end

% Add event and block-name structures to file
for o = 1:length(postica)
    reref(o).event = postica(o).event;
    reref(o).block = postica(o).block;
end

end

%% Define EEG channels

noteegchannels  = find(ismember(trials(1).label, {'ECG', 'HEOG', 'VEOG', 'Marker'}));
eegchannels     = setdiff(1:length(trials(1).label), noteegchannels);

%% Rereferencing
cfg             = [];
cfg.refchannel  = eegchannels;
cfg.channel     = 'all';
cfg.reref       = 'yes';
cfg.refmethod   = 'avg';
cfg.trials      = 'all';

% Loop and rereference
for t = 1:3
    newtrials(t) = ft_preprocessing(cfg,trials(t));
end

% Add event and block-name structures to file
for o = 1:length(newtrials)
    newtrials(o).event = trials(o).event;
    newtrials(o).block = trials(o).block;
end
