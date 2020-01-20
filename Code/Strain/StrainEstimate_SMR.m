clear all
cd(fileparts(matlab.desktop.editor.getActiveFilename))

%define source path
source_path_SMR = '../../Data_Raw/Osm/SMR';

%define path to save plots to
saveto = '../../Data_processed/Strain';
if exist(saveto, 'dir') ~= 7
    mkdir(saveto)
end

%% SMR load data
% load sample control dataset (at osmolairty 300 mOsm)

dirinfo1 = dir(fullfile(source_path_SMR, '*.mat'));
% Ignore header file
header_index = ~cellfun(@isempty, strfind({dirinfo1(:).name}', 'Headers'));
set1heads = importdata(fullfile(source_path_SMR, dirinfo1(header_index).name));

dirinfo1 = dirinfo1(~header_index);
clear header_index
for ii = 1:length(dirinfo1)
    set1{ii} = importdata(fullfile(source_path_SMR, dirinfo1(ii).name));
end
clear dirinfo1

setsel = set1{1, 1};
clear  set1
clear ind300
ind300 = find(setsel(:, 1) == 300);
dataSMR = setsel(ind300, :);
clear setsel ind300

dSMR = dataSMR(:, 4); %cell diameter for undeformed sphere
VSMR = dataSMR(:, 3); %cell volume
rSMR = dSMR ./ 2; %cell diameter for undeformed sphere
%the cell is considered as an ellipsoid with the characteristic diemnsions
%a, b and c

%% SMR Estimate Strain
%let's set some limitis for the values of a,b, and c
bSMR0 = 3; % most of the cells are squeeed to the size of the constiction width of 6 um (unless the original cell radius is <3um)
cmax = 7.5; % the maximum of c is defined by the constriction hight of 15 um
%Velipsoid = 4/3*pi*a*b*c
%assuming therw would be no limits for c, a=c
%Velipsoid = 4/3*pi*c*c*b
% c = sqrt(3/4.*VSMR./(pi*b))
cSMR = sqrt(3/4.*VSMR./(pi .* bSMR0));
theta = [-1 * pi:2 * pi / 100:pi];

for ii = 1:length(dSMR)
    %if cell radius is below 3 we assume it doesn't get deformed
    if rSMR(ii) < 3
        aSMR(ii, 1) = rSMR(ii, 1);
        bSMR(ii, 1) = rSMR(ii, 1);
        cSMR(ii, 1) = rSMR(ii, 1);
        
        %if cell radius is between 3 and 7.5, b=3, and we assume a=c and is
        %calculated from V = 4/3*pi*c*c*b
    else
        if cSMR(ii) < 7.5
            bSMR(ii, 1) = bSMR0;
            cSMR(ii, 1) = cSMR(ii, 1);
            aSMR(ii, 1) = cSMR(ii, 1);
            
            %if cell radius is above 7.5, b=3, c=cmax, and a is calculated from
            %V = 4/3*pi*a*b*c
        else
            bSMR(ii, 1) = bSMR0;
            cSMR(ii, 1) = cmax;
            aSMR(ii, 1) = 3 / 4 .* VSMR(ii, 1) ./ (pi .* bSMR0 .* cmax);
        end
    end
    
    %generate elipse equation (with the center at the origin) in polar coordinates, for planes xy, xz, and yz, for each cell,
    %based on its a, b, and c dimensions
    elipseSMRxy(:, ii) = aSMR(ii, 1) .* bSMR(ii, 1) ./ sqrt((bSMR(ii, 1) .* cos(theta)).^2+(aSMR(ii, 1) .* sin(theta)).^2);
    elipseSMRxz(:, ii) = aSMR(ii, 1) .* cSMR(ii, 1) ./ sqrt((cSMR(ii, 1) .* cos(theta)).^2+(aSMR(ii, 1) .* sin(theta)).^2);
    elipseSMRyz(:, ii) = bSMR(ii, 1) .* cSMR(ii, 1) ./ sqrt((cSMR(ii, 1) .* cos(theta)).^2+(bSMR(ii, 1) .* sin(theta)).^2);
    
    %calculate strain along the angle theta expressed as a relative
    %distance between the radius of undeformed sphere and the distance to
    %the ellipse center
    strainSMRxy(:, ii) = (elipseSMRxy(:, ii) - rSMR(ii)) ./ rSMR(ii);
    strainSMRxz(:, ii) = (elipseSMRxz(:, ii) - rSMR(ii)) ./ rSMR(ii);
    strainSMRyz(:, ii) = (elipseSMRyz(:, ii) - rSMR(ii)) ./ rSMR(ii);
    
end

strainSMRxy_mean = mean(strainSMRxy, 2);
strainSMRxy_SD = std(strainSMRxy, 1, 2);

strainSMRxz_mean = mean(strainSMRxz, 2);
strainSMRxz_SD = std(strainSMRxz, 1, 2);

strainSMRyz_mean = mean(strainSMRyz, 2);
strainSMRyz_SD = std(strainSMRyz, 1, 2);

strainSMR_mean = [strainSMRxy_mean, strainSMRxz_mean, strainSMRyz_mean];
strainSMR_SD = [strainSMRxy_SD, strainSMRxz_SD, strainSMRyz_SD];

save(fullfile(saveto, 'strainSMR_mean'), 'strainSMR_mean');
save(fullfile(saveto, 'strainSMR_SD'), 'strainSMR_SD');
