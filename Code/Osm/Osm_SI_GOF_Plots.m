clear all

cd(fileparts(matlab.desktop.editor.getActiveFilename))

% Add folder to path to use:
% - csv2cell()
addpath('../Utils')

%settings for plots
set(0, 'DefaultAxesFontName', 'Helvetica');
set(0, 'DefaultAxesFontSize', 14);

saveto = '../../Figures/Osm_fits';
if exist(saveto, 'dir') ~= 7
    mkdir(saveto)
end

%define color map for plotting
cmp(1, :) = [209, 38,  91]  ./ 255;
cmp(2, :) = [51,  186, 162] ./ 255;
cmp(3, :) = [66,  79,  161] ./ 255;

%% Load and format data
residuals_cell = csv2cell('../../Results/Osm_Regression/Osm_Residuals.csv', 'fromfile');
method_list = {'SMR', 'RTDC', 'DC'};
fit_list = {'Exponential', 'Power', 'Linear'};
residual_index = strcmp(residuals_cell(1, :), 'AbsResiduals');
method_index = strcmp(residuals_cell(1, :), 'Method');
fit_index = strcmp(residuals_cell(1, :), 'Fit');

% structure data
% colums: SMR, RTDC, DC, rows: exp, power law, linear
res = zeros(3, 3);
for i = 1:numel(fit_list)
    for j = 1:numel(method_list)
        method_match = strcmp(residuals_cell(:, method_index), method_list{j});
        fit_match = strcmp(residuals_cell(:, fit_index), fit_list{i});
        use_rows = and(method_match, fit_match);
        residuals_cell_subset = residuals_cell(use_rows, :);
        res(i, j) = mean(cellfun(@str2double, residuals_cell_subset(:, residual_index)));
    end
end

res2 = res.';

resAVfit = mean(res, 2);
resSDfit = std(res, 0, 2);

res2 = [res2; resAVfit.'];

bic_cell = csv2cell('../../Results/Osm_Regression/BIC.csv', 'fromfile');

% colums: SMR-RTDC-DC, rows: exp, power law, linear
BIC0 = zeros(3, 3);
for i = 1:numel(fit_list)
    for j = 1:numel(method_list)
        row_index = strcmp(bic_cell(:, 1), fit_list{i});
        col_index = strcmp(bic_cell(1, :), method_list{j});
        BIC0(i, j) = str2double(bic_cell(row_index, col_index));
    end
end
BIC = BIC0.';

BICAVfit = mean(BIC0, 2);
BICSDfit = std(BIC0, 0, 2);

BIC = [BIC; BICAVfit.'];

%% Residuals
f1 = figure('Units', 'centimeters', 'Position', [1.5, 1.5, 14.4, 7.2]);
b1 = bar(res2);
b1(1).FaceColor = cmp(1, :);
b1(2).FaceColor = cmp(2, :);
b1(3).FaceColor = cmp(3, :);
hold on

%For the last set of bars, find the centers of the bars, and write error bars
for ib = 1:3
    %XData property is the tick labels/group centers; XOffset is the offset
    %of each distinct group
    xData = b1(ib).XData + b1(ib).XOffset;
    xpoints(ib, 1) = xData(4);
end

for ii = 1:size(res, 1)
    scatter(xpoints(ii)+rand(size(res, 2), 1)./7-0.1, res(ii, :), 30, 'filled', 'markeredgecolor', [0, 0, 0], 'markerfacecolor', [1, 1, 1])
    hold on
end

errorbar(xpoints, resAVfit, resSDfit*0, resSDfit, 'k.')
hold on
plot([3.5, 3.5], [0, 0.1], '--k', 'linewidth', 2)

box on
ax = gca;
ax.YGrid = 'on';
ax.GridLineStyle = ':';
ax.LineWidth = 1;
ax.GridAlpha = 0.3;
ax.YTick = [0:0.02:1];

ylabel('mean absolute residuals')
ylim([0, 0.1])
legend(b1, 'exponential', 'power law', 'linear', 'location', 'north')
xticklabels({'cDC', 'sDC', 'xDC', 'mean'})

print(fullfile(saveto, 'Osm_MeanResiduals_3fits.tiff'), '-dtiff')

%% BIC
f2 = figure('Units', 'centimeters', 'Position', [1.5, 1.5, 14.4, 7.2])

b2 = bar(BIC);
b2(1).FaceColor = cmp(1, :);
b2(2).FaceColor = cmp(2, :);
b2(3).FaceColor = cmp(3, :);
xticklabels({'cDC', 'sDC', 'xDC', 'mean'})
ylabel('BIC')

box on
ax = gca;
ax.YGrid = 'on';
ax.GridLineStyle = ':';
ax.LineWidth = 1;
ax.GridAlpha = 0.3;
ax.YTick = [-100:20:0];
ax.FontSize = 14;
hold on
for ib = 1:3
    %XData property is the tick labels/group centers; XOffset is the offset
    %of each distinct group
    xData = b2(ib).XData + b2(ib).XOffset;
    xpoints(ib, 1) = xData(4);
end
for ii = 1:size(BIC0, 1)
    scatter(xpoints(ii)+rand(size(res, 2), 1)./7-0.1, BIC0(ii, :), 30, 'filled', 'markeredgecolor', [0, 0, 0], 'markerfacecolor', [1, 1, 1])
    hold on
end
errorbar(xpoints, BICAVfit, BICSDfit, BICSDfit*0, 'k.')
hold on
plot([3.5, 3.5], [-100, 0], '--k', 'linewidth', 2)
legend(b2, 'exponential', 'power law', 'linear', 'location', 'southwest')

ylim([-90, 0])

print(fullfile(saveto, 'Osm_BIC_3fits.tiff'), '-dtiff')
