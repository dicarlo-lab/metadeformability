function [diam_ind, def_ind, mean_diam] = Osm_prep(sets_headers, sets_col)
%diam_ind - indices of column containing diameter values for each method
%def_ind - indices of column containing deformability values for each method
%meandiam - mean diameter of all measurments performed with given method;
%           meandiam +/-0.5um is defined as a bin for size-selected data

diam_ind = [
    find(~cellfun(@isempty, strfind(sets_headers{1}, 'DiameterV_um')));
    find(~cellfun(@isempty, strfind(sets_headers{2}, 'DiameterA_um')));
    find(~cellfun(@isempty, strfind(sets_headers{3}, 'DiameterA_um')));
    ];
%DiameterV_um - diameter calculated for equivalent sphere from Volume [um];
%DiameterA_um - diameter calculated for equivalent circle from area [um];
%DiameterA_um  - size in the direction perpendicular to flow +/- 30 deg [um];

def_ind = [
    find(~cellfun(@isempty, strfind(sets_headers{1}, 'Deform')));
    find(~cellfun(@isempty, strfind(sets_headers{2}, 'Deform')));
    find(~cellfun(@isempty, strfind(sets_headers{3}, 'Deform')));
    ];

for ii = 1:length(sets_col)
    mean_diam(ii, 1) = mean(sets_col{ii}(:, diam_ind(ii)));
end