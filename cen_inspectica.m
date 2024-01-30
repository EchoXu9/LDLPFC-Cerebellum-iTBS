function comps = cen_inspectica(comps)
% Identify which components are to be removed
% Done through automated process with follow-up visual confirmation
% Automated process to suggest components for removal
% Plot, inspect, and identify first 25 ICs for removal (Display 5 x 5)
% At the prompt, list the components to reject
% Example: [3,6,7,8,9];

%% Automated ICA inspection
[blinks, eye_movements, muscle, gen_disc, suggested_comps, all_art] = cen_autoica(comps);

%% Visual ICA inspection
cen_plotica(comps,suggested_comps);

% plot the components for visual inspection
% figure
% cfg = [];
% cfg.component = 1:32;       % specify the component(s) that should be plotted
% cfg.layout    = 'easycapM1.mat'; % specify the layout file that should be used for plotting
% cgf.comment   = 'no';
% ft_topoplotIC(cfg, comps)

% further inspection
% cfg = [];
% cfg.layout = 'easycapM1.mat'; % specify the layout file that should be used for plotting
% cfg.viewmode = 'component';
% ft_databrowser(cfg, comps)

%% List components for rejection
% Suggestion of components to remove
disp('Automated ICA reject components are:')
disp(['Blinks: ', num2str(blinks)]);
disp(['Lateral eye movements: ', num2str(eye_movements)]);
disp(['Generic discontinuities: ', num2str(gen_disc)]);
disp(['Muscle: ', num2str(muscle)]);
disp(['All artifacts: ', num2str(all_art)]);
disp('.');
disp(['Suggested: ', num2str(suggested_comps)]);

%% Create prompt for user to include which components need to be rejected
prompt          = 'list components to reject. Approximately 10-15% of total:';
x               = input(prompt);
comps.rejected  = x;
close
end
