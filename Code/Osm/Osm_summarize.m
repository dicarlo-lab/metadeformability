% this function prepares data summary of the Osm experiments

function [summary, factor_all, summary_headers, table] = Osm_summarize(sets, diam_ind, def_ind, meandiam, osm, osmStr)
% Loop through SMR, RTDC, DC data and generate summaries
% each row contains median values for individual measurment

summary_headers = {'Osm', 'Deformability', 'Relative_Deformability', 'Exp', 'Deformability_All', 'Relative_Deformability_All', 'Size', 'n_all', 'n_sel'};

summary = cell(1, 3);
factor_all = cell(1, 3);

for i = 1:3
    set0 = sets{i};
    outall = [];
    factor = [];
    diam = diam_ind(i);
    def = def_ind(i);
    
    
    for ii = 1:length(set0)
        set = set0{ii};
        indsel1 = find(set(:, diam) >= meandiam(i)-0.5 & set(:, diam) <= meandiam(i)+0.5);
        setsel1 = set(indsel1, :);
        indcnt = find(set(:, 1) == 300);
        indcnt1 = find(setsel1(:, 1) == 300);
        
        medcnt = median(set(indcnt, def));
        medcnt1 = median(setsel1(indcnt1, def));
        
        check = unique(set(:, 1));
        % Initialize Variables
        [med, med1, RD, RD1, class, dia, nall, nsel1, perc1] = deal(zeros(numel(check), 1));
        factor0 = cell(numel(check), 1);
        for cc = 1:length(check)
            class(cc, 1) = find(osm == check(cc));
            factor0{cc, 1} = osmStr(class(cc, 1));
            
            ind = find(set(:, 1) == check(cc));
            ind1 = find(setsel1(:, 1) == check(cc));
            dia(cc, 1) = median(set(ind, diam));
            
            med(cc, 1) = median(set(ind, def));
            med1(cc, 1) = median(setsel1(ind1, def));
            
            RD(cc, 1) = med(cc) ./ medcnt;
            RD1(cc, 1) = med1(cc) ./ medcnt1;
            
            if ~isempty(ind)
                nall(cc, 1) = length(ind);
                nsel1(cc, 1) = length(ind1);
                perc1(cc, 1) = nsel1(cc, 1) / nall(cc, 1);
            else
                nall(cc, 1) = NaN;
                nsel1(cc, 1) = NaN;
                perc1(cc, 1) = NaN;
            end
            clear ind ind1
        end
        experiment = ii .* ones(length(check), 1);
        
        out = [check, med1, RD1, experiment, med, RD, dia, nall, nsel1];
        
        factor = [factor; factor0];
        
        outall = [outall; out];
        
        clear indcnt indcnt1 check out med med1 RD RD1 factor0 experiment dia class
        clear set setsel1 medcnt medcnt1 class nall nsel1 perc1
    end
    
    clear set0
    
    summary{i} = outall;
    factor_all{i} = factor;
    clear outall
end


% claculate means of all medians and SDs

for aa = 1:length(summary)
    for ii = 1:length(osm)
        ind = find(summary{aa}(:, 1) == osm(ii));
        meanS(ii, 1) = mean(summary{aa}(ind, 7));
        SDS(ii, 1) = std(summary{aa}(ind, 7));
        meanall(ii, 1) = mean(summary{aa}(ind, 6));
        mean1(ii, 1) = mean(summary{aa}(ind, 3));
        SDall(ii, 1) = std(summary{aa}(ind, 6));
        SD1(ii, 1) = std(summary{aa}(ind, 3));
        n(ii, 1) = length(ind);
        
    end
    table{aa} = [osm, meanall, SDall, mean1, SD1, meanS, SDS, n];
end
