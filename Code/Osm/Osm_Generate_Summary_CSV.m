clear all
cd(fileparts(matlab.desktop.editor.getActiveFilename))

%directory to save the csv summaries
saveto = '../../Data_Processed/Osm/';
if exist(saveto, 'dir') ~= 7
    mkdir(saveto)
end

%% Open the files

[osm, sets, sets_col, sets_headers] = Osm_Load_Data();
[diam_ind, def_ind, meandiam] = Osm_prep(sets_headers, sets_col);

osmStr = {'hypo2', 'hypo1', 'ctrl', 'hyper1', 'hyper2', 'hyper3', 'hyper4'};
methods = {'SMR', 'RTDC', 'DC'};

%% Creat summaries SMR, RTDC, DC
[summary, factor_all, summary_headers] = Osm_summarize(sets, diam_ind, def_ind, meandiam, osm, osmStr);

%% Save Summary CSV files for Statistical Analysis

%%%%%%% Following columns are included:
            % 1 - LatB - treatement group defined by LatB conc used
            % 2 - Deformability,
            % 3 - Relative_Deformability
            %       - medians, as caluclated from 1-um diameter binned data
            % 4 - Exp - experiemntal series number
            % 5 - Deformability_All,
            % 6 - Relative_Deformability_All
            %       - calculated without size bin
            % 7 - Size - median diameter

for i = 1:numel(methods)
    
    factor = factor_all{i}; %string describing treatment group
    data = summary{i};
    
    T0 = array2table(data, 'VariableNames', summary_headers);
    T0 = horzcat(table(factor, 'VariableNames', {'factor'}), T0);
    
    writetable(T0, [saveto, 'Osm_', methods{i}, '_Medians_Summary.csv'])
    
    clear T0 data
    
end
