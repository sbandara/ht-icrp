function g = edginess(ss_msk, im_A, roi_y, roi_x)
% EDGINESS  Determine death metric "edge" from uniformly localized GFP.
%   G = EDGINESS(SS_MSK, IM_A, ROI_Y, ROI_X) detrmines "edge" in image IM_A
%   for cell identified by single cell mask SS_MSK. ROI_Y and ROI_X must be
%   the precomputed centroid of the cell. Sam
dx = [-1,  0,  1, -1, 1, -1, 0, 1];
dy = [-1, -1, -1,  0, 0,  1, 1, 1];
[hgt, wdt] = size(ss_msk);
n_d = length(dx);
g = zeros(1, n_d);
for d = 1 : n_d
    x = roi_x;
    y = roi_y;
    dist = 0;
    k = 0;
    dI = zeros(1, 5);
    while dist < 3
        prev_I = im_A(y, x);
        x = x + dx(d);
        if x > wdt || x < 1
            break
        end
        y = y + dy(d);
        if y > hgt || y < 1
            break
        end
        k = k + 1;
        dI(1 + mod(k, 5)) = prev_I - im_A(y, x);
        if ~ss_msk(y, x)
            dist = dist + 1;
        end
    end
    g(d) = max(dI);
end
