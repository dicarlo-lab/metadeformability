clear all

% set current directory to the directory of this script
cd(fileparts(matlab.desktop.editor.getActiveFilename))

%add destination path
saveto = '../Figures/SMR_PassageTime/';
if exist(saveto, 'dir') ~= 7
    mkdir(saveto)
end

%% Load data

%%%%% import SMR results - osmotic shock %%%%%
data_folder = '../Data_Raw/Osm/SMR';
dirinfo1O = dir(fullfile(data_folder, '*.mat'));
for ii = 2:length(dirinfo1O)
    set1O{ii-1} = importdata(fullfile(data_folder, dirinfo1O(ii).name));
    % each cell contains experiment series performed on one day
end
% concatanante all experiemnt series
set1Ocol = vertcat(set1O{:});
% collect passage time data from all control experiments (at 300 mOsm)
PTcntO = set1Ocol(set1Ocol(:, 1) == 300, 5); % in s
clear dirinfo1O data_folder set1O set1Ocol

%%%%% import SMR results - LatB treatment %%%%%
data_folder = '../Data_Raw/LatB/SMR';
dirinfo1LB = dir(fullfile(data_folder, '*.mat'));
for ii = 2:length(dirinfo1LB)
    set1LB{ii-1} = importdata(fullfile(data_folder, dirinfo1LB(ii).name));
    % each cell contains experiment series performed on one day
end
% concatanante all experiemnt series
set1LBcol = vertcat(set1LB{:});
% collect passage time data from all control experiments (at 0 ng/ml LatB)
PTcntLB = set1LBcol(set1LBcol(:, 1) == 0, 5); % in s
clear dirinfo1LB data_folder set1LB set1LBcol

%%%%%% concatanate passage times from all controll experiemnts %%%%%
%from both osmotic shock and LatB_treatment datasets
PTcnt = [PTcntO; PTcntLB];
clear PTcntLB PTcntO

%% building histogram from defined edges
clear hs centers
barN = 5000; %select number of bins
values = 1000 * PTcnt; %values used for building the histograms; passage time converted to miliseconds
edges = linspace(min(values), max(values), (barN + 1)); %edges used for classifying data to bins
range = edges(2) - edges(1); % bin width

if ~isvector(values)
    error('vals and weights must be vectors of the same size');
end

N = length(edges);
hs = zeros(size(edges)-1); %relative count of histogram bins
centers = zeros(size(edges)-1); %centers of histogram bins

for n = 1:N - 2
    ind = find(values >= edges(n) & values < edges(n+1));
    hs(n) = length(ind) / length(values);
    centers(n) = (edges(n) + edges(n+1)) / 2;
end

for n = N - 1
    ind = find(values >= edges(n) & values <= edges(n+1));
    hs(n) = length(ind) / length(values);
    centers(n) = (edges(n) + edges(n+1)) / 2;
end

% fit Kernel Density Estimation to histogram
xK = 1000 .* [0:0.001:10];
pdK = fitdist(values, 'Kernel', 'Kernel', 'epanechnikov');
yK = range .* pdf(pdK, xK);

Kmax = xK(yK == max(yK)); %most represented value

clear n N range values

%% plot histogram of passage time
% with fitted kernel density estimation of probability distribution
set(0, 'DefaultAxesFontName', 'Helvetica');

c_bar = [201, 151, 192] ./ 255;
c_curve = [162, 51, 137] ./ 255 .* 0.8;

f = figure('Units', 'centimeters', 'Position', [1.5, 1.5, 14, 10]);
bar(centers, hs, 'FaceColor', c_bar);
set(gca, 'FontSize', 11);
xlim([0, 150]);
ylim([0, 0.09]);

hold on
plot(xK, yK, '--', 'color', c_curve, 'linewidth', 3);
hold on
plot([Kmax, Kmax], [0, max(yK)], '--', 'color', c_curve, 'linewidth', 3);
box on
grid on
CA = gca;
CA.XAxis.MinorTick = 'on';
CA.XMinorGrid = 'on';
CA.MinorGridLineStyle = ':';
CA.YTick = [0:0.01:1];
xlabel('passage time (ms)', 'fontsize', 14);
ylabel('relative counts', 'fontsize', 14);
print(strcat(saveto, 'SMR_PassageTime_Cnt_pulled', '.jpeg'), '-djpeg', '-r300')
