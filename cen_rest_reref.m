function reref = cen_rest_reref(postica)

% Add following paths/files
addpath '/Users/echo/Library/CloudStorage/OneDrive-UNSW/Brain_Stimulation/EEG_training/scripts/REST/';


% Load rereferencing files to align with cap
load('REF_LABELS.mat')

% Remove any other rereferences variables
clear reref

for r = 1:length(postica)
    
    % Convert 'FPz' to 'Fpz' - if necessary
    postica(r).label(strcmp(postica(r).label,'FPz')) = {'Fpz'};
    
    % Identify correct leadfield
    if sum(ismember(REF_LABELS{1},postica(r).label)) == 64
        load('leadfield_oldcap.mat')
        leadfield = leadfield_oldcap;
    elseif sum(ismember(REF_LABELS{2},postica(r).label)) == 64
        load('leadfield_newcap.mat')
        leadfield = leadfield_newcap;
    elseif sum(ismember(REF_LABELS{3},postica(r).label)) == 64
        load('leadfield_newestcap.mat')
        leadfield = leadfield_newestcap;
    else
        error('The channels do not match the leadfield - recalculate the leadfield using brainstorm')
    end
    
    % Calculate gain_constrained leadfield
    leadfield_gain_constrained = bst_gain_orient(leadfield.Gain,leadfield.GridOrient);
    
    % Match channel order
    [ischan,channumber]                     = ismember(leadfield.label,postica(r).label);
    leadfield_sorted(channumber(ischan),:)  = leadfield_gain_constrained(ischan,:);
    
    % Rereference all trials
    for t = 1:length(postica(r).trial)
        data                = double(postica(r).trial{t});
        [Nc, ~]             = size(data);
        H                   = rREST_Hsc(Nc,20);
        
        % REST
        REST_ref            = leadfield_sorted * pinv(H * leadfield_sorted, 0.05) * H;
        temp(r).trial{t}    = REST_ref * data;
    end
    
    % Create reref structure
    reref(r)        = postica(r);
    reref(r).trial  = temp(r).trial;
end