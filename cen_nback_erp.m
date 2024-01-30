function nback_erp = cen_nback_erp(reref)

BASE    = [-0.5 0.0]; % [-0.5 -0.2];

% Find NBACK blocks
clear nback
nback_index = find(contains({reref.block},'NBACK'));

% Find target and non-target hit trials
% target_index    = contains({reref(nback_index).event.type},'TARGET');
nontarget_index = contains({reref(nback_index).event.type},'NONTARGET');

% Baseline correction
cfg             = [];
cfg.channel     = 'all';
cfg.baseline    = BASE;
temp            = ft_timelockbaseline(cfg,reref(nback_index));

% Averaging target hit trials
cfg             = [];
cfg.covariance  = 'yes';
cfg.trials      = find(~nontarget_index);
nback_erp(1)    = ft_timelockanalysis(cfg,temp);

% Averaging nontarget hit trials
cfg             = [];
cfg.covariance  = 'yes';
cfg.trials      = find(nontarget_index);
nback_erp(2)    = ft_timelockanalysis(cfg,temp);

% Label files
nback_erp(1).stimtype   = 'TARGET';
nback_erp(2).stimtype   = 'NONTARGET';

end

%% aeverage both target and non-target hits
% BASE    = [-0.5 0.0]; % [-0.5 -0.2];
% 
% % Find NBACK blocks
% clear nback
% nback_index = find(contains({reref.block},'NBACK'));
% 
% % Average NBACK trials
% for t = 1:length(nback_index)
%     
%     % Baseline correction
%     cfg             = [];
%     cfg.channel     = 'all';
%     cfg.baseline    = BASE;
%     temp(t)         = ft_timelockbaseline(cfg,reref(nback_index(t)));
%     
%     % Averaging
%     cfg             = [];
%     cfg.covariance  = 'yes';
%     nback_erp(t)        = ft_timelockanalysis(cfg,temp(t));
% end
% 
% % Label files
% for t = 1:length(nback_index)
%     nback_erp(t).stimtype   = reref(nback_index(t)).block;
% end