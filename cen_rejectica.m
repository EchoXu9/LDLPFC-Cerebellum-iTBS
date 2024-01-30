function postica = cen_rejectica(interp,comps)

for m = 1:length(interp)
        
    % Remove non-EEG channels
    cfg             = [];
    cfg.channel     = {'all','-ECG','-HEOG','-VEOG','-Marker'};
    interp(m)       = ft_selectdata(cfg,interp(m));

    % Create ind component time series using original data
    cfg             = [];
    cfg.unmixing    = comps.unmixing; % NxN unmixing matrix
    cfg.topolabel   = comps.topolabel; % Nx1 cell-array with the channel labels
    cfg.channel     = 1:64;
    comp_orig       = ft_componentanalysis(cfg,interp(m));

    % Original data reconstructed excluding rejected components
    cfg             = [];
    cfg.component   = comps.rejected;
    cfg.channel     = 1:64;
    postica(m)      = ft_rejectcomponent(cfg,comp_orig,interp(m));
end
end