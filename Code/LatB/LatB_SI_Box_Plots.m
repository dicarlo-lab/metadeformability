clear all

cd(fileparts(matlab.desktop.editor.getActiveFilename))

% Add folder to path to use:
% - notBoxPlot()
% - load_colors()
addpath('../Utils')

%settings for plots
set(0, 'DefaultAxesFontName', 'Helvetica');
set(0, 'DefaultAxesFontSize', 14);

%colors for plotting
load('LatB_cdots.mat');
cc = load_colors('shades');

%add destination path
saveto = '../../Figures/LatB_Box/';
if exist(saveto, 'dir') ~= 7
    mkdir(saveto)
end

%% Open the files
[LatB, sets, sets_col, sets_headers] = LatB_Load_Data();
[diam_ind, def_ind, meandiam] = LatB_prep(sets_headers, sets_col);

LatBL = LatB;
LatB = LatB(2:end);
LatBLStr = {'ctrl', 'tr1', 'tr2', 'tr3', 'tr4', 'tr5', 'tr6'};
methods = {'SMR', 'RTDC', 'DC'};

% Creat summaries SMR, RTDC, DC - obtain medians & means of medians
[summary, factor_all, summary_headers, table] = LatB_summarize(sets, diam_ind, def_ind, meandiam, LatBL, LatBLStr);

%% Box plot Summary RD
ylims = [0.9, 1.8; 0.9, 1.8; 0.8, 1.7];

for m = 1:length(methods)
    barC = [1:1:7];
    bh = 0.165;
    
    f = figure
    
    for ii = 1:size(table{m}, 1)
        patch([barC(ii) - bh, barC(ii) + bh, barC(ii) + bh, barC(ii) - bh], ...
            [table{m}(ii, 4) - table{m}(ii, 5), table{m}(ii, 4) - table{m}(ii, 5), ...
            table{m}(ii, 4) + table{m}(ii, 5), table{m}(ii, 4) + table{m}(ii, 5)], ...
            [1, 1, 1], 'linestyle', 'none');
        hold on
    end
    
    for ii = 1:size(table{m}, 1)
        patch([barC(ii) - bh, barC(ii) + bh, barC(ii) + bh, barC(ii) - bh], ...
            [table{m}(ii, 4) - table{m}(ii, 5), table{m}(ii, 4) - table{m}(ii, 5), ...
            table{m}(ii, 4) + table{m}(ii, 5), table{m}(ii, 4) + table{m}(ii, 5)], ...
            cc{m}(ii, :), 'faceAlpha', 0.5, 'linestyle', 'none');
        hold on
    end
    
    medw = bh / 16;
    for ii = 1:size(table{m}, 1)
        patch([barC(ii) - bh, barC(ii) + bh, barC(ii) + bh, barC(ii) - bh], ...
            [table{m}(ii, 4) - medw, table{m}(ii, 4) - medw, table{m}(ii, 4) + medw, table{m}(ii, 4) + medw], ...
            cc{m}(ii, :), 'EdgeColor', 'none');
        hold on
    end
    
    box on
    ax = gca;
    ax.GridLineStyle = ':';
    ax.YGrid = 'on';
    ax.XGrid = 'off';
    
    hold on
    
    for ii = 1:length(LatBL)
        ind = find(summary{m}(:, 1) == LatBL(ii));
        for jj = 1:length(unique(summary{m}(:, 4)))
            ind2 = intersect(ind, find(summary{m}(:, 4) == jj));
            scatter(ii+rand(length(summary{m}(ind2, 7)), 1)./3-0.25, summary{m}(ind2, 3), 50, 'filled', 'markeredgecolor', [0, 0, 0], 'markerfacecolor', cdots(jj, :))
            clear ind2
        end
        clear ind
        hold on
    end
    
    ylim(ylims(m, :))
    xticklabels({'', '0', '1', '5', '10', '25', '50', '100'})
    xlabel('LatB concentration (ng ml^{-1})')
    ylabel('Relative Deformability')
    
    print(strcat(saveto, 'LatB_Box_', methods{m}, '_RD_Sum.tiff'), '-dtiff', '-r300')
end

%% Box plot Summary SIZE

ylims = [12, 14; 13, 15; 13, 16];
for m = 1:length(methods) %method index
    barC = [1:1:7];
    bh = 0.165;
    
    f = figure
    
    for ii = 1:size(table{m}, 1)
        patch([barC(ii) - bh, barC(ii) + bh, barC(ii) + bh, barC(ii) - bh], ...
            [table{m}(ii, 6) - table{m}(ii, 7), table{m}(ii, 6) - table{m}(ii, 7), ...
            table{m}(ii, 6) + table{m}(ii, 7), table{m}(ii, 6) + table{m}(ii, 7)], ...
            [1, 1, 1], 'linestyle', 'none');
        hold on
    end
    
    for ii = 1:size(table{m}, 1)
        patch([barC(ii) - bh, barC(ii) + bh, barC(ii) + bh, barC(ii) - bh], ...
            [table{m}(ii, 6) - table{m}(ii, 7), table{m}(ii, 6) - table{m}(ii, 7), ...
            table{m}(ii, 6) + table{m}(ii, 7), table{m}(ii, 6) + table{m}(ii, 7)], ...
            cc{m}(ii, :), 'faceAlpha', 0.5, 'linestyle', 'none');
        hold on
    end
    
    medw = bh ./ 16 .* (ylims(m, 2) - ylims(m, 1));
    for ii = 1:size(table{m}, 1)
        patch([barC(ii) - bh, barC(ii) + bh, barC(ii) + bh, barC(ii) - bh], ...
            [table{m}(ii, 6) - medw, table{m}(ii, 6) - medw, table{m}(ii, 6) + medw, table{m}(ii, 6) + medw], ...
            cc{m}(ii, :), 'EdgeColor', 'none');
        hold on
    end
    
    for ii = 1:length(LatBL)
        ind = find(summary{m}(:, 1) == LatBL(ii));
        for jj = 1:length(unique(summary{m}(:, 4)))
            ind2 = intersect(ind, find(summary{m}(:, 4) == jj))
            scatter(ii+rand(length(summary{m}(ind2, 7)), 1)./3-0.25, summary{m}(ind2, 7), 50, 'filled', 'markeredgecolor', [0, 0, 0], 'markerfacecolor', cdots(jj, :))
            clear ind2
        end
        clear ind
        hold on
    end
    
    box on
    ax = gca
    ax.GridLineStyle = ':';
    ax.YGrid = 'on';
    ax.XGrid = 'off';
    
    pbaspect([1.2, 1, 1])
    
    xticklabels({'', '0', '1', '5', '10', '25', '50', '100'})
    xlabel('LatB concentration (ng ml^{-1})')
    ylabel(strcat('cell diameter (', char(181), 'm)'));
    
    ylim(ylims(m, :))
    print(strcat(saveto, 'LatB_Box_', methods{m}, '_Size.tiff'), '-dtiff', '-r300')
end

%% Box plot Summary - EVENTS NUMBER

values = [];
for ii = 1:length(LatBL)
    for aa = 1:length(summary)
        set0 = summary{1, aa};
        temp = set0(set0(:, 1) == LatBL(ii), 9);
        values(1:length(temp), end+1) = temp;
        clear temp
    end
end

values(values == 0) = NaN;
valuesA = nanmean(values, 1);
valuesB = reshape(valuesA, [3, 7]).'
errors = nanstd(values, 1)
errorsB = reshape(errors, [3, 7]).'

f = figure
% Finding the number of groups and the number of bars in each group
ngroups = size(valuesB, 1);
nbars = size(valuesB, 2);
% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
% Set the position of each error bar with recpect to the centre of the bar
% group, based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
for i = 1:nbars
    % Calculate center of each bar group
    x = (1:ngroups) - groupwidth / 2 + (2 * i - 1) * groupwidth / (2 * nbars);
    for ii = 1:length(x)
        patch([x(ii) - groupwidth / 8, x(ii) + groupwidth / 8, x(ii) + groupwidth / 8, x(ii) - groupwidth / 8], ...
            [valuesB(ii, i) - errorsB(ii, i), valuesB(ii, i) - errorsB(ii, i), ...
            valuesB(ii, i) + errorsB(ii, i), valuesB(ii, i) + errorsB(ii, i)], ...
            [1, 1, 1], 'linestyle', 'none');
        hold on
    end
    
    for ii = 1:length(x)
        patch([x(ii) - groupwidth / 8, x(ii) + groupwidth / 8, x(ii) + groupwidth / 8, x(ii) - groupwidth / 8], ...
            [valuesB(ii, i) - errorsB(ii, i), valuesB(ii, i) - errorsB(ii, i), ...
            valuesB(ii, i) + errorsB(ii, i), valuesB(ii, i) + errorsB(ii, i)], ...
            cc{i}(5, :), 'faceAlpha', 0.5, 'linestyle', 'none');
        hold on
    end
    
    for ii = 1:length(x)
        plot([x(ii) - groupwidth / 8, x(ii) + groupwidth / 8], [valuesB(ii, i), valuesB(ii, i)], ...
            'color', cc{i}(5, :), 'linewidth', 5);
        hold on
    end
end

box on
ax = gca;
ax.GridLineStyle = '--';
ax.YGrid = 'on';
ax.XGrid = 'off';
yticks([0:250:2200])
ylim([0, 2200])
xticklabels({'', '0', '1', '5', '10', '25', '50', '100'})
xlabel('LatB concentration (ng ml^{-1})')
ylabel('number of events in size bin')

print(strcat(saveto, 'LatB_Box_EventsNoPerBin.tiff'), '-dtiff', '-r300')

%% Box plot Summary - EVENTS PERC

values = [];
for ii = 1:length(LatBL)
    for aa = 1:length(summary)
        set0 = summary{1, aa};
        temp = set0(set0(:, 1) == LatBL(ii), 9) ./ set0(set0(:, 1) == LatBL(ii), 8);
        values(1:length(temp), end+1) = temp .* 100;
        clear temp
    end
end

values(values == 0) = NaN;
valuesA = nanmean(values, 1);
valuesB = reshape(valuesA, [3, 7]).'
errors = nanstd(values, 1)
errorsB = reshape(errors, [3, 7]).'

f = figure
% Finding the number of groups and the number of bars in each group
ngroups = size(valuesB, 1);
nbars = size(valuesB, 2);
% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
% Set the position of each error bar with recpect to the centre of the bar
% group, based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
for i = 1:nbars
    % Calculate center of each bar group
    x = (1:ngroups) - groupwidth / 2 + (2 * i - 1) * groupwidth / (2 * nbars);
    for ii = 1:length(x)
        patch([x(ii) - groupwidth / 8, x(ii) + groupwidth / 8, x(ii) + groupwidth / 8, x(ii) - groupwidth / 8], ...
            [valuesB(ii, i) - errorsB(ii, i), valuesB(ii, i) - errorsB(ii, i), ...
            valuesB(ii, i) + errorsB(ii, i), valuesB(ii, i) + errorsB(ii, i)], ...
            [1, 1, 1], 'linestyle', 'none');
        hold on
    end
    
    for ii = 1:length(x)
        patch([x(ii) - groupwidth / 8, x(ii) + groupwidth / 8, x(ii) + groupwidth / 8, x(ii) - groupwidth / 8], ...
            [valuesB(ii, i) - errorsB(ii, i), valuesB(ii, i) - errorsB(ii, i), ...
            valuesB(ii, i) + errorsB(ii, i), valuesB(ii, i) + errorsB(ii, i)], ...
            cc{i}(5, :), 'faceAlpha', 0.5, 'linestyle', 'none');
        hold on
    end
    
    for ii = 1:length(x)
        plot([x(ii) - groupwidth / 8, x(ii) + groupwidth / 8], [valuesB(ii, i), valuesB(ii, i)], ...
            'color', cc{i}(5, :), 'linewidth', 5);
        hold on
    end
end

box on
ax = gca;
ax.GridLineStyle = '--';
ax.YGrid = 'on';
ax.XGrid = 'off';
yticks([0:5:100])
ylim([10, 45])
xticklabels({'', '0', '1', '5', '10', '25', '50', '100'})
xlabel('LatB concentration (ng ml^{-1})')
ylabel('events in size bin (% of all events)')

print(strcat(saveto, 'LatB_Box_EventsPercPerBin.tiff'), '-dtiff', '-r300')
