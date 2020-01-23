clear all
cd(fileparts(matlab.desktop.editor.getActiveFilename))

%define source path
source_path_DC = '../../Data_Raw/Strain/DC';

%define path to save plots to
saveto = '../../Data_processed/Strain';
if exist(saveto, 'dir') ~= 7
    mkdir(saveto)
end

%% DC load data
load(fullfile(source_path_DC, 'DC_controlCellMeasurements.mat'))
headers = controlCellMeasurements(1, :);
data = cell2mat(controlCellMeasurements(2:end, :));
dDC = data(:, 1);
dDC_mean = mean(dDC); %cell diameter for undeformed sphere
rDC = dDC ./ 2;
rDC_mean = mean(rDC); %cell radius for undeformed sphere
aDC = data(:, 3) ./ 2;
aDC_mean = mean(aDC); %size along major axis
bDC = data(:, 4) ./ 2;
bDC_mean = mean(bDC); %size along minor axis

%volume of undeformed sphere from cell radius
VsDC = 4/3 .* pi .* rDC.^3;
%size along axis perpendicular to the imaging plane
cDC = 3/4 * VsDC ./ (pi .* aDC .* bDC);
cDC_mean = mean(cDC);

%% DC Estimate Strain

theta = [-1 * pi:2 * pi / 100:pi];
for ii = 1:length(aDC)
    %generate ellipse equation (with the center at the origin) in polar coordinates, for planes xy, xz, and yz, for each cell,
    %based on its a, b, and c dimensions
    elipseDCxy(:, ii) = aDC(ii) * bDC(ii) ./ sqrt((bDC(ii) .* cos(theta)).^2+(aDC(ii) .* sin(theta)).^2);
    elipseDCxz(:, ii) = aDC(ii) * cDC(ii) ./ sqrt((cDC(ii) .* cos(theta)).^2+(aDC(ii) .* sin(theta)).^2);
    elipseDCyz(:, ii) = bDC(ii) * cDC(ii) ./ sqrt((cDC(ii) .* cos(theta)).^2+(bDC(ii) .* sin(theta)).^2);
    %calculate strain along the angle theta expressed as a relative
    %distance between the radius of undeformed sphere and the distance to
    %the ellipse center
    strainDCxy(:, ii) = (elipseDCxy(:, ii) - rDC(ii)) ./ rDC(ii);
    strainDCxz(:, ii) = (elipseDCxz(:, ii) - rDC(ii)) ./ rDC(ii);
    strainDCyz(:, ii) = (elipseDCyz(:, ii) - rDC(ii)) ./ rDC(ii);
end

%calculate average and std of many cell strains in planes xy, xz, and yz
strainDCxy_mean = mean(strainDCxy, 2);
strainDCxy_SD = std(strainDCxy, 1, 2);
strainDCxz_mean = mean(strainDCxz, 2);
strainDCxz_SD = std(strainDCxz, 1, 2);
strainDCyz_mean = mean(strainDCyz, 2);
strainDCyz_SD = std(strainDCyz, 1, 2);

strainDC_mean = [strainDCxy_mean, strainDCxz_mean, strainDCyz_mean];
strainDC_SD = [strainDCxy_SD, strainDCxz_SD, strainDCyz_SD];

save(fullfile(saveto, 'strainDC_mean'), 'strainDC_mean');
save(fullfile(saveto, 'strainDC_SD'), 'strainDC_SD');
