function [tseg, best_m, cost] = segmorph(edge)
% SEGMORPH  Segment death metric in the time domain.
%   [TSEG, BEST_M, COST] = SEGMORPH(EDGE) segments trajectories of death
%   metrices and finds the three most likely change points according to a
%   least squares assumption. EDGE must be a vector of the death readout
%   (tested for "area", "edge", and "momp"). TSEG is the vector of three
%   changepoints, BEST_M is the best fit vector of means, and COST is the
%   sum of residuals. Sam
m = zeros(4, 1);
n_t = length(edge);
tseg = [];
cost = inf;
best_m = [];
for idx1 = 2 : n_t - 1
    seg_edge = edge(1 : idx1);
    m(1) = mean(seg_edge);
    res0 = sum((m(1) - seg_edge) .^ 2);
    for idx2 = idx1 + 1 : n_t - 1
        res1 = res0;
        seg_edge = edge(idx1 + 1 : idx2);
        m(2) = mean(seg_edge);
        res1 = res1 + sum((m(2) - seg_edge) .^ 2);
        for idx3 = idx2 + 1 : n_t - 1
            res = res1;
            seg_edge = edge(idx2 + 1 : idx3);
            m(3) = mean(seg_edge);
            res = res + sum((m(3) - seg_edge) .^ 2);
            seg_edge = edge(idx3 + 1 : end);
            m(4) = mean(seg_edge);
            res = res + sum((m(4) - seg_edge) .^ 2);
            if res < cost
                cost = res;
                tseg = [idx1, idx2, idx3];
                best_m = m;
            end
        end
    end
end
