%this function loads osmotic shock data
%set1: SMR; set2: RT-DC; set3: DC;

function [osm, sets, sets_col, sets_headers] = Osm_Load_Data()
%used osmolarities [mOsm]
osm = [200; 250; 300; 400; 500; 600; 700];

% set current directory to the directory of this script
cd(fileparts(matlab.desktop.editor.getActiveFilename))

data_folder = '../../Data_Raw/Osm/SMR';
dirinfo1 = dir(fullfile(data_folder, '*.mat'));
% Ignore header file
header_index = ~cellfun(@isempty, strfind({dirinfo1(:).name}', 'Headers'));
set1heads = importdata(fullfile(data_folder, dirinfo1(header_index).name));

dirinfo1 = dirinfo1(~header_index);
for ii = 1:length(dirinfo1)
    set1{ii} = importdata(fullfile(data_folder, dirinfo1(ii).name));
end
set1col = vertcat(set1{:});


data_folder = '../../Data_Raw/Osm/RT-DC';
dirinfo2 = dir(fullfile(data_folder, '*.mat'));
% Ignore header file
header_index = ~cellfun(@isempty, strfind({dirinfo2(:).name}', 'Headers'));
set2heads = importdata(fullfile(data_folder, dirinfo2(header_index).name));

dirinfo2 = dirinfo2(~header_index);
for ii = 1:length(dirinfo2)
    set2{ii} = importdata(fullfile(data_folder, dirinfo2(ii).name));
end
set2col = vertcat(set2{:});

data_folder = '../../Data_Raw/Osm/DC';
dirinfo3 = dir(fullfile(data_folder, '*.mat'));
% Ignore header file
header_index = ~cellfun(@isempty, strfind({dirinfo3(:).name}', 'Headers'));
set3heads = importdata(fullfile(data_folder, dirinfo3(header_index).name));

dirinfo3 = dirinfo3(~header_index);
for ii = 1:length(dirinfo3)
    set3{ii} = importdata(fullfile(data_folder, dirinfo3(ii).name));
    set3{ii}(:, 4) = 4 / 3 .* pi .* ((set3{ii}(:, 2) ./ 2).^3);
end
set3heads = [set3heads, 'Volume_um3'];
set3col = vertcat(set3{:});

sets = {set1, set2, set3};
sets_col = {set1col, set2col, set3col};
sets_headers = {set1heads, set2heads, set3heads};
