function [comps] = cen_ica(interp)

% Concatenate data structure to allow ICA
ICA_data    = cen_icadata(interp);

% ICA
cfg         = [];
cfg.method  = 'runica';
cfg.channel = 1:64;
cfg.numcomponent = 32;

comps = ft_componentanalysis(cfg,ICA_data);
end