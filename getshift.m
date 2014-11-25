function [dx, dy] = getshift(ref, im, max_shift)
% GETSHIFT  Determine the displacement between two images.
%   [DX, DY] = GETSHIFT(REF, IM, MAX_SHIFT) determines the displacement of
%   image IM relative to a reference image REF based on intensity
%   correlation. MAX_SHIFT is largest possible shift to consider. Sam
steps = [floor(max_shift / 4), 1, 1, 1];
lpf = lowpass(11, 0.5);
pyr_ref = pyramidize(ref, lpf);
pyr_im = pyramidize(im, lpf);
x0 = 0;
y0 = 0;
dx = 0;
dy = 0;
next_crop = steps(1);
for k = 1 : length(steps) - 1
    % iteratively shift downsampled images of increasing resolution
    n_crop = next_crop;
    n_steps = steps(k);
    n_corr = 2 * n_steps + 1;
    dx = dx * 2;
    dy = dy * 2;
    gamma = intshift(pyr_ref{k}, pyr_im{k}, n_steps, n_crop, x0, y0);
    [~, max_ind] = max(gamma(:));
    [ymax, xmax] = ind2sub([n_corr, n_corr], max_ind);
    dx = dx + xmax - n_steps - 1;
    dy = dy + ymax - n_steps - 1;
    next_crop = n_crop * 2 + steps(k + 1);
    x0 = next_crop + dx * 2 - steps(k + 1);
    y0 = next_crop + dy * 2 - steps(k + 1);
end
% use peak interpolation of gamma to determine sub-pixel shift
gamma = intshift(ref, im, steps(end), n_crop + steps(end), n_crop + dx, ...
    n_crop + dy);
[sub_dx, sub_dy] = quadpk2d(gamma);
dx = dx + sub_dx;
dy = dy + sub_dy;


function pyr = pyramidize(im, lpf)
pyr = {[], [], im};
for sca = length(pyr) : -1 : 2
    lpf_ref = filter2(lpf, pyr{sca});
    pyr{sca - 1} = lpf_ref(1 : 2 : end, 1 : 2 : end);
end


function gamma = intshift(ref, im, n_steps, n_crop, x0, y0)
n_corr = 2 * n_steps + 1;
ref_cntr = ref(1 + n_crop : end - n_crop, 1 + n_crop : end - n_crop);
[row_corr, col_corr] = size(ref_cntr);
ref_avg = sum(ref_cntr(:)) / (row_corr * col_corr);
gamma = zeros(n_corr);
x_pos = 1;
for x = 1 + x0 : (x0 + n_corr)
    y_pos = 1;
    for y = 1 + y0 : (y0 + n_corr)
        im_avg = sum(sum(im(y : row_corr + y - 1, ...
            x : col_corr + x - 1))) / (row_corr * col_corr);
        gamma(y_pos, x_pos) = sum(sum((im(y : row_corr + y - 1, x : ...
            col_corr + x - 1) - im_avg) .* (ref_cntr - ref_avg)));
        y_pos = y_pos + 1;
    end
    x_pos = x_pos + 1;
end
