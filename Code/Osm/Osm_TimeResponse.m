clear all

cd(fileparts(matlab.desktop.editor.getActiveFilename))

%settings for plots
set(0, 'DefaultAxesFontName', 'Helvetica');
set(0, 'DefaultAxesFontSize', 14);

saveto = '../../Figures/Osm_TimeResponse';
if exist(saveto, 'dir') ~= 7
    mkdir(saveto)
end

%define color map for plotting
cmp = [158, 196, 63; ...
       122, 186, 87; ...
       86,  178, 107; ...
       49,  173, 124; ...
       25,  159, 133; ...
       31,  142, 137] ./ 255;

%% Load Data
source_path = '../../Data_Raw/Osm_Time_Response';

fileList = dir(fullfile(source_path, '*.txt'));
fileList = fileList(~[fileList.isdir]); %clean some subdirectories

for ii = 1:length(fileList)
    data{ii} = dlmread(fullfile(source_path, fileList(ii).name), '\t', 1, 0);
    Osm{ii} = regexp(fileList(ii).name, '[0-9]+mOsm', 'match');
    Osm{ii} = Osm{ii}{1, 1};
    Osm_num(ii, 1) = str2double(Osm{ii}(1:3));
    Mn{ii} = fileList(ii).name(10:11);
    Date{ii} = regexp(fileList(ii).name, '2016[0-9]+', 'match');
end

dataX = importdata(fullfile(source_path, fileList(1).name));
headers = dataX.textdata;
clear dataX

% sort all experiments in osm order
[OsmSort, sel] = sort(Osm_num);

Dcnt = data{Osm_num == 300}(1, 2);
DcntBin = data{Osm_num == 300}(1, 6);

%% Plot Median Deformation vs Time

f1 = figure;

for aa = 1:length(sel)
    ii = sel(aa)
    plot(data{ii}(:, 1), data{ii}(:, 2), '*-', 'color', cmp(aa, :), 'linewidth', 3)
    hold on
end

xlim([0, 27]);
grid on
xlabel('time (min) ', 'fontsize', 16);
ylabel(strcat('deformation'), 'fontsize', 16)
legend(num2str(Osm_num(sel)), 'location', 'eastoutside')
legend('boxoff')
text(30, 0.04, 'mOsm', 'FontSize', 11)

print(fullfile(saveto, 'Osm_Time_response_Deformation.tiff'), '-dtiff', '-r300')

%% Plot Median RD vs Time

f2 = figure;

for aa = 1:length(sel)
    ii = sel(aa)
    plot(data{ii}(:, 1), data{ii}(:, 2)/Dcnt, '*-', 'color', cmp(aa, :), 'linewidth', 3)
    hold on
end

xlim([0, 27]);
ylim([0.2, 1.8]);

grid on
xlabel('time (min) ', 'fontsize', 16);
ylabel(strcat('\it{RD}'), 'fontsize', 16)
legend(num2str(Osm_num(sel)), 'location', 'eastoutside')
legend('boxoff')
text(30, 0.75, 'mOsm', 'FontSize', 11)

print(fullfile(saveto, 'Osm_Time_response_RD.tiff'), '-dtiff', '-r300')

%%  Plot Median RD vs Time BIN SELECTED

f3 = figure;

for aa = 1:length(sel)
    ii = sel(aa)
    plot(data{ii}(:, 1), data{ii}(:, 6)/DcntBin, '*-', 'color', cmp(aa, :), 'linewidth', 3)
    hold on
end

xlim([0, 27]);
ylim([0.2, 1.8]);

grid on
xlabel('time (min) ', 'fontsize', 16);
ylabel(strcat('\it{RD}'), 'fontsize', 16)
legend(num2str(Osm_num(sel)), 'location', 'eastoutside')
legend('boxoff')
text(30, 0.75, 'mOsm', 'FontSize', 11)

print(fullfile(saveto, 'Osm_Time_response_RD_sizeSel.tiff'), '-dtiff', '-r300')

%% Plot Time vs Size Median

f4 = figure;

for aa = 1:length(sel)
    ii = sel(aa);
    plot(data{ii}(:, 1), data{ii}(:, 3), '*-', 'color', cmp(aa, :), 'linewidth', 3)
    hold on
end
xlim([0, 27]);
ylim([11, 16])

grid on
xlabel('time (min) ', 'fontsize', 16);
ylabel(['cell diameter (', char(181), 'm)'], 'Interpreter', 'tex', 'fontsize', 16)
legend(num2str(Osm_num(sel)), 'location', 'eastoutside')
legend('boxoff')
text(30, 12.7, 'mOsm', 'FontSize', 11)

print(fullfile(saveto, 'Osm_Time_response_Diameter.tiff'), '-dtiff', '-r300')
