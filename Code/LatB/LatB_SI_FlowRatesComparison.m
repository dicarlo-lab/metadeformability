clear all
cd(fileparts(matlab.desktop.editor.getActiveFilename))

%define source path
source_path = '../../Data_Raw/LatB_FlowRate';

%define path to save plots to
saveto = '../../Figures/LatB_FlowRate';
if exist(saveto, 'dir') ~= 7
    mkdir(saveto)
end

%default for plots
set(0, 'defaultAxesFontSize', 12)
set(0, 'defaultAxesFontName', 'Helvetica')

%define colors for plotting
colors = [143, 145, 146; ...
          109, 190, 80; ...
          0,   107, 181] ./ 255;

%% load and structure data
dirinfo = dir(fullfile(source_path, '*.txt'));
dirinfo = dirinfo(~[dirinfo.isdir]);

for ii = 1:length(dirinfo)
    data{ii} = importdata(fullfile(source_path, dirinfo(ii).name));
    dataT{ii} = data{ii}.data;
end
headers = split(data{1}.textdata).';
clear data

dataAll = vertcat(dataT{:});

ind_cnt = [];
for ii = 1:5
    ind_cnt = [ind_cnt; repmat([1; 2; 3; 4]+(ii - 1)*28, 7, 1)];
end

for cc = 1:length(dataAll)
    dataAll(cc, 15) = dataAll(cc, 12) ./ dataAll(ind_cnt(cc), 12);
    dataAll(cc, 14) = dataAll(cc, 7) ./ dataAll(ind_cnt(cc), 7);
end

data04 = dataAll(dataAll(:, 3) == 0.04, :);
data08 = dataAll(dataAll(:, 3) == 0.08, :);
data12 = dataAll(dataAll(:, 3) == 0.12, :);
data00 = dataAll(dataAll(:, 3) == 0.00, :);

conc = unique(dataAll(:, 2));
fr = unique(dataAll(:, 3));

%% Calculate means and SD for all concentrations

for ii = 1:length(conc)
    for aa = 1:length(fr)
        indsel = find(dataAll(:, 2) == conc(ii) & dataAll(:, 3) == fr(aa));
        meanRD(ii, aa) = mean(dataAll(indsel, 15));
        sdRD(ii, aa) = std(dataAll(indsel, 15));
        meanD(ii, aa) = mean(dataAll(indsel, 12));
        sdD(ii, aa) = std(dataAll(indsel, 12));
    end
end

%% Plot dose-response of defermobality and relative deformability for different flow rates
f = figure
f.Units = 'centimeters';
f.OuterPosition = [0.1, 0.1, 30, 12]

subplot(1, 2, 1)
scatter(data04(:, 2).*1000, data04(:, 12), 'MarkerEdgeColor', colors(1, :))
hold on
scatter(data08(:, 2).*1000, data08(:, 12), 'MarkerEdgeColor', colors(3, :))
hold on
scatter(data12(:, 2).*1000, data12(:, 12), 'MarkerEdgeColor', colors(2, :))

hold on
errorbar(conc.*1000, meanD(:, 2), sdD(:, 2), 'color', colors(1, :), 'linewidth', 1.5)
hold on
errorbar(conc.*1000, meanD(:, 3), sdD(:, 3), 'color', colors(3, :), 'linewidth', 1.5)
hold on
errorbar(conc.*1000, meanD(:, 4), sdD(:, 4), 'color', colors(2, :), 'linewidth', 1.5)


hold on
scatter(conc.*1000, meanD(:, 2), 'fill', 'MarkerEdgeColor', colors(1, :), 'MarkerFaceColor', colors(1, :))
hold on
scatter(conc.*1000, meanD(:, 3), 'fill', 'MarkerEdgeColor', colors(3, :), 'MarkerFaceColor', colors(3, :))
hold on
scatter(conc.*1000, meanD(:, 4), 'fill', 'MarkerEdgeColor', colors(2, :), 'MarkerFaceColor', colors(2, :))


set(gca, 'XScale', 'log')
legend('fr1', 'fr2', 'fr3', 'location', 'northwest')
grid on
box on

xlim([0.0008, 0.12].*1000)

xlabel('LatB concentration (ng ml^{-1})')
ylabel('Deformability')

subplot(1, 2, 2)

scatter(data04(:, 2).*1000, data04(:, 15), 'MarkerEdgeColor', colors(1, :))
hold on
scatter(data08(:, 2).*1000, data08(:, 15), 'MarkerEdgeColor', colors(3, :))
hold on
scatter(data12(:, 2).*1000, data12(:, 15), 'MarkerEdgeColor', colors(2, :))

hold on
errorbar(conc.*1000, meanRD(:, 2), sdRD(:, 2), 'color', colors(1, :), 'linewidth', 1.5)
hold on
errorbar(conc.*1000, meanRD(:, 3), sdRD(:, 3), 'color', colors(3, :), 'linewidth', 1.5)
hold on
errorbar(conc.*1000, meanRD(:, 4), sdRD(:, 4), 'color', colors(2, :), 'linewidth', 1.5)

hold on
scatter(conc.*1000, meanRD(:, 2), 'fill', 'MarkerEdgeColor', colors(1, :), 'MarkerFaceColor', colors(1, :))
hold on
scatter(conc.*1000, meanRD(:, 3), 'fill', 'MarkerEdgeColor', colors(3, :), 'MarkerFaceColor', colors(3, :))
hold on
scatter(conc.*1000, meanRD(:, 4), 'fill', 'MarkerEdgeColor', colors(2, :), 'MarkerFaceColor', colors(2, :))


set(gca, 'XScale', 'log')
legend('fr1', 'fr2', 'fr3', 'location', 'northwest')
grid on
box on

xlim([0.0008, 0.12].*1000)
xlabel('LatB concentration (ng ml^{-1})')
ylabel('Relative Deformability')

print(fullfile(saveto, 'LatB_FlowRatesComparison.tiff'), '-dtiff', '-r300')
