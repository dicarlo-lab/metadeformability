clear all

cd(fileparts(matlab.desktop.editor.getActiveFilename))

% Add folder to path to use:
% - csv2cell()
% - load_colors()
addpath('../Utils')

%settings for plots
set(0, 'DefaultAxesFontName', 'Helvetica');
set(0, 'DefaultAxesFontSize', 14);

saveto = '../../Figures/Osm_fits';
if exist(saveto, 'dir') ~= 7
    mkdir(saveto)
end

%define color map for plotting - main
cMap = load_colors('main');

%define color map for plotting - supplement
cmp(1, :) = [209, 38,  91]  ./ 255;
cmp(2, :) = [51,  186, 162] ./ 255;
cmp(3, :) = [66,  79,  161] ./ 255;

%% Load data

[osm, sets, sets_col, sets_headers] = Osm_Load_Data();
[diam_ind, def_ind, meandiam] = Osm_prep(sets_headers, sets_col);
osm_fp = [265:1:730] ./ 300; %for plotting of fits

osmStr = {'hypo2', 'hypo1', 'ctrl', 'hyper1', 'hyper2', 'hyper3', 'hyper4'};
methods = {'cDC', 'sDC', 'xDC'};

% Creat summaries SMR, RTDC, DC
[summary, factor_all, summary_headers, table] = Osm_summarize(sets, diam_ind, def_ind, meandiam, osm, osmStr);

% Load exponential fit coefficients from R
exp_fit_cell = csv2cell('../../Results/Osm_Regression/Osm_Exponential_Coefficients.csv', 'fromfile');
estimate_index = strcmp(exp_fit_cell(1, :), 'estimate');
method_index = strcmp(exp_fit_cell(1, :), 'Method');

row_index = strcmp(exp_fit_cell(:, method_index), 'SMR');
exp_b(1, 1) = str2double(exp_fit_cell(row_index, estimate_index));
row_index = strcmp(exp_fit_cell(:, method_index), 'RTDC');
exp_b(2, 1) = str2double(exp_fit_cell(row_index, estimate_index));
row_index = strcmp(exp_fit_cell(:, method_index), 'DC');
exp_b(3, 1) = str2double(exp_fit_cell(row_index, estimate_index));
clear estimate_index method_index

% Load power law fit coefficients from R
pl_fit_cell = csv2cell('../../Results/Osm_Regression/Osm_Power_Coefficients.csv', 'fromfile');
estimate_index = strcmp(pl_fit_cell(1, :), 'estimate');
method_index = strcmp(pl_fit_cell(1, :), 'Method');

row_index = strcmp(pl_fit_cell(:, method_index), 'SMR');
pl_b(1, 1) = str2double(pl_fit_cell(row_index, estimate_index));
row_index = strcmp(pl_fit_cell(:, method_index), 'RTDC');
pl_b(2, 1) = str2double(pl_fit_cell(row_index, estimate_index));
row_index = strcmp(pl_fit_cell(:, method_index), 'DC');
pl_b(3, 1) = str2double(pl_fit_cell(row_index, estimate_index));
clear estimate_index method_index

% Load linear fit coefficients from R
lin_fit_cell = csv2cell('../../Results/Osm_Regression/Osm_Linear_Coefficients.csv', 'fromfile');
estimate_m_index = strcmp(lin_fit_cell(1, :), 'm');
estimate_b_index = strcmp(lin_fit_cell(1, :), 'b');
method_index = strcmp(lin_fit_cell(1, :), 'Method');

row_index = strcmp(lin_fit_cell(:, method_index), 'SMR');
lin_m(1, 1) = str2double(lin_fit_cell(row_index, estimate_m_index));
lin_b(1, 1) = str2double(lin_fit_cell(row_index, estimate_b_index));

row_index = strcmp(lin_fit_cell(:, method_index), 'RTDC');
lin_m(2, 1) = str2double(lin_fit_cell(row_index, estimate_m_index));
lin_b(2, 1) = str2double(lin_fit_cell(row_index, estimate_b_index));

row_index = strcmp(lin_fit_cell(:, method_index), 'DC');
lin_m(3, 1) = str2double(lin_fit_cell(row_index, estimate_m_index));
lin_b(3, 1) = str2double(lin_fit_cell(row_index, estimate_b_index));

%% Plot Regression lines for all methods, Figure 2e

f = figure('Units', 'centimeters', 'Position', [1.5, 1.5, 16, 12])
patch([0.5, 0.5, 1, 1], [0, 1.4, 1.4, 0], 'k', 'FaceAlpha', 0.2, 'EdgeColor', 'none')
hold on
for aa = [3, 2, 1]
    plotHandle(aa) = errorbar(osm./300, table{aa}(:, 4), table{aa}(:, 5), 'o', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', cMap(aa, :), ...
        'linewidth', 3, 'Color', cMap(aa, :), 'MarkerSize', 12, 'CapSize', 12);
    hold on
    plot(osm_fp, exp(exp_b(aa, 1).*(1 - osm_fp)), 'color', cMap(aa, :), 'linewidth', 3)
    hold on
end
box on
grid on
ax = gca;
ax.XTick = [0:0.25:3];
ax.GridLineStyle = ':';
ax.LineWidth = 1;
ax.GridAlpha = 0.3;

xlim([0.5, 2.5]);
ylim([0, 1.4]);

legend(plotHandle, methods, 'location', 'northeast')

xlabel('\it{Osm/Osm_{iso}}')
ylabel('Relative Deformability')

print(fullfile(saveto, 'Osm_DoseResponse_1umBin_expFit.tiff'), '-dtiff')

%% Plot Regression lines all fits per method, Supplementary Figure 5

ylims = [0, 1.4; 0, 1.4; 0.4, 1.3];

for aa = 1:3
    f = figure('Units', 'centimeters', 'Position', [1.5, 1.5, 16, 12])
    patch([0.5, 0.5, 1, 1], [0, 1.4, 1.4, 0], 'k', 'FaceAlpha', 0.2, 'EdgeColor', 'none')
    hold on
    
    p(1) = plot(osm_fp, exp(exp_b(aa, 1).*(1 - osm_fp)), 'color', cmp(1, :), 'linewidth', 3);
    hold on
    p(2) = plot(osm_fp, osm_fp.^pl_b(aa), 'color', cmp(2, :), 'linewidth', 3);
    hold on
    p(3) = plot(osm_fp, lin_m(aa).*osm_fp+lin_b(aa), 'color', cmp(3, :), 'linewidth', 3);
    hold on
    
    sc = errorbar(osm./300, table{aa}(:, 4), table{aa}(:, 5), 'o', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', 'k', ...
        'linewidth', 1.5, 'Color', 'k', 'MarkerSize', 10, 'CapSize', 12);
    hold on
    
    box on
    grid on
    ax = gca;
    ax.XTick = [0:0.25:3];
    ax.GridLineStyle = ':';
    ax.LineWidth = 1;
    ax.GridAlpha = 0.3;
    
    xlim([0.5, 2.5]);
    ylim(ylims(aa, :));
    
    legend(p, {'exponential', 'power law', 'linear'}, 'location', 'northeast')
    legend('boxoff')
    
    xlabel('\it{Osm/Osm_{iso}}')
    ylabel('Relative Deformability')
    
    print(fullfile(saveto, strcat('Osm_', methods{aa}, '_3Fits.tiff')), '-dtiff')
end
