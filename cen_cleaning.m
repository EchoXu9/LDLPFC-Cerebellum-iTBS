function allrej = cen_cleaning(input)

% Automatic rejection of trials    
for row = 1:length(input)
    autorej(row) = cen_trialrejection(input(row));
end

% instructions
fprintf('\nINSPECT DATA AND NOTE ITEMS FOR REJECTION IN SEPARATE SPREADSHEET\n\n')

% inspect all trials (without rejecting yet) - this is doe to get an
% overall feel for the quality of the data
for a = 1:length(autorej)
    % Define eeg channels 
    noteegchannels  = find(ismember(autorej(a).label, {'ECG', 'HEOG', 'VEOG', 'Marker'}));
    eegchannels     = setdiff(1:length(autorej(a).label), noteegchannels);
    
    % Quick visual inspection of all trials - identify possible BAD trials
    cfg             = [];
    cfg.channel     = eegchannels;
    cfg.viewmode    = 'butterfly'; % butterfly/vertical
    cfg.alim        = [-100 100];
    cfg.ylim        = [-100 100];
    cfg.blocksize   = round(autorej(a).time{1}(end) - autorej(a).time{1}(1));
    cfg.continuous  = 'no';
    cfg.colorgroups = 'sequential'; 
    cfg.layout      = 'easycapM1.mat';
    
    % Note down potential trials for rejection in separate spreadsheet
    ft_databrowser(cfg,autorej(a))
end

% Select and remove BAD trials and channels using visual inspection 
for a = 1:length(autorej)
    cfg                 = [];
    cfg.method          = 'trial';
    cfg.eegscale        = 1.0;
    cfg.eogscale        = 0.1;
    cfg.ecgscale        = 0.05;
    cfg.emgscale        = 1.0;
    cfg.preproc.detrend = 'yes';
    cfg.preproc.demean  = 'yes';
    visrej(a)   = ft_rejectvisual(cfg,autorej(a));
end

% Select and remove BAD trials and channels using summary statistics
for a = 1:length(visrej)
    cfg         = [];
    cfg.channel	= {'all','-ECG','-HEOG','-VEOG','-Marker'};
    cfg.method  = 'summary';
    cfg.metric  = 'var'; % or: 'zvalue';
    allrej(a)   = ft_rejectvisual(cfg,visrej(a));
end

end