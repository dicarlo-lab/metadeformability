clear all

cd(fileparts(matlab.desktop.editor.getActiveFilename))

% Add folder to path to use:
% - load_colors()
addpath('../Utils')

saveto = '../../Figures/Osm_DifferentBins';
if exist(saveto, 'dir') ~= 7
    mkdir(saveto)
end

%settings for plots
set(0, 'DefaultAxesFontName', 'Helvetica');
set(0, 'DefaultAxesFontSize', 14);

%% Load data
[osm, sets, sets_col, sets_headers] = Osm_Load_Data();
[diam_ind, def_ind, meandiam] = Osm_prep(sets_headers, sets_col);

osmStr = {'hypo2', 'hypo1', 'ctrl', 'hyper1', 'hyper2', 'hyper3', 'hyper4'};
methods = {'cDC', 'sDC', 'xDC'};

%% Calculate values for different bin selections
clear outall

for aa = 1:length(methods)
    set0 = sets{aa};
    outall = [];
    factor = {};
    d = diam_ind(aa);
    def = def_ind(aa);
    for ii = 1:length(set0)
        set = set0{ii};
        indsel1 = find(set(:, d) >= meandiam(aa)-0.5 & set(:, d) <= meandiam(aa)+0.5);
        indsel3 = find(set(:, d) >= meandiam(aa)-1.5 & set(:, d) <= meandiam(aa)+1.5);
        setsel1 = set(indsel1, :);
        setsel3 = set(indsel3, :);
        indcnt = find(set(:, 1) == 300);
        indcnt1 = find(setsel1(:, 1) == 300);
        indcnt3 = find(setsel3(:, 1) == 300);
        
        medcnt = median(set(indcnt, def));
        medcnt1 = median(setsel1(indcnt1, def));
        medcnt3 = median(setsel3(indcnt3, def));
        
        check = unique(set(:, 1));
        
        for cc = 1:length(check)
            class(cc, 1) = find(osm == check(cc));
            
            ind = find(set(:, 1) == check(cc));
            ind1 = find(setsel1(:, 1) == check(cc));
            ind3 = find(setsel3(:, 1) == check(cc));
            
            size(cc, 1) = median(set(ind, d));
            
            med(cc, 1) = median(set(ind, def));
            med1(cc, 1) = median(setsel1(ind1, def));
            med3(cc, 1) = median(setsel3(ind3, def));
            
            RD(cc, 1) = med(cc) ./ medcnt;
            RD1(cc, 1) = med1(cc) ./ medcnt1;
            RD3(cc, 1) = med3(cc) ./ medcnt3;
            if ~isempty(ind)
                nall(cc, 1) = length(ind);
                nsel1(cc, 1) = length(ind1);
                perc1(cc, 1) = nsel1(cc, 1) / nall(cc, 1);
            else
                nall(cc, 1) = NaN;
                nsel1(cc, 1) = NaN;
                perc1(cc, 1) = NaN;
            end
            
            clear ind ind1 ind3
        end
        exp = ii .* ones(length(check), 1);
        out = [check, med, RD, med1, RD1, med3, RD3, nall, nsel1, perc1, exp, size, class];
        outall = [outall; out];
        clear indcnt indcnt1 indcnt3 check out med med1 med3 RD RD1 RD3
        clear set setsel1 setsel3 medcnt medcnt1 medcnt3 size class perc1 nsel1 nall
    end
    
    clear set0
    summary{aa} = outall;
    clear outall
end


% final table summary
for aa = 1:length(summary)
    for ii = 1:length(osm)
        ind = find(summary{aa}(:, 1) == osm(ii));
        meanS(ii, 1) = mean(summary{aa}(ind, 12));
        SDS(ii, 1) = std(summary{aa}(ind, 12));
        meanall(ii, 1) = mean(summary{aa}(ind, 3));
        mean3(ii, 1) = mean(summary{aa}(ind, 7));
        mean1(ii, 1) = mean(summary{aa}(ind, 5));
        SDall(ii, 1) = std(summary{aa}(ind, 3));
        SD3(ii, 1) = std(summary{aa}(ind, 7));
        SD1(ii, 1) = std(summary{aa}(ind, 5));
        n(ii, 1) = length(ind);
        
    end
    table{aa} = [osm, meanall, SDall, mean3, SD3, mean1, SD1, meanS, SDS, n];
end

%% Bin Strategies Comparison - groupped by Bins
ylims = [0.1, 1.3];
xlims = [0.5, 2.5];
ms = 25;
colors = load_colors('main');

g = figure;
g.Units = 'centimeters';
g.OuterPosition = [0.1, 0.1, 27, 10];

subplot(1, 3, 1)
for aa = 1:3
    errorbar(osm./300, table{aa}(:, 2), table{aa}(:, 3), '.-', 'linewidth', 2, 'color', colors(aa, :), 'MarkerSize', ms);
    xlim(xlims);
    ylim(ylims);
    ylabel('Relative Deformability')
    hold on
end
box on
grid on
legend(methods, 'location', 'northeast')

subplot(1, 3, 2)
for aa = 1:3
    errorbar(osm./300, table{aa}(:, 4), table{aa}(:, 5), '.-', 'linewidth', 2, 'color', colors(aa, :), 'MarkerSize', ms);
    xlim(xlims);
    ylim(ylims);
    xlabel('\it{Osm/Osm_{iso}}')
    hold on
end
box on
grid on
legend(methods, 'location', 'northeast')

subplot(1, 3, 3)
for aa = 1:3
    errorbar(osm./300, table{aa}(:, 6), table{aa}(:, 7), '.-', 'linewidth', 2, 'color', colors(aa, :), 'MarkerSize', ms);
    xlim(xlims);
    ylim(ylims);
    hold on
end
box on
grid on
legend(methods, 'location', 'northeast')

ax = findobj(g, 'Type', 'Axes');

title(ax(3), {'all events'}, 'Fontweight', 'normal')
title(ax(2), {char(strcat('3 ', {' '}, char(181), 'm bin'))}, 'Fontweight', 'normal')
title(ax(1), {char(strcat('1 ', {' '}, char(181), 'm bin'))}, 'Fontweight', 'normal')

print(fullfile(saveto, 'Osm_Response_DiffBins_ByBin.tiff'), '-dtiff', '-r300')

%% Bin Strategies Comparison - groupped by Method

ylims = [0.1, 1.3];
xlims = [0.5, 2.5];

g = figure;
g.Units = 'centimeters';
g.OuterPosition = [0.1, 0.1, 27, 10]
subplot(1, 3, 1)
aa = 1;
colors = [129, 53, 139; 195, 61, 129; 237, 160, 161] ./ 255;

errorbar(osm./300, table{aa}(:, 2), table{aa}(:, 3), 'linewidth', 2, 'color', colors(1, :));
hold on
errorbar(osm./300, table{aa}(:, 4), table{aa}(:, 5), 'linewidth', 2, 'color', colors(2, :));
hold on
errorbar(osm./300, table{aa}(:, 6), table{aa}(:, 7), 'linewidth', 2, 'color', colors(3, :));

legend('all', char(strcat('3 ', {' '}, char(181), 'm bin')), char(strcat('1 ', {' '}, char(181), 'm bin')), 'location', 'northeast')
xlim(xlims)
ylim(ylims)
grid on
box on
ylabel('Relative Deformability')


subplot(1, 3, 2)
aa = 2;
colors = [50, 174, 125; 124, 187, 87; 195, 216, 139] ./ 255;
errorbar(osm./300, table{aa}(:, 2), table{aa}(:, 3), 'linewidth', 2, 'color', colors(1, :));
hold on
errorbar(osm./300, table{aa}(:, 4), table{aa}(:, 5), 'linewidth', 2, 'color', colors(2, :));
hold on
errorbar(osm./300, table{aa}(:, 6), table{aa}(:, 7), 'linewidth', 2, 'color', colors(3, :));

legend('all', char(strcat('3 ', {' '}, char(181), 'm bin')), char(strcat('1 ', {' '}, char(181), 'm bin')), 'location', 'northeast')
xlim(xlims)
ylim(ylims)
grid on
box on
xlabel('\it{Osm/Osm_{iso}}')

subplot(1, 3, 3)
aa = 3;
colors = [244, 122, 32; 252, 176, 23; 250, 214, 103] ./ 255;
errorbar(osm./300, table{aa}(:, 2), table{aa}(:, 3), 'linewidth', 2, 'color', colors(1, :));
hold on
errorbar(osm./300, table{aa}(:, 4), table{aa}(:, 5), 'linewidth', 2, 'color', colors(2, :));
hold on
errorbar(osm./300, table{aa}(:, 6), table{aa}(:, 7), 'linewidth', 2, 'color', colors(3, :));

legend('all', char(strcat('3 ', {' '}, char(181), 'm bin')), char(strcat('1 ', {' '}, char(181), 'm bin')), 'location', 'northeast')
xlim(xlims)
ylim(ylims)
grid on
box on

ax = findobj(g, 'Type', 'Axes');
title(ax(3), {'cDC'}, 'Fontweight', 'normal')
title(ax(2), {'sDC'}, 'Fontweight', 'normal')
title(ax(1), {'xDC'}, 'Fontweight', 'normal')

print(fullfile(saveto, 'Osm_Response_DiffBins_ByMethod.tiff'), '-dtiff', '-r300')
