clear all
cd(fileparts(matlab.desktop.editor.getActiveFilename))

% Add folder to path to use:
% - csv2cell()
% - load_colors()
addpath('../Utils')

saveto = '../../Figures/LatB_fits';
if exist(saveto, 'dir') ~= 7
    mkdir(saveto)
end

regression_file = '../../Results/LatB_Regression/LatB_Dose_Response_Coefficients_LL4.csv';
if exist(regression_file, 'file') ~= 2
    error('LatB_Dose_Response_Coefficients_LL4.csv does not exist. Ensure that regression has been performed in R.')
end

% define curves colormap
cMap = load_colors('main');

%default for plots
set(0, 'defaultAxesFontSize', 12)
set(0, 'defaultAxesFontName', 'Helvetica')

%% Open the files

[LatB, sets, sets_col, sets_headers] = LatB_Load_Data();
[diam_ind, def_ind, meandiam] = LatB_prep(sets_headers, sets_col);

LatBL = LatB;
LatB = LatB(2:end);
LatBLStr = {'ctrl', 'tr1', 'tr2', 'tr3', 'tr4', 'tr5', 'tr6'};
methods = {'cDC', 'sDC', 'xDC'};

% Creat summaries SMR, RTDC, DC - obtain medians & means of medians
[summary, factor_all, summary_headers, table] = LatB_summarize(sets, diam_ind, def_ind, meandiam, LatBL, LatBLStr);

%% Load and 4-Parameter Log-Logistic Regression Coefficients

LatB_coeffArray = csv2cell('../../Results/LatB_Regression/LatB_Dose_Response_Coefficients_LL4.csv', 'fromfile');

LatB_coeffArray(2:end, 3) = num2cell(str2double(LatB_coeffArray(2:end, 3)));
LatB_SMR_Coeff_4 = struct();
LatB_DC_Coeff_4 = struct();
LatB_RTDC_Coeff_4 = struct();
coeffNames = {'b', 'c', 'd', 'e', 'ed50'};
coeffNames2 = {'Slope:(Intercept)', 'Lower:(Intercept)', 'Upper:(Intercept)', 'ED50:(Intercept)', 'ED50:(Intercept)'};

for i = 1:numel(coeffNames)
    Index = and(ismember(LatB_coeffArray(:, 2), 'SMR'), ismember(LatB_coeffArray(:, 1), coeffNames2{i}));
    LatB_SMR_Coeff_4.(coeffNames{i}) = LatB_coeffArray{Index, 3};
    Index = and(ismember(LatB_coeffArray(:, 2), 'DC'), ismember(LatB_coeffArray(:, 1), coeffNames2{i}));
    LatB_DC_Coeff_4.(coeffNames{i}) = LatB_coeffArray{Index, 3};
    Index = and(ismember(LatB_coeffArray(:, 2), 'RTDC'), ismember(LatB_coeffArray(:, 1), coeffNames2{i}));
    LatB_RTDC_Coeff_4.(coeffNames{i}) = LatB_coeffArray{Index, 3};
end
LL4_func = @(x, fu) fu.c + (fu.d - fu.c) ./ ((1 + exp(fu.b*(log(x) - log(fu.e)))));

LL4_fit_x = linspace(1e-4*1000, 1e-1*1000, 1000);
LL4_fit{1} = LL4_func(LL4_fit_x, LatB_SMR_Coeff_4);
LL4_fit_ed50{1} = [LatB_SMR_Coeff_4.ed50, LL4_func(LatB_SMR_Coeff_4.ed50, LatB_SMR_Coeff_4)];
LL4_fit{2} = LL4_func(LL4_fit_x, LatB_RTDC_Coeff_4);
LL4_fit_ed50{2} = [LatB_RTDC_Coeff_4.ed50, LL4_func(LatB_RTDC_Coeff_4.ed50, LatB_RTDC_Coeff_4)];
LL4_fit{3} = LL4_func(LL4_fit_x, LatB_DC_Coeff_4);
LL4_fit_ed50{3} = [LatB_DC_Coeff_4.ed50, LL4_func(LatB_DC_Coeff_4.ed50, LatB_DC_Coeff_4)];

%% Plot Regression lines

figure('Units', 'centimeters', 'Position', [1.5, 1.5, 16, 12])
plotHandle = [];
for aa = 1:3
    plotHandle(aa) = errorbar(LatBL*1000, table{aa}(:, 4), table{aa}(:, 5), 'o', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', cMap(aa, :), ...
        'linewidth', 3, 'Color', cMap(aa, :), 'MarkerSize', 12, 'CapSize', 12);
    hold on
    plot(LL4_fit_x, LL4_fit{aa}, 'LineWidth', 3, 'Color', cMap(aa, :))
    scatter(LL4_fit_ed50{aa}(1), LL4_fit_ed50{aa}(2), 200, cMap(aa, :), 'LineWidth', 3)
    set(gca, 'xscale', 'log')
    xlim([0.0008, 0.12]*1000);
    ylim([0.86, 1.8])
    hold on
end
box on
grid on
legend(plotHandle, methods, 'location', 'northwest')
xlabel('LatB concentration (ng ml^{-1})')
ylabel('Relative Deformability')
set(gcf, 'renderer', 'painters');
filePath = fullfile(saveto, 'LatB_DoseResponse_1umBin_Fit4.tiff');
print('-dtiff', filePath)
