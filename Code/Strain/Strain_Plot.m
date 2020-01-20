clear all
cd(fileparts(matlab.desktop.editor.getActiveFilename))

% Add folder to path to use:
% - load_colors()
addpath('../Utils')

%define source path
source_path = '../../Data_Processed/Strain';
dirinfo = dir(fullfile(source_path, '*.mat'));
if isempty(dirinfo)
    StrainEstimate_SMR
    StrainEstimate_RTDC
    StrainEstimate_DC
end
clear all
source_path = '../../Data_Processed/Strain';

%define path to save plots to
saveto = '../../Figures/Strain';
if exist(saveto, 'dir') ~= 7
    mkdir(saveto)
end

% default for plots
set(0, 'defaultAxesFontSize', 12)
set(0, 'defaultAxesFontName', 'Helvetica')

%define colors for plotting
colors = load_colors('main');

methods = {'cDC', 'sDC', 'xDC'};
axes = {'xy', 'xz'};

%% Load Estimated Strain Data
dirinfo = dir(fullfile(source_path, '*.mat'));

for indM = 1:length(dirinfo)
    load(fullfile(source_path, dirinfo(indM).name));
end

strain{1} = strainSMR_mean;
strain{2} = strainRTDC_mean;
strain{3} = strainDC_mean;
clear strainSMR_mean strainRTDC_mean strainDC_mean

strain_SD{1} = strainSMR_SD;
strain_SD{2} = strainRTDC_SD;
strain_SD{3} = strainDC_SD;
clear strainSMR_SD strainRTDC_SD strainDC_SD

theta = [-1:2 / 100:1];
lebs_tetha = {'-$\pi$', '-$\frac{3}{4}\pi$', '-$\frac{1}{2}\pi$', '-$\frac{1}{4}\pi$', '0', '$\frac{1}{4}\pi$', '$\frac{1}{2}\pi$', '$\frac{3}{4}\pi$'};

% in strain_SD and strain_mean matrices the columns include
% 1 - estimate for xy plane
% 2 - estimate for xz plane
% 3 - estimate for yz plane (only SMR and DC)

%% Plot strain xy 3 methods
figure('Units', 'centimeters', 'Position', [1.5, 1.5, 16, 9])

indC = 1;
plot([-1, 1], [0, 0], ':k', 'LineWidth', 2);
hold on
for indM = 1:length(methods)
    p1(indM) = plot(theta, strain{indM}(:, indC), 'linewidth', 2, 'color', colors(indM, :));
    hold on
    p2 = patch([theta(2:end-1), fliplr(theta(2:end-1))], ...
        [strain{indM}(2:end - 1, indC) + strain_SD{indM}(2:end - 1, indC); flipud(strain{indM}(2:end - 1, indC)-strain_SD{indM}(2:end - 1, indC))].', ...
        colors(indM, :), 'faceAlpha', 0.3, 'lineStyle', 'none');
    hold on
end
legend(p1, methods)
clear p1 p2

hold off
xlabel('$\theta$', 'interpreter', 'latex', 'fontsize', 18)
ylabel('$\varepsilon_{xy}$', 'interpreter', 'latex', 'fontsize', 18)
box on
grid on
ax = gca;
ax.GridLineStyle = ':';
xlim([-1, 1]);
ylim([-0.75, 1.5]);
yticks([-1:0.25:2]);
xticks([-1:0.25:1]);
set(gca, 'TickLabelInterpreter', 'latex', 'XTickLabel', lebs_tetha)

print(fullfile(saveto, 'Strain_xy_3methods.tiff'), '-dtiff', '-r300')

%% Plot strain xz 3 methods

figure('Units', 'centimeters', 'Position', [1.5, 1.5, 16, 9])
indC = 2;
plot([-1, 1], [0, 0], ':k', 'LineWidth', 2);
hold on
for indM = 1:length(methods)
    p1(indM) = plot(theta, strain{indM}(:, indC), '--', 'linewidth', 1.5, 'color', colors(indM, :));
    hold on
    p2 = patch([theta(2:end-1), fliplr(theta(2:end-1))], ...
        [strain{indM}(2:end - 1, indC) + strain_SD{indM}(2:end - 1, indC); flipud(strain{indM}(2:end - 1, indC)-strain_SD{indM}(2:end - 1, indC))].', ...
        colors(indM, :), 'faceAlpha', 0.3, 'lineStyle', 'none');
    hold on
end
legend(p1, methods)
clear p1 p2

hold off
xlabel('$\theta$', 'interpreter', 'latex', 'fontsize', 18)
ylabel('$\varepsilon_{xz}$', 'interpreter', 'latex', 'fontsize', 18)
box on
grid on
ax = gca;
ax.GridLineStyle = ':';
xlim([-1, 1]);
ylim([-0.75, 1.5]);
yticks([-1:0.25:2]);
xticks([-1:0.25:1]);
set(gca, 'TickLabelInterpreter', 'latex', 'XTickLabel', lebs_tetha)

print(fullfile(saveto, 'Strain_xz_3methods.tiff'), '-dtiff', '-r300')

%% Plot strain xy/xz individual methods SMR (cDC)

figure('Units', 'centimeters', 'Position', [1.5, 1.5, 16, 9]);
ylims = [-0.8, 1.6; -0.2, 0.6; -0.6, 1.0];
for indM = 1:3
    plot([-1, 1], [0, 0], ':k', 'LineWidth', 2);
    hold on
    for indC = 1
        p1(indC) = plot(theta, strain{indM}(:, indC), '-k', 'linewidth', 2);
        hold on
        p2 = patch([theta(2:end-1), fliplr(theta(2:end-1))], ...
            [strain{indM}(2:end - 1, indC) + strain_SD{indM}(2:end - 1, indC); flipud(strain{indM}(2:end - 1, indC)-strain_SD{indM}(2:end - 1, indC))].', ...
            [0, 0, 0], 'faceAlpha', 0.2, 'lineStyle', 'none');
        hold on
    end
    for indC = 2
        p1(indC) = plot(theta, strain{indM}(:, indC), '--k', 'linewidth', 1.5);
        hold on
        p2 = patch([theta(2:end-1), fliplr(theta(2:end-1))], ...
            [strain{indM}(2:end - 1, indC) + strain_SD{indM}(2:end - 1, indC); flipud(strain{indM}(2:end - 1, indC)-strain_SD{indM}(2:end - 1, indC))].', ...
            [0, 0, 0], 'faceAlpha', 0.2, 'lineStyle', 'none');
        hold on
    end
    legend(p1, axes)
    clear p1 p2
    
    hold off
    xlabel('$\theta$', 'interpreter', 'latex', 'fontsize', 18)
    ylabel('$\varepsilon$', 'interpreter', 'latex', 'fontsize', 18)
    box on
    grid on
    ax = gca;
    ax.GridLineStyle = ':';
    xlim([-1, 1]);
    ylim(ylims(indM, :));
    yticks([-1:0.25:2]);
    xticks([-1:0.25:1]);
    set(gca, 'TickLabelInterpreter', 'latex', 'XTickLabel', lebs_tetha)
    
    print(fullfile(saveto, strcat('Strain_xy_xz_', methods{indM}, '.tiff')), '-dtiff', '-r300')
end
