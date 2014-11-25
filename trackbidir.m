function [tr, res] = trackbidir(res)
% TRACKBIDIR  Track cells by identifying mutual nearest neighbors.
%   [TR, RES] = TRACKBIDIR(RES) returns the tracking matrix TR of cell
%   indices in the segmentation result structure RES. TR is a TxC matrix
%   where T is the numnber of time points and C the number of cells, and
%   tracks are zero-terminated. Only a cell that is the nearest neighbor
%   of its nearest neighbor in the next frame will be tracked. This
%   approach will not work for highly motile cells. Sam
if isempty(res)
    error('empty tracking problem');
end
n_frm = length(res);
for t = 1 : n_frm - 1
    for k0 = 1 : length(res(t).c)
        x0 = res(t).c(k0).x + res(t + 1).dx;
        y0 = res(t).c(k0).y + res(t + 1).dy;        
        x1 = [res(t + 1).c.x];
        y1 = [res(t + 1).c.y];
        d = (x1 - x0) .^ 2 + (y1 - y0) .^ 2;
        [~, res(t).c(k0).next] = min(d);
    end
end
for t = 2 : n_frm
    for k0 = 1 : length(res(t).c)
        x0 = res(t).c(k0).x - res(t).dx;
        y0 = res(t).c(k0).y - res(t).dy;
        x1 = [res(t - 1).c.x];
        y1 = [res(t - 1).c.y];
        d = (x1 - x0) .^ 2 + (y1 - y0) .^ 2;
        [~, res(t).c(k0).prev] = min(d);
    end
end
tr = zeros(n_frm - 1, length(res(1).c));
for k = 1 : length(res(1).c)
    index = k;
    for t = 1 : n_frm - 1
        next = res(t).c(index).next;
        prev = res(t + 1).c(next).prev;
        if prev == index
            tr(t, k) = index;
        else
            break
        end
        index = next;
    end
end
