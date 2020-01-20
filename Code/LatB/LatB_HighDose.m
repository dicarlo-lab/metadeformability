clear all
cd(fileparts(matlab.desktop.editor.getActiveFilename))

%define source path
source_path = '../../Data_Raw/LatB_HighDose';

%define path to save plots to
saveto = '../../Figures/LatB_HighDose';
if exist(saveto, 'dir') ~= 7
    mkdir(saveto)
end

%default for plots
set(0, 'defaultAxesFontSize', 12)
set(0, 'defaultAxesFontName', 'Helvetica')

%define colors for plotting
colors = [162, 51,  137; ...
          87,  178, 107; ...
          17,  132, 69] ./ 255;

%% Load RTDC data

dirinfo = dir(fullfile(source_path, '/RTDC', '*.txt'));
dirinfo = dirinfo(~[dirinfo.isdir]);

selbin = 13.8799; %set as for the main LatB dataset
mins = selbin - 0.5;
maxs = selbin + 0.5;

for ii = 1:length(dirinfo)
    data{ii} = dlmread(fullfile(source_path, '/RTDC', dirinfo(ii).name), '\t', 1, 0);
    fullname{ii, 1} = dirinfo(ii).name;
    conc(ii, 1) = data{ii}(1, 3);
    ifLatB(ii, 1) = data{ii}(1, 2);
    indsel{ii} = find(data{ii}(:, 4) >= mins & data{ii}(:, 4) < maxs);
    datasel{ii} = data{ii}(indsel{ii}, :);
end

concRTDC = conc(ifLatB == 1) .* 1000;

dataCat = vertcat(datasel{:});
headers = {'Date', 'IfLatB', 'Conc', 'DiameterA_um', 'Def'};

dataDMSO = datasel(ifLatB == 0);
dataLatB = datasel(ifLatB == 1);

MediansDMSO = cellfun(@median, dataDMSO, 'UniformOutput', false);
MedDMSO = vertcat(MediansDMSO{:});

for ii = 1:length(dataLatB)
    dataLatB{ii}(:, 6) = dataLatB{ii}(:, 5) ./ MedDMSO(ii, 5);
end

MediansLatB = cellfun(@median, dataLatB, 'UniformOutput', false);
MedLatB = vertcat(MediansLatB{:});

MADLatB = cellfun(@mad, dataLatB, 'UniformOutput', false);
MADLatBCol = vertcat(MADLatB{:});


MeansLatB = cellfun(@mean, dataLatB, 'UniformOutput', false);
MeansLatB = vertcat(MeansLatB{:});

StDevLatB = cellfun(@std, dataLatB, 'UniformOutput', false);
StDevLatBCol = vertcat(StDevLatB{:});

%% SMR data
load(fullfile(source_path, '/SMR/SMR_HighDose_all'));
headersSMR = {'IfLatB', 'Conc', 'volume', 'diameter', 'pt', 'Def'};

selbin = 13.1774; %set as for the main LatB dataset
mins = selbin - 0.5;
maxs = selbin + 0.5;

for ii = 1:length(SMR)
    b = regexp(SMR(ii).name, '(0.)?[0-9]*u', 'match');
    if ~isempty(b)
        Conc(ii, 1) = str2num(b{1, 1}(1:end - 1));
    else
        Conc(ii, 1) = 0;
    end
    
    if any(regexp(SMR(ii).name, 'DMSO'))
        logi(ii, 1) = 0;
    else if any(regexp(SMR(ii).name, 'LatB'))
            logi(ii, 1) = 1;
        else
            logi(ii, 1) = 2;
        end
    end
    
    uni = ones(length(SMR(ii).volume), 1);
    
    dataSMR{ii} = [uni .* logi(ii), uni .* Conc(ii), SMR(ii).volume.', ...
        [2 .* (3 / 4 .* SMR(ii).volume ./ pi).^(1 / 3)].', SMR(ii).pt.', 1 ./ SMR(ii).pt.'];
    
    indselSMR{ii} = find(dataSMR{ii}(:, 4) >= mins & dataSMR{ii}(:, 4) < maxs);
    dataselSMR{ii} = dataSMR{ii}(indselSMR{ii}, :);
end

dataCatSMR = vertcat(dataselSMR{:});

dataSMRDMSO{1} = dataCatSMR(dataCatSMR(:, 1) == 0 & dataCatSMR(:, 2) == 0.05, :);
dataSMRDMSO{2} = dataCatSMR(dataCatSMR(:, 1) == 0 & dataCatSMR(:, 2) == 5, :);

dataSMRLatB{1} = dataCatSMR(dataCatSMR(:, 1) == 1 & dataCatSMR(:, 2) == 0.05, :);
dataSMRLatB{2} = dataCatSMR(dataCatSMR(:, 1) == 1 & dataCatSMR(:, 2) == 5, :);

MediansSMRDMSO = cellfun(@median, dataSMRDMSO, 'UniformOutput', false);
MedSMRDMSO = vertcat(MediansSMRDMSO{:});

for ii = 1:2
    dataSMRLatB{ii}(:, 7) = dataSMRLatB{ii}(:, 6) ./ MedSMRDMSO(ii, 6);
end

MediansSMRLatB = cellfun(@median, dataSMRLatB, 'UniformOutput', false);
MedSMRLatB = vertcat(MediansSMRLatB{:});

MeansSMRLatB = cellfun(@mean, dataSMRLatB, 'UniformOutput', false);
MeansSMRLatB = vertcat(MeansSMRLatB{:});

MADSMRLatB = cellfun(@mad, dataSMRLatB, 'UniformOutput', false);
MADSMRLatBCol = vertcat(MADSMRLatB{:});

StDevSMRLatB = cellfun(@std, dataSMRLatB, 'UniformOutput', false);
StDevSMRLatBCol = vertcat(StDevSMRLatB{:});

concSMR = [50; 500];

%%
f = figure('Units', 'centimeters', 'Position', [1.5, 1.5, 16, 12])
errorbar(concRTDC(5:8), MedLatB(5:8, 6), MADLatBCol(5:8, 6), '.', 'linewidth', 2, 'color', colors(3, :), 'MarkerSize', 40)
hold on
errorbar(concRTDC(1:4), MedLatB(1:4, 6), MADLatBCol(1:4, 6), '.', 'linewidth', 2, 'color', colors(2, :), 'MarkerSize', 50)
hold on

errorbar(concSMR, MedSMRLatB(:, 7), MADSMRLatBCol(:, 7), '.', 'linewidth', 2, 'color', colors(1, :), 'MarkerSize', 40)

grid on
set(gca, 'xscale', 'log')
xlim([5, 1000])
ylim([0.6, 2])
legend('sDC rep1', 'sDC rep2', 'cDC')
xlabel('LatB concentration (ng ml^{-1})')
ylabel('Relative Deformability')

print(fullfile(saveto, 'LatB_HighDose.tiff'), '-dtiff', '-r300')
