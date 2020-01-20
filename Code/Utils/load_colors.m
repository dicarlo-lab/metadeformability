function [cc] = load_colors(grouping)
% Loads custom color map from shared .csv file

% Add folder to path to use:
% - csv2cell()
% - hex2rgb()
addpath('../Utils')

if strcmp(grouping, 'shades')
    cc = cell(1, 3);
    hex_cell = csv2cell('../plot_colors_shades.csv', 'fromfile');
    
    method_list = {'SMR', 'RTDC', 'DC'};
    
    for i = 1:numel(method_list)
        for j = 1:numel(cc)
            if strcmp(method_list{i}, hex_cell{1, j})
                cc{i} = hex2rgb(hex_cell(2:end, j));
            end
        end
    end
elseif strcmp(grouping, 'main')
    hex_cell = csv2cell('../plot_colors_main.csv', 'fromfile');
    
    cc = hex2rgb(hex_cell(2:end, :));
end
