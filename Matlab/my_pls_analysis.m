%%%toolkit: https://mlnl.github.io/cca_pls_toolkit/ 
%%this script should be in a folder called "pls_analysis"
%%%in this folder you also need to create a folder called  "data" with X -> behavioral var and Y -> brain var.

%%%%%
% Add toolkit to path
toolkit_dir = '/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Scripts/Matlab/RCCA/cca_pls_toolkit-master/';
cd(toolkit_dir);
addpath(toolkit_dir);
set_path;

% Project folder (contains the data/ subfolder with X.mat, Y.mat)
cfg.dir.project = '/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Scripts/Matlab/RCCA/cca_pls_toolkit-master/pls_analysis';

% Standard PLS correlation
cfg.machine.name = 'pls';

% Descriptive framework (fit to all subjects)
cfg.frwork.name = 'permutation';
cfg.frwork.split.nout = 1;

% Statistical inference
cfg.stat.nperm = 1000;

% Environment
cfg.env.comp = 'local';

% Update cfg with defaults
cfg = cfg_defaults(cfg);
%%
% Run analysis
main(cfg);

%% Load data and PLS weights
res_folder = fullfile(cfg.dir.project, 'framework/pls_permutation/res/level1');

load(fullfile(cfg.dir.project, 'data', 'X.mat'), 'X');   % 405 x 8 clinical
load(fullfile(cfg.dir.project, 'data', 'Y.mat'), 'Y');   % 405 x 150 brain
load(fullfile(res_folder, 'model_1.mat'), 'wX', 'wY');     % saliences from the toolkit
wX = wX(:);  wY = wY(:);

%% 
X_labels = {'ADOS2_severity','ADI_R_SOCIAL_A','ADOS2_rrb','ADOS2_total_gotham', ...
            'ADOS2_socaff','ADI_R_VERBAL_BV','ADI_RRB','ADI_R_NONVERBAL_BV'};

% Clinical weights
for i = 1:8
    fprintf('%s: %.4f\n', X_labels{i}, wX(i));
end

% Top brain ICs by weight
[~, sortIdx] = sort(abs(wY), 'descend');
fprintf('\nTop brain ICs:\n');
for k = 1:5
    fprintf('IC%02d: %.4f\n', sortIdx(k), wY(sortIdx(k)));
end


Xz = zscore(X);
Yz = zscore(Y);
u = Xz*wX(:);  v = Yz*wY(:);
fprintf('latent r = %.4f  (expect 0.567)\n', corr(u,v));

%% Haufe loadings 
a_X = corr(Xz, u, 'rows','pairwise');
a_Y = corr(Yz, v, 'rows','pairwise');


%% Bootstrap 
n_boot = 1000;
n_subj = size(Xz,1);
boot_wX = zeros(n_boot, size(Xz,2));
boot_wY = zeros(n_boot, size(Yz,2));

rng(1);
for b = 1:n_boot
    idx = randi(n_subj, n_subj, 1);
    Xb = zscore(X(idx,:));      % re-standardize within the resample
    Yb = zscore(Y(idx,:));

    C = Xb' * Yb;               % now a proper cross-covariance
    [U,~,V] = svd(C,'econ');
    wXb = U(:,1);
    wYb = V(:,1);

    if wYb' * wY(:) < 0
        wXb = -wXb;  wYb = -wYb;
    end

    boot_wX(b,:) = wXb;
    boot_wY(b,:) = wYb;
end

%% BSR 
bsr_X = wX ./ std(boot_wX)';
bsr_Y = wY ./ std(boot_wY)';

p_X = 2*normcdf(-abs(bsr_X));
p_Y = 2*normcdf(-abs(bsr_Y));

fprintf('\nreliable clinical: %d of %d\n', sum(abs(bsr_X)>2), numel(bsr_X));
fprintf('reliable brain ICs: %d of %d  (chance ~7)\n', sum(abs(bsr_Y)>2), numel(bsr_Y));

%%
n_boot = 1000;
n_subj = size(X,1);

for s = 1:5
    rng(s);
    boot_wX = zeros(n_boot, size(X,2));
    boot_wY = zeros(n_boot, size(Y,2));

    for b = 1:n_boot
        idx = randi(n_subj, n_subj, 1);
        Xb = zscore(X(idx,:));
        Yb = zscore(Y(idx,:));
        [U,~,V] = svd(Xb'*Yb, 'econ');
        wXb = U(:,1);
        wYb = V(:,1);
        if wYb' * wY < 0
            wXb = -wXb;  wYb = -wYb;
        end
        boot_wX(b,:) = wXb;
        boot_wY(b,:) = wYb;
    end

    bsr_X_s = wX ./ std(boot_wX)';
    bsr_Y_s = wY ./ std(boot_wY)';

    fprintf('seed %d: %d clinical, %d brain, max|BSR_Y| = %.4f\n', ...
            s, sum(abs(bsr_X_s)>2), sum(abs(bsr_Y_s)>2), max(abs(bsr_Y_s)));
end
%% Save
T_clin = table(X_labels', wX, a_X, bsr_X, ...
    'VariableNames',{'Variable','Salience','HaufeLoading','BSR'});
writetable(T_clin, fullfile(res_folder,'bootstrap_clinical_final.csv'));

[~,si] = sort(abs(bsr_Y),'descend');
T_brain = table(arrayfun(@(x)sprintf('IC%03d',x), si, 'UniformOutput',false), ...
    wY(si), a_Y(si), bsr_Y(si), ...
    'VariableNames',{'IC','Salience','HaufeLoading','BSR'});
writetable(T_brain, fullfile(res_folder,'bootstrap_brain_ICs_final.csv'));
%%
fprintf('%d clinical, %d brain below p=.05\n', sum(p_X<0.05), sum(p_Y<0.05));
