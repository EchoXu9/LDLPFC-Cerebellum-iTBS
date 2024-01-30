function stroop_erp = cen_stroop_erp(reref)

BASE    = [-0.5 0.0]; % [-0.5 -0.2];

% Find STROOP blocks
clear stroop
stroop_index    = find(contains({reref.block},'STROOP'));

% Find congruent and incongruent trials
incong_index    = contains({reref(stroop_index).event.type},'INCONG');

% Baseline correction
cfg             = [];
cfg.channel     = 'all';
cfg.baseline    = BASE;
temp            = ft_timelockbaseline(cfg,reref(stroop_index));

% Averaging congruent trials
cfg             = [];
cfg.covariance  = 'yes';
cfg.trials      = find(~incong_index);
stroop_erp(1)   = ft_timelockanalysis(cfg,temp);

% Averaging incongruent trials
cfg.trials      = find(incong_index);
stroop_erp(2)   = ft_timelockanalysis(cfg,temp);

% Label files
stroop_erp(1).stimtype   = 'CONGRUENT';
stroop_erp(2).stimtype   = 'INCONGRUENT';

end