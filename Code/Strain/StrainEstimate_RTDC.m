clear all
cd(fileparts(matlab.desktop.editor.getActiveFilename))

%define source path
source_path_RTDC = '../../Data_Raw/Strain/RTDC';

%define path to save plots to
saveto = '../../Data_processed/Strain';
if exist(saveto, 'dir') ~= 7
    mkdir(saveto)
end

%% RTDC read in and order data

fileListTxt = dir(fullfile(source_path_RTDC, '*.txt'));
fileListTxt = fileListTxt(~[fileListTxt.isdir]); %clean some subdirectories
filename_cont = fileListTxt(1).name;


fileListTsv = dir(fullfile(source_path_RTDC, '*.tsv'));
fileListTsv = fileListTsv(~[fileListTsv.isdir]); %clean some subdirectories
filename_Tsv = fileListTsv(1).name;

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Read-in contours %%%

fid = fopen(fullfile(source_path_RTDC, filename_cont));
S = textscan(fid, '%[Contour]%[in]%[frame]%n');
N = 0;
while ~isempty(S{1})
    N = N + 1; %Count number of contours
    FrameNo(N, 1) = S{4}; %Frame No
    C0 = textscan(fid, '( %f %f )', 'Delimiter', ',', 'CollectOutput', 1);
    C{1, N} = C0{1, 1};
    S = textscan(fid, '%[Contour]%[in]%[frame]%n');
    clear C0
end
fclose(fid);

clear fid S

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Read-in Shape-Out extended data %%%
dataX = importdata(fullfile(source_path_RTDC, filename_Tsv));
headers = dataX.colheaders;
TabData = dataX.data;
clear dataX

%%% interesct TabData and Contours Data based on frame no and keep only
%%% cells that exist in both datasets
[inter, ind_TD, indFN] = intersect(TabData(:, 11), FrameNo(:));
TabData = TabData(ind_TD, :);
C = C(indFN);

%%%% filter for AR (1, 1.05) and Area (50, 500)
sela = find(TabData(:, 4) > 50 & TabData(:, 4) < 500);
selar = find(TabData(:, 3) >= 1 & TabData(:, 3) < 1.05);
indF = intersect(sela, selar);
TabData = TabData(indF, :);
C = C(indF);

r0_A = sqrt(TabData(:, 4)./pi);
r0_Vol = (3 / 4 .* TabData(:, 20) ./ pi).^(1 ./ 3);

%% RTDC Estimate Strain
% Transform the contour into polar coordinates rho(tetha)
clear RHO
N_interp = 101;
for i = 1:length(C)
    clear theta rho
    
    %x and y coordinates of each contour in um
    x = C{i}(:, 1) .* 0.34;
    y = C{i}(:, 2) .* 0.34;
    K = convhull(x, y);
    
    %polygeom returns area, X centroid, Y centroid and perimeter for the planar polygon
    geo = polygeom(x, y);
    geo_hull = polygeom(x(K), y(K));
    
    x1 = x(K) - geo_hull(2);
    y1 = y(K) - geo_hull(3);
    
    [theta, rho] = cart2pol(x(K)-geo_hull(2), y(K)-geo_hull(3));
    theta(theta < 0) = theta(theta < 0) + 2 * pi;
    theta = theta - pi;
    indU = find(unique(theta));
    theta = theta(indU);
    rho = rho(indU);
    
    [thetaS, iT] = sort(theta);
    rhoS = rho(iT);
    
    thetaCol{i} = thetaS;
    rhoCol{i} = rhoS;
    %rearrange vectors theta and rho to start with smallest (positive)
    %value of theta and map theta onto 0:2pi plus adding first value to the
    %end of vector at theta(1)+2pi and adding the first negative value of theta to
    %the front to create overlap for correct interpolation
    l = length(theta);
    ind = find(theta >= 0);
    theta_sort = NaN(size(theta));
    rho_sort = NaN(size(rho));
    
    if ind(1) > 1
        theta_sort(1:end-(ind(1) - 1)) = theta(ind(1):end);
        rho_sort(1:end-(ind(1) - 1)) = rho(ind(1):end);
        theta_sort(end-(ind(1) - 2):end) = theta(1:ind(1)-1);
        rho_sort(end-(ind(1) - 2):end) = rho(1:ind(1)-1);
    elseif ind(end) == l
        ind2 = find(theta < 0);
        theta_sort(1:l-ind2(end)) = theta(ind2(end)+1:end);
        rho_sort(1:l-ind2(end)) = rho(ind2(end)+1:end);
        theta_sort(l-ind2(end)+1:end) = theta(1:ind2(end));
        rho_sort(l-ind2(end)+1:end) = rho(1:ind2(end));
    else
        theta_sort = theta;
        rho_sort = rho;
    end
    theta_sort = (theta_sort >= 0) .* theta_sort + (theta_sort < 0) .* (theta_sort + 2 * pi);
    
    theta_sort = [theta_sort(end) - 2 * pi; theta_sort; theta_sort(1) + 2 * pi];
    rho_sort = [rho_sort(end); rho_sort; rho_sort(1)];
    
    theta_set = linspace(0, 2*pi-2*pi/N_interp, N_interp);
    theta_set = linspace(0, 2*pi, N_interp) - pi;
    
    strainRTDCxy(:, i) = (interp1(thetaS, (rhoS - r0_Vol(i))./r0_Vol(i), theta_set'))';
end

strainRTDCxy_mean = nanmean(strainRTDCxy, 2);
strainRTDCxy_SD = nanstd(strainRTDCxy, 1, 2);
strainRTDCxy_SD(isnan(strainRTDCxy_SD)) = 0
%we assume that the bullet shape optained in RTDC is symetrical around the
%flow directon axis, therefore the strain will have the same profile in xy
%and xz planes

strainRTDCxz_mean = strainRTDCxy_mean;
strainRTDCxz_SD = strainRTDCxy_SD;

strainRTDC_mean = [strainRTDCxy_mean, strainRTDCxz_mean];
strainRTDC_SD = [strainRTDCxy_SD, strainRTDCxz_SD];

save(fullfile(saveto, 'strainRTDC_mean'), 'strainRTDC_mean');
save(fullfile(saveto, 'strainRTDC_SD'), 'strainRTDC_SD');
