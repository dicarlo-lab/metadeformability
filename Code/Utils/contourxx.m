
function [CLine, h] = contourxx(X, Y, varargin)

nbins = [];
lambda = [];
level = [];

okargs = {'smoothing', 'bins', 'level'};
for j = 1:2:nargin - 2
    pname = varargin{j};
    pval = varargin{j+1};
    k = strmatch(lower(pname), okargs); %#ok
    if isempty(k)
        error('Bioinfo:UnknownParameterName', ...
            'Unknown parameter name: %s.', pname);
    elseif length(k) > 1
        error('Bioinfo:AmbiguousParameterName', ...
            'Ambiguous parameter name: %s.', pname);
    else
        switch (k)
            case 1 % smoothing factor
                if isnumeric(pval)
                    lambda = pval;
                else
                    error('Bioinfo:InvalidScoringMatrix', 'Invalid smoothing parameter.');
                end
            case 2 % bins
                if isscalar(pval)
                    nbins = [pval, pval];
                else
                    nbins = pval;
                end
            case 3 % level
                if isscalar(pval)
                    level = [pval, pval];
                else
                    level = [0.5, 0.5];
                end
        end
    end
end


minx = min(X, [], 1);
maxx = max(X, [], 1);
miny = min(Y, [], 1);
maxy = max(Y, [], 1);

if isempty(nbins)
    nbins = [min(numel(unique(X)), 200), min(numel(unique(Y)), 200)];
end

if isempty(lambda)
    lambda = 20;
end

edges1 = linspace(minx, maxx, nbins(1)+1);
ctrs1 = edges1(1:end-1) + .5 * diff(edges1);
edges1 = [-Inf, edges1(2:end-1), Inf];
edges2 = linspace(miny, maxy, nbins(2)+1);
ctrs2 = edges2(1:end-1) + .5 * diff(edges2);
edges2 = [-Inf, edges2(2:end-1), Inf];

[n, p] = size(X);
bin = zeros(n, 2);
% Reverse the columns to put the first column of X along the horizontal
% axis, the second along the vertical.
[dum, bin(:, 2)] = histc(X, edges1);
[dum, bin(:, 1)] = histc(Y, edges2);
H = accumarray(bin, 1, nbins([2, 1])) ./ n;
G = smooth1D(H, nbins(2)/lambda);
F = smooth1D(G', nbins(1)/lambda)';
F2 = F ./ (max(max(F)));
% = filter2D(H,lambda);


[CLine, h] = contour(ctrs1, ctrs2, F2, level);
end
