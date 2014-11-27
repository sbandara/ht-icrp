function [tseg, least_cost] = segmorph(edge, n_bnd)
% SEGMORPH  Segment death metric in the time domain.
%   [TSEG, BEST_M, COST] = SEGMORPH(EDGE) segments trajectories of death
%   metrics and finds the N_BND most likely change points according to a
%   least mean residual assumption. EDGE must be a vector of the death
%   readout (tested for "area", "edge", and "momp"). TSEG is the vector
%   of three changepoints, and LEAST_COST is the sum of residuals. Sam
n_t = length(edge);
least_cost = inf;
tseg = [];
tseg_sub = [];
for idx = 1 : n_t - n_bnd
    seg_edge = edge(1 : idx);
    cost = sum(abs(mean(seg_edge) - seg_edge));
    if n_bnd == 1
        seg_edge = edge(idx + 1 : end);
        cost = cost + sum(abs(mean(seg_edge) - seg_edge));
    else
        [tseg_sub, cost_sub] = segmorph(edge(idx + 1 : end), n_bnd - 1);
        cost = cost + cost_sub;
    end
    if cost < least_cost
        least_cost = cost;
        tseg = [idx, tseg_sub + idx];
    end
end
