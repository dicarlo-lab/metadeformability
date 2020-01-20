clear all

cd(fileparts(matlab.desktop.editor.getActiveFilename))

% Add folder to path to use:
% - load_colors()
addpath('../Utils')

% Add folder to path to use:
% - violinplot()
addpath('../Utils/Violinplot-Matlab')

%settings for plots
set(0, 'DefaultAxesFontName', 'Helvetica');
set(0, 'DefaultAxesFontSize', 14);

%colors for plotting
cc = load_colors('shades');
cc = cellfun(@flipud, cc, 'UniformOutput', false);

%directory to save plots
saveto = '../../Figures/Osm_Box/';
if exist(saveto, 'dir') ~= 7
    mkdir(saveto)
end

%% Open the files
[osm, sets, sets_col, sets_headers] = Osm_Load_Data();
[diam_ind, def_ind, meandiam] = Osm_prep(sets_headers, sets_col);

methods = {'SMR', 'RTDC', 'DC'};
set_sel = [2; 4; 2]; % index of selected set for each method

%% Violin Plot Diameter - SLECTED SET

for m = 1:length(methods)
    data = sets{1, m}{1, set_sel(m)};
    
    f = figure
    violin = violinplot(data(:, diam_ind(m)), data(:, 1), 'ShowData', false, ...
        'ViolinColor', cc{m}(1, :), 'BoxColor', [0.2, 0.2, 0.2], 'ViolinAlpha', 0.5);
    for ii = 1:length(violin)
        violin(ii).ViolinColor = cc{m}(ii, :);
        violin(ii).BoxPlot.LineWidth = 4;
        violin(ii).WhiskerPlot.LineWidth = 1;
        violin(ii).ViolinPlot.EdgeColor = 'none';
        x_txt = violin(ii).WhiskerPlot.XData(1) + 0.2;
        y_txt = violin(ii).WhiskerPlot.YData(2);
        text(x_txt, y_txt, strcat('\it n \rm= ', {' '}, num2str(length(violin(ii).ScatterPlot.XData))), ...
            'Rotation', 90, 'FontSize', 12);
        clear x_txt y_txt
    end
    
    ylabel(['cell diameter (', char(181), 'm)'], 'Interpreter', 'tex')
    xlabel(['osmolarity (mOsm)'], 'Interpreter', 'tex')
    ylim([5, 25])
    
    box on
    ax = gca;
    ax.GridLineStyle = ':';
    ax.LineWidth = 1;
    ax.GridAlpha = 0.3;
    
    ax.YGrid = 'on';
    ax.XGrid = 'off';
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [0, 0, 16, 15]);
    print(strcat(saveto, 'Osm_Violin_', methods{m}, '_Size_Set', num2str(set_sel(m)), '.tiff'), '-dtiff', '-r300')
    
    clear data
    
end

%% Violin Plot Relative Deormability - SLECTED SET

for m = 1:length(methods)
    data = sets{1, m}{1, set_sel(m)};
    selind = find(data(:, diam_ind(m)) >= meandiam(m)-0.5 & data(:, diam_ind(m)) <= meandiam(m)+0.5);
    selindcnt = intersect(selind, find(data(:, 1) == 300));
    defmedcnt(m, 1) = median(data(selindcnt, def_ind(m)));
    
    f = figure
    violin = violinplot(data(selind, def_ind(m))./defmedcnt(m, 1), data(selind, 1), 'ShowData', true, ...
        'ViolinColor', cc{m}(1, :), 'BoxColor', [0.2, 0.2, 0.2]);
    for ii = 1:length(violin)
        violin(ii).ViolinColor = cc{m}(ii, :)
        violin(ii).BoxPlot.LineWidth = 4;
        violin(ii).WhiskerPlot.LineWidth = 1;
        violin(ii).ViolinPlot.EdgeColor = 'none';
        x_txt = violin(ii).WhiskerPlot.XData(1) + 0.2;
        y_txt = violin(ii).WhiskerPlot.YData(2);
        text(x_txt, y_txt, strcat('\it n \rm= ', {' '}, num2str(length(violin(ii).ScatterPlot.XData))), ...
            'Rotation', 90, 'FontSize', 12);
        clear x_txt y_txt
    end
    
    ylabel('Relative Deformability')
    xlabel('osmolarity (mOsm)', 'Interpreter', 'tex')
    ylim([0, 2.25])
    
    box on
    ax = gca;
    ax.GridLineStyle = ':';
    ax.LineWidth = 1;
    ax.GridAlpha = 0.3;
    
    ax.YGrid = 'on';
    ax.XGrid = 'off';
    ax.YTick = [0:0.25:3];
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [0, 0, 16, 15]);
    print(strcat(saveto, 'Osm_Violin_', methods{m}, '_RD_Set', num2str(set_sel(m)), '.tiff'), '-dtiff', '-r300')
    clear data selind selindcnt
end
