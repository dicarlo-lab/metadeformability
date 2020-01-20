clear all

cd(fileparts(matlab.desktop.editor.getActiveFilename))

% Add Utils folder to the session to use the following functions:
% - contour50()
% - smooth1D()
% - load_colors()
addpath('../Utils')

%settings for plots
set(0, 'DefaultAxesFontName', 'Helvetica');
set(0, 'DefaultAxesFontSize', 14);

%colors for plotting
cc = load_colors('shades');
cc = cellfun(@flipud, cc, 'UniformOutput', false);

%directory to save plots
saveto = '../../Figures/Osm_Contour_Hist/';
if exist(saveto, 'dir') ~= 7
    mkdir(saveto)
end

%% Load Data
% methods indices for sets: 1 - cDC(SMR);  2 - sDC(RT-DC);   3 - xDC(DC)

[osm, sets, sets_col, sets_headers] = Osm_Load_Data();
[diam_ind, def_ind, meandiam] = Osm_prep(sets_headers, sets_col);

% diam_ind  - index of diameter column in given dataset
% def_ind   - index of deformability column in given dataset
% meandiam  - mean diameter from all measurments with given method

%% Estimate bin for size selection for each dataset, define plotting limits
binHF = 0.5; % half size of the 1-um bin for relative deformability analysis

for ii = 1:length(sets)
    binC(ii, 1) = meandiam(ii); % bin center for SMR
    poly{ii} = [binC(ii) - binHF, binC(ii) - binHF, binC(ii) + binHF, binC(ii) + binHF; 100, 0, 0, 100]; %selection polygon for plotting
end

% define bin sizes for histograms
binS_Dia = [0.65; 0.65; 0.65];
binS_Def = [4.5; 0.006; 0.1];
binS_Def_Sel = [4; 0.009; 0.19];

% define plotting limits
size_min_sets = [8; 8; 8];
size_max_sets = [18; 18; 18];

D_min_sets = [0; 0; 1];
D_max_sets = [70; 0.12; 4.0];

%% SMR - prepare data for ploting
m = 1; % method's index
aa = 2; % experimental series selected for plotting
data = sets{m}{aa};

size_min = size_min_sets(m);
size_max = size_max_sets(m);
D_min = D_min_sets(m);
D_max = D_max_sets(m);
indS = diam_ind(m);
indD = def_ind(m);

% prepare contour
for ii = 1:length(osm)
    X = data(data(:, 1) == osm(ii), 4);
    Y = data(data(:, 1) == osm(ii), 6);
    if ~isempty(X)
        [plcor50{ii}, ~] = contour50(X, Y, 'bins', [100, 100]);
    end
    clear X Y
    close
end

% prepare histogram size (diameter)
clear binS edges barN range centers_S relc_S relcS_max
binS = binS_Dia(m);
edges = [0:binS:25];
barN = length(edges) - 1;
range = edges(2) - edges(1);
centers_S = edges(1:end-1) + range ./ 2;

values1 = data(:, indS);
for bb = 1:length(osm)
    values = values1(data(:, 1) == osm(bb));
    for ii = 1:barN
        indx = find(values >= edges(ii) & values < edges(ii+1));
        relc_S(ii, bb) = length(indx) ./ length(values);
        clear indx
    end
    clear values
end
clear values1
relcS_max = ceil(max(max(relc_S.*10))) ./ 10;

% prepare histogram deormability
clear binS edges barN range centers_D relc_D relcD_max
binS = binS_Def(m);
edges = [0:binS:120];
barN = length(edges) - 1;
range = edges(2) - edges(1);
centers_D = edges(1:end-1) + range ./ 2;

values1 = sets{1}{aa}(:, indD);
for bb = 1:length(osm)
    values = values1(data(:, 1) == osm(bb));
    lengthSMRAll(bb, 1) = length(values);
    for ii = 1:barN
        indx = find(values >= edges(ii) & values < edges(ii+1));
        relc_D(ii, bb) = length(indx) ./ length(values);
        clear indx
    end
    clear values
end
clear values1
relcD_max = ceil(max(max(relc_D.*10))) ./ 10;

% prepare histogram deformability, selected for size
clear binS edges barN range centers_D2 relc_D2 relcD2_max
binS = binS_Def_Sel(m);
edges = [0:binS:120];
barN = length(edges) - 1;
range = edges(2) - edges(1);
centers_D2 = edges(1:end-1) + range ./ 2;

selind = find(data(:, indS) >= binC(m)-0.5 & data(:, indS) <= binC(m)+0.5);
values1 = data(selind, indD);
Osm1 = data(selind, 1);
for bb = 1:length(osm)
    values = values1(Osm1 == osm(bb));
    lengthSMRsel(bb, 1) = length(values);
    for ii = 1:barN
        indx = find(values >= edges(ii) & values < edges(ii+1));
        relc_D2(ii, bb) = length(indx) ./ length(values);
        clear indx
    end
    clear values
end
clear values1 Osm1
relcD2_max = ceil(max(max(relc_D2.*10))) ./ 10;

%% SMR - plot, Figure 2b
f = figure('Units', 'centimeters', 'Position', [1.5, 1.5, 20, 21])
pos1 = [0.1300, 0.1100, 0.6000, 0.6]; %2contour
pos2 = [0.75, 0.110, 0.200, 0.6]; %deformability histo, right side
pos3 = [0.13, 0.73, 0.6, 0.19]; %diameter histo, top

subplot('Position', pos1)

for ii = 1:length(osm)
    plot(plcor50{ii}(1, 2:end), plcor50{ii}(2, 2:end), 'color', cc{m}(ii, :), 'linewidth', 4)
    hold on
end

for ii = 1:length(osm)
    patch(plcor50{ii}(1, 2:end), plcor50{ii}(2, 2:end), cc{m}(ii, :), 'facealpha', 0.3, 'edgecolor', 'none')
    hold on
end

xlabel(strcat('cell diameter (', char(181), 'm)'), 'FontSize', 18);
ylabel('deformability (s^{-1})', 'FontSize', 18);
legend(cellstr(num2str(osm)), 'FontSize', 16)
text(0.92*size_max, 0.55*D_max, 'mOsm', 'FontSize', 16)
legend('boxoff')
xlim([size_min, size_max])
ylim([D_min, D_max])
box on
grid on
set(gca, 'XTick', [0:2:50])
hold off

subplot('Position', pos2)
for bb = 1:length(osm)
    plot(relc_D(:, bb), centers_D, 'linewidth', 4, 'color', cc{m}(bb, :))
    hold on
end
ylim([D_min, D_max])
xlim([0, relcD_max])
box on
grid on
CA = gca
yticklabels('')
CA.XAxis.FontSize = 14;
CA.XTick = [0:0.2:1];
CA.XAxisLocation = 'top';


subplot('Position', pos3)

for bb = 1:length(osm)
    plot(centers_S, relc_S(:, bb), 'linewidth', 4, 'color', cc{m}(bb, :))
    hold on
end

xlim([size_min, size_max])
ylim([0, relcS_max])
box on
grid on
CA = gca
xticklabels('')
CA.YAxis.FontSize = 14;
CA.YTick = [0:0.1:1];

print(fullfile(saveto, ['Osm_SMR_Contour_Hist_Set', num2str(aa)]), '-dtiff', '-r300')

%% SMR - plot with demnostrating bin selection, Supplementary Figure 3a
f = figure('Units', 'centimeters', 'Position', [1.5, 1.5, 26, 21])
pos1 = [0.13, 0.11, 0.45, 0.60]; %2contour
pos2 = [0.60, 0.11, 0.15, 0.60]; %deformability histo, right side
pos2b = [0.78, 0.11, 0.15, 0.60]; %deformability histo, with size-bin
pos3 = [0.13, 0.73, 0.45, 0.19]; %diameter histo, top

subplot('Position', pos1)
for ii = 1:length(osm)
    plot(plcor50{ii}(1, 2:end), plcor50{ii}(2, 2:end), 'color', cc{m}(ii, :), 'linewidth', 4)
    hold on
end

for ii = 1:length(osm)
    patch(plcor50{ii}(1, 2:end), plcor50{ii}(2, 2:end), cc{m}(ii, :), 'facealpha', 0.3, 'edgecolor', 'none')
    hold on
end

xlabel(strcat('cell diameter (', char(181), 'm)'), 'FontSize', 18);
ylabel('deformability (s^{-1})', 'FontSize', 18);
legend(cellstr(num2str(osm)), 'FontSize', 16)
text(0.92*size_max, 0.55*D_max, 'mOsm', 'FontSize', 16)
legend('boxoff')
xlim([size_min, size_max])
ylim([D_min, D_max])
box on
grid on
set(gca, 'XTick', [0:2:50])
hold off

p = patch(poly{m}(1, :), poly{m}(2, :), 'k', 'linestyle', 'none', 'HandleVisibility', 'off')
set(p, 'facealpha', 0.2)

subplot('Position', pos2)
for bb = 1:length(osm)
    plot(relc_D(:, bb), centers_D, 'linewidth', 4, 'color', cc{m}(bb, :))
    hold on
end
ylim([D_min, D_max])
xlim([0, relcD_max])
box on
grid on
CA = gca
yticklabels('')
CA.XAxis.FontSize = 14;
CA.XTick = [0:0.2:1];
CA.XAxisLocation = 'top';

subplot('Position', pos2b)
for bb = 1:length(osm)
    plot(relc_D2(:, bb), centers_D2, 'linewidth', 4, 'color', cc{m}(bb, :))
    hold on
end
plot([0.03, 0.97, 0.97, 0.03, 0.0].*relcD2_max, [D_min, D_min, D_max, D_max, D_min], 'k-', 'linewidth', 12, 'color', [0, 0, 0, 0.3])
ylim([D_min, D_max])
xlim([0, relcD2_max])
box on
grid on
CA = gca
CA.XAxis.FontSize = 14;
CA.XTick = [0:0.3:1];
CA.XAxisLocation = 'top';
yticklabels('')

subplot('Position', pos3)
for bb = 1:length(osm)
    plot(centers_S, relc_S(:, bb), 'linewidth', 4, 'color', cc{1}(bb, :))
    hold on
end

p = patch(poly{m}(1, :), poly{m}(2, :), 'k', 'linestyle', 'none')
set(p, 'facealpha', 0.2)

xlim([size_min, size_max])
ylim([0, relcS_max])
box on
grid on
CA = gca
xticklabels('')
CA.YAxis.FontSize = 14;
CA.YTick = [0:0.1:1];

%change '-dtiff' for '-depsc' for vector graphic version
print(fullfile(saveto, ['Osm_SMR_Contour_Hist_Set', num2str(aa), '_BinSel']), '-dtiff', '-r300')

%% RTDC - prepare data for ploting
clear data plcor50 centers_S centers_D centers_D2 relc_S relc_D relc_D2
close all
m = 2; % method's index
aa = 4; % experimental series selected for plotting
data = sets{m}{aa};

size_min = size_min_sets(m);
size_max = size_max_sets(m);
D_min = D_min_sets(m);
D_max = D_max_sets(m);
indS = diam_ind(m);
indD = def_ind(m);

%prepare contours
for ii = 1:length(osm)
    X = data(data(:, 1) == osm(ii), indS);
    Y = data(data(:, 1) == osm(ii), indD);
    [plcor50{ii}, ~] = contour50(X, Y, 'bins', [100, 100]);
    close
    clear X Y
end

% prepare histogram size (diameter)
clear binS edges barN range centers_S relc_S relcS_max
binS = binS_Dia(m);
edges = [0:binS:25];
barN = length(edges) - 1;
range = edges(2) - edges(1);
centers_S = edges(1:end-1) + range;

values1 = data(:, indS);
for bb = 1:length(osm)
    values = values1(data(:, 1) == osm(bb));
    for ii = 1:barN
        indx = find(values >= edges(ii) & values < edges(ii+1));
        relc_S(ii, bb) = length(indx) ./ length(values);
        clear indx
    end
    clear values
end
clear values1
relcS_max = ceil(max(max(relc_S.*10))) ./ 10;

% prepare histogram deformability
clear binS edges barN range centers_D relc_D relcD_max
binS = binS_Def(m);
edges = [0:binS:0.2];
barN = length(edges) - 1;
range = edges(2) - edges(1);
centers_D = edges(1:end-1) + range;

values1 = data(:, indD);
for bb = 1:length(osm)
    values = values1(data(:, 1) == osm(bb));
    for ii = 1:barN
        indx = find(values >= edges(ii) & values < edges(ii+1));
        relc_D(ii, bb) = length(indx) ./ length(values);
        clear indx
    end
    clear values
end
clear values1
relcD_max = ceil(max(max(relc_D.*10))) ./ 10;

% prepare histogram deformability, selected for size
clear binS edges barN range centers_D2 relc_D2 relcD2_max
binS = binS_Def_Sel(m);
edges = [0:binS:0.2];
barN = length(edges) - 1;
range = edges(2) - edges(1);
centers_D2 = edges(1:end-1) + range;

selind = find(data(:, indS) >= binC(m)-0.5 & data(:, indS) <= binC(m)+0.5);
values1 = data(selind, indD);
Osm1 = data(selind, 1);
for bb = 1:length(osm)
    values = values1(Osm1 == osm(bb));
    lengthRTDCsel(bb, 1) = length(values);
    for ii = 1:barN
        indx = find(values >= edges(ii) & values < edges(ii+1));
        relc_D2(ii, bb) = length(indx) ./ length(values);
        clear indx
    end
    clear values
end
clear values1 Osm1
relcD2_max = ceil(max(max(relc_D2.*10))) ./ 10;

%% RTDC - plot, Figure 2c
f = figure('Units', 'centimeters', 'Position', [1.5, 1.5, 20, 21])
pos1 = [0.1300, 0.1100, 0.6000, 0.6]; %2contour
pos2 = [0.75, 0.110, 0.200, 0.6]; %deformability histo, right side
pos3 = [0.13, 0.73, 0.6, 0.19]; %diameter histo, top

subplot('Position', pos1)

for ii = 1:length(osm)
    plot(plcor50{ii}(1, 2:end), plcor50{ii}(2, 2:end), 'color', cc{m}(ii, :), 'linewidth', 4)
    hold on
end

for ii = 1:length(osm)
    patch(plcor50{ii}(1, 2:end), plcor50{ii}(2, 2:end), cc{m}(ii, :), 'facealpha', 0.3, 'edgecolor', 'none')
    hold on
end

xlabel(strcat('cell diameter (', char(181), 'm)'), 'FontSize', 18);
ylabel('deformability', 'FontSize', 18);
legend(cellstr(num2str(osm)), 'FontSize', 16)
text(0.92*size_max, 0.55*D_max, 'mOsm', 'FontSize', 16)
legend('boxoff')
xlim([size_min, size_max])
ylim([D_min, D_max])
box on
grid on
set(gca, 'XTick', [0:2:50])
hold off

subplot('Position', pos2)
for bb = 1:length(osm)
    plot(relc_D(:, bb), centers_D, 'linewidth', 4, 'color', cc{m}(bb, :))
    hold on
end
ylim([D_min, D_max])
xlim([0, relcD_max])
box on
grid on
CA = gca
yticklabels('')
CA.XAxis.FontSize = 14;
CA.XTick = [0:0.2:1];
CA.XAxisLocation = 'top';


subplot('Position', pos3)

for bb = 1:length(osm)
    plot(centers_S, relc_S(:, bb), 'linewidth', 4, 'color', cc{m}(bb, :))
    hold on
end

xlim([size_min, size_max])
ylim([0, relcS_max])
box on
grid on
CA = gca
xticklabels('')
CA.YAxis.FontSize = 14;
CA.YTick = [0:0.1:1];

%change '-dtiff' for '-depsc' for vector graphic version
print(fullfile(saveto, ['Osm_RTDC_Contour_Hist_Set', num2str(aa)]), '-dtiff', '-r300')

%% RTDC - plot with demnostrating bin selection, Supplementary Figure 3b

f = figure('Units', 'centimeters', 'Position', [1.5, 1.5, 26, 21])
pos1 = [0.13, 0.11, 0.45, 0.60]; %2contour
pos2 = [0.60, 0.11, 0.15, 0.60]; %deformability histo, right side
pos2b = [0.78, 0.11, 0.15, 0.60]; %deformability histo, with size-bin
pos3 = [0.13, 0.73, 0.45, 0.19]; %diameter histo, top

subplot('Position', pos1)
for ii = 1:length(osm)
    plot(plcor50{ii}(1, 2:end), plcor50{ii}(2, 2:end), 'color', cc{m}(ii, :), 'linewidth', 4)
    hold on
end

for ii = 1:length(osm)
    patch(plcor50{ii}(1, 2:end), plcor50{ii}(2, 2:end), cc{m}(ii, :), 'facealpha', 0.3, 'edgecolor', 'none')
    hold on
end

xlabel(strcat('cell diameter (', char(181), 'm)'), 'FontSize', 18);
ylabel('deformability', 'FontSize', 18);
legend(cellstr(num2str(osm)), 'FontSize', 16, 'Location', 'northwest')
text(0.48*size_max, 0.55*D_max, 'mOsm', 'FontSize', 16)
legend('boxoff')
xlim([size_min, size_max])
ylim([D_min, D_max])
box on
grid on
set(gca, 'XTick', [0:2:50])
hold off

p = patch(poly{m}(1, :), poly{m}(2, :), 'k', 'linestyle', 'none', 'HandleVisibility', 'off')
set(p, 'facealpha', 0.2)

subplot('Position', pos2)
for bb = 1:length(osm)
    plot(relc_D(:, bb), centers_D, 'linewidth', 4, 'color', cc{m}(bb, :))
    hold on
end
ylim([D_min, D_max])
xlim([0, relcD_max])
box on
grid on
CA = gca
yticklabels('')
CA.XAxis.FontSize = 14;
CA.XTick = [0:0.2:1];
CA.XAxisLocation = 'top';

subplot('Position', pos2b)
for bb = 1:length(osm)
    plot(relc_D2(:, bb), centers_D2, 'linewidth', 4, 'color', cc{m}(bb, :))
    hold on
end
plot([0.03, 0.97, 0.97, 0.03, 0.03].*relcD2_max, [D_min, D_min, D_max, D_max, D_min], 'k-', 'linewidth', 12, 'color', [0, 0, 0, 0.3])
ylim([D_min, D_max])
xlim([0, relcD2_max])
box on
grid on
CA = gca
CA.XAxis.FontSize = 14;
CA.XTick = [0:0.2:1];
CA.XAxisLocation = 'top';
yticklabels('')

subplot('Position', pos3)
for bb = 1:length(osm)
    plot(centers_S, relc_S(:, bb), 'linewidth', 4, 'color', cc{m}(bb, :))
    hold on
end

p = patch(poly{m}(1, :), poly{m}(2, :), 'k', 'linestyle', 'none')
set(p, 'facealpha', 0.2)

xlim([size_min, size_max])
ylim([0, relcS_max])
box on
grid on
CA = gca
xticklabels('')
CA.YAxis.FontSize = 14;
CA.YTick = [0:0.1:1];
CA.XTick = [0:2:30];

%change '-dtiff' for '-depsc' for vector graphic version
print(fullfile(saveto, ['Osm_RTDC_Contour_Hist_Set', num2str(aa), '_BinSel']), '-dtiff', '-r300')

%% DC - prepare data for ploting
clear data plcor50 centers_S centers_D centers_D2 relc_S relc_D relc_D2
close all

m = 3; % method's index
aa = 2; % experimental series selected for plotting
data = sets{m}{aa};

size_min = size_min_sets(m);
size_max = size_max_sets(m);
D_min = D_min_sets(m);
D_max = D_max_sets(m);
indS = diam_ind(m);
indD = def_ind(m);

%prepare contours
for ii = 1:length(osm)
    X = data(data(:, 1) == osm(ii), indS);
    Y = data(data(:, 1) == osm(ii), indD);
    [plcor50{ii}, ~] = contour50(X, Y, 'bins', [100, 100]);
    close
    clear X Y
end

% prepare histogram size (diameter)
clear binS edges barN range centers_S relc_S relcS_max
binS = binS_Dia(m);
edges = [0:binS:25];
barN = length(edges) - 1;
range = edges(2) - edges(1);
centers_S = edges(1:end-1) + range;

values1 = data(:, indS);
for bb = 1:length(osm)
    values = values1(data(:, 1) == osm(bb));
    for ii = 1:barN
        indx = find(values >= edges(ii) & values < edges(ii+1));
        relc_S(ii, bb) = length(indx) ./ length(values);
        clear indx
    end
    clear values
end
clear values1
relcS_max = ceil(max(max(relc_S.*10))) ./ 10;

% prepare histogram deformability
clear binS edges barN range centers_D relc_D relcD_max
binS = binS_Def(m);
edges = [0.5:binS:5];
barN = length(edges) - 1;
range = edges(2) - edges(1);
centers_D = edges(1:end-1) + range;

values1 = data(:, indD);
for bb = 1:length(osm)
    values = values1(data(:, 1) == osm(bb));
    for ii = 1:barN
        indx = find(values >= edges(ii) & values < edges(ii+1));
        relc_D(ii, bb) = length(indx) ./ length(values);
        clear indx
    end
    clear values
end
clear values1
relcD_max = ceil(max(max(relc_D.*10))) ./ 10;

% prepare histogram deformability, selected for size
clear binS edges barN range centers_D2 relc_D2 relcD2_max
binS = binS_Def_Sel(m);
edges = [0.5:binS:5];
barN = length(edges) - 1;
range = edges(2) - edges(1);
centers_D2 = edges(1:end-1) + range;

selind = find(data(:, indS) >= binC(m)-0.5 & data(:, indS) <= binC(m)+0.5);
values1 = data(:, indD);
values1 = data(selind, indD);
Osm1 = data(selind, 1);
for bb = 1:length(osm)
    values = values1(Osm1 == osm(bb));
    lengthRTDCsel(bb, 1) = length(values);
    for ii = 1:barN
        indx = find(values >= edges(ii) & values < edges(ii+1));
        relc_D2(ii, bb) = length(indx) ./ length(values);
        clear indx
    end
    clear values
end
clear values1 Osm1
relcD2_max = ceil(max(max(relc_D2.*10))) ./ 10;

%% DC - plot, Figure 2d
f = figure('Units', 'centimeters', 'Position', [1.5, 1.5, 20, 21])
pos1 = [0.1300, 0.1100, 0.6000, 0.6]; %2contour
pos2 = [0.75, 0.110, 0.200, 0.6]; %deformability histo, right side
pos3 = [0.13, 0.73, 0.6, 0.19]; %diameter histo, top

subplot('Position', pos1)

for ii = 1:length(osm)
    plot(plcor50{ii}(1, 2:end), plcor50{ii}(2, 2:end), 'color', cc{m}(ii, :), 'linewidth', 4)
    hold on
end

for ii = 1:length(osm)
    patch(plcor50{ii}(1, 2:end), plcor50{ii}(2, 2:end), cc{m}(ii, :), 'facealpha', 0.3, 'edgecolor', 'none')
    hold on
end

xlabel(strcat('cell diameter (', char(181), 'm)'), 'FontSize', 18);
ylabel('deformability', 'FontSize', 18);
legend(cellstr(num2str(osm)), 'FontSize', 16, 'location', 'northwest')
text(0.48*size_max, 0.66*D_max, 'mOsm', 'FontSize', 16)
legend('boxoff')
xlim([size_min, size_max])
ylim([D_min, D_max])
box on
grid on
set(gca, 'XTick', [0:2:50])
hold off

subplot('Position', pos2)
for bb = 1:length(osm)
    plot(relc_D(:, bb), centers_D, 'linewidth', 4, 'color', cc{m}(bb, :))
    hold on
end
ylim([D_min, D_max])
xlim([0, relcD_max])
box on
grid on
CA = gca
yticklabels('')
CA.XAxis.FontSize = 14;
CA.XTick = [0:0.2:1];
CA.XAxisLocation = 'top';


subplot('Position', pos3)

for bb = 1:length(osm)
    plot(centers_S, relc_S(:, bb), 'linewidth', 4, 'color', cc{m}(bb, :))
    hold on
end

xlim([size_min, size_max])
ylim([0, relcS_max])
box on
grid on
CA = gca
xticklabels('')
CA.YAxis.FontSize = 14;
CA.YTick = [0:0.2:1];

%change '-dtiff' for '-depsc' for vector graphic version
print(fullfile(saveto, ['Osm_DC_Contour_Hist_Set', num2str(aa)]), '-dtiff', '-r300')

%% DC - plot with demnostrating bin selection, Supplementary Figure 3c

f = figure('Units', 'centimeters', 'Position', [1.5, 1.5, 26, 21])
pos1 = [0.13, 0.11, 0.45, 0.60]; %2contour
pos2 = [0.60, 0.11, 0.15, 0.60]; %deformability histo, right side
pos2b = [0.78, 0.11, 0.15, 0.60]; %deformability histo, with size-bin
pos3 = [0.13, 0.73, 0.45, 0.19]; %diameter histo, top

subplot('Position', pos1)
for ii = 1:length(osm)
    plot(plcor50{ii}(1, 2:end), plcor50{ii}(2, 2:end), 'color', cc{m}(ii, :), 'linewidth', 4)
    hold on
end

for ii = 1:length(osm)
    patch(plcor50{ii}(1, 2:end), plcor50{ii}(2, 2:end), cc{m}(ii, :), 'facealpha', 0.3, 'edgecolor', 'none')
    hold on
end

xlabel(strcat('cell diameter (', char(181), 'm)'), 'FontSize', 18);
ylabel('deformability', 'FontSize', 18);
legend(cellstr(num2str(osm)), 'FontSize', 16, 'location', 'northwest')
text(0.48*size_max, 0.66*D_max, 'mOsm', 'FontSize', 16)
legend('boxoff')
xlim([size_min, size_max])
ylim([D_min, D_max])
box on
grid on
set(gca, 'XTick', [0:2:50])
hold off

p = patch(poly{m}(1, :), poly{m}(2, :), 'k', 'linestyle', 'none', 'HandleVisibility', 'off')
set(p, 'facealpha', 0.2)

subplot('Position', pos2)
for bb = 1:length(osm)
    plot(relc_D(:, bb), centers_D, 'linewidth', 4, 'color', cc{m}(bb, :))
    hold on
end
ylim([D_min, D_max])
xlim([0, relcD_max])
box on
grid on
CA = gca
yticklabels('')
CA.XAxis.FontSize = 14;
CA.XTick = [0:0.2:1];
CA.XAxisLocation = 'top';

subplot('Position', pos2b)
for bb = 1:length(osm)
    plot(relc_D2(:, bb), centers_D2, 'linewidth', 4, 'color', cc{m}(bb, :))
    hold on
end
plot([0.03, 0.97, 0.97, 0.03, 0.03].*relcD2_max, [D_min, D_min, D_max, D_max, D_min], 'k-', 'linewidth', 12, 'color', [0, 0, 0, 0.3])
ylim([D_min, D_max])
xlim([0, relcD2_max])
box on
grid on
CA = gca
CA.XAxis.FontSize = 14;
CA.XTick = [0:0.3:1];
CA.XAxisLocation = 'top';
yticklabels('')

subplot('Position', pos3)
for bb = 1:length(osm)
    plot(centers_S, relc_S(:, bb), 'linewidth', 4, 'color', cc{m}(bb, :))
    hold on
end

p = patch(poly{m}(1, :), poly{m}(2, :), 'k', 'linestyle', 'none')
set(p, 'facealpha', 0.2)

xlim([size_min, size_max])
ylim([0, relcS_max])
box on
grid on
CA = gca
xticklabels('')
CA.YAxis.FontSize = 14;
CA.YTick = [0:0.2:1];

%change '-dtiff' for '-depsc' for vector graphic version
print(fullfile(saveto, ['Osm_DC_Contour_Hist_Set', num2str(aa), '_BinSel']), '-dtiff', '-r300')
