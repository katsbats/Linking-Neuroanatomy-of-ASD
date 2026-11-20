% this script performs the holdout test. X.mat and Y.mat were copied from
% the pls_analysis data folder.
% Add toolkit to path
toolkit_dir = '/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Scripts/Matlab/RCCA/cca_pls_toolkit-master/';
cd(toolkit_dir); addpath(toolkit_dir); set_path;

% Project folder (contains the data/ subfolder with X.mat, Y.mat)
cfg.dir.project = '/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Scripts/Matlab/RCCA/cca_pls_toolkit-master/pls_holdout_two';

% Standard PLS correlation
cfg.machine.name = 'pls';

% Predictive framework (train/test split)
cfg.frwork.name = 'holdout';
cfg.frwork.split.nout = 10;
cfg.frwork.split.propout = 0.2;
cfg.frwork.split.nin = 50;

% Statistical inference
cfg.stat.nperm = 1000;

% Environment
cfg.env.comp = 'local';

% Update cfg with defaults
cfg = cfg_defaults(cfg);
%%
% Run analysis
main(cfg);

%% looking at results
lvl1 = fullfile(cfg.dir.frwork, 'res', 'level1');
T = readtable(fullfile(lvl1, 'results_table.txt'), 'FileType', 'text', 'Delimiter', '\t');

splits = T.split';
correl = T.correl';
pval   = T.pval';
bonf_thresh = 0.05 / numel(splits);  % 0.005
sig_uncorrected = pval < 0.05 & pval >= bonf_thresh;  % significant, but doesn't survive correction
sig_bonferroni  = pval < bonf_thresh;                  % survives Bonferroni
not_sig = ~sig_uncorrected & ~sig_bonferroni;
figure; hold on;
% stems down to zero, so each point still reads clearly against the axis
stem(splits, correl, 'Color', [0.7 0.7 0.7], 'LineStyle', ':', 'Marker', 'none');
scatter(splits(not_sig), correl(not_sig), 80, [0.6 0.6 0.6], 'filled');
scatter(splits(sig_uncorrected), correl(sig_uncorrected), 90, [0.9 0.6 0.2], 'filled');
scatter(splits(sig_bonferroni), correl(sig_bonferroni), 100, [0.8 0.2 0.2], 'filled', ...
'MarkerEdgeColor', 'k', 'LineWidth', 1.2);
yline(0, '--k', 'LineWidth', 1);
xlabel('Outer holdout split', 'FontWeight', 'bold');
ylabel('Out-of-sample correlation', 'FontWeight', 'bold');
xlim([0.5 10.5]);
xticks(1:10);
legend({'', 'Not significant', 'p < .05 (uncorrected)', 'p < .005 (Bonferroni)'}, ...
'Location', 'best');
title('PLS out-of-sample correlation across holdout splits');
box on; grid on;


%% looking at correlation
clear cfg
cfg.dir.project = '/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Scripts/Matlab/RCCA/cca_pls_toolkit-master/pls_holdout_two';
cfg.machine.name = 'pls';
cfg.frwork.name = 'holdout';
cfg.frwork.split.nout = 10;
cfg.frwork.split.propout = 0.2;
cfg.frwork.split.nin = 50;
cfg.stat.nperm = 1000;
cfg.env.comp = 'local';
cfg = cfg_defaults(cfg);

disp(cfg.dir.frwork)
set_path('plot');
res.dir.frwork = cfg.dir.frwork;
res.frwork.level = 1;

res = res_defaults(res, 'load');

best = res.frwork.split.best;
fprintf('best split = %d (expect 4)\n', best);

plot_proj(res, {'X' 'Y'}, res.frwork.level, 'osplit', ...
    best, 'training+test', '2d_group', ...
    'proj.lsline', 'on', ...
    'proj.xlabel', 'Behavioral latent variable', ...
    'proj.ylabel', 'Brain latent variable');

title(sprintf('Best holdout split (split %d, r = %.2f, p = %s)', ...
    best, correl(best), regexprep(sprintf('%.3f', pval(best)), '^0', '')), 'FontWeight', 'bold');
