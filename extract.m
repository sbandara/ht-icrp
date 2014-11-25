function res = extract(f, n_frm, row, col, site)
% EXTRACT  Extract single-cell data from epithelial FRET reporter cells.
%   RES = EXTRACT(F, N_FRM, ROW, COL, SITE) analyzes images in file set F
%   up to frame number N_FRM of SITE in the well at ROW and COL. Results
%   RES include FRET ratio, death metrics, and cell positions. Sam
res = struct('t', {}, 'c', {}, 'dx', {}, 'dy', {}, 'is_gap', {});
old_im = [];
jitter_scale = 0.25;
scaled_max_jitter = 10;
for frm = 1 : n_frm
    im_A = [];
    im_B = [];
    im_C = [];
    for k = 1 : length(f)
        if f(k).row == row && f(k).col == col && f(k).site == site ...
                && f(k).frm == frm
            im = single(imread(f(k).name));
            if f(k).ch == 1
                im_A = bgmesh(im, 170, 128);
            elseif f(k).ch == 2
                im_B = bgmesh(im, 170, 128);
            elseif f(k).ch == 3
                im_C = bgmesh(im, 170, 128);
            end
        end
    end
    res(frm).is_gap = false();
    if isempty(im_A) || isempty(im_B)
        res(frm) = res(frm - 1);
        res(frm).is_gap = true();
        continue
    end
    try
        % prepare watershed for further segmentation
        im_flt = conv2(im_A, fspecial('gaussian', 12, 5), 'same');
        ws = watershed(-im_flt);
        % threshold based on pixel-to-pixel variability
        t = 3 * prctile(abs(im_A(:)), 20);
        msk = im_A > t;
        msk(ws == 0) = 0;
        msk = bwmorph(msk, 'erode', 3);
        [L, num] = bwlabel(msk);
        % align channels to correct for chromatic aberration
        [dx, dy] = getshift(im_A, im_B, 5);
        im_B = shiftimg(im_B, dx, dy);
        if ~isempty(im_C)
            [dx, dy] = getshift(im_A, im_C, 5);
            im_C = shiftimg(im_C, dx, dy);
        end
        rp = regionprops(L, 'area', 'centroid');
        c = struct('fr', {}, 'b', {}, 'x', {}, 'y', {}, 'area', {}, ...
            'prev', {}, 'next', {}, 'momp', {}, 'edge', {}, 'rfp', {});
        for k = 1 : num
            ss_msk = (L == k);
            a = im_A(ss_msk);
            b = im_B(ss_msk);
            c(k).b = median(b);
            c(k).fr = median(a ./ b);
            c(k).x = rp(k).Centroid(1);
            c(k).y = rp(k).Centroid(2);
            if ~isempty(im_C)
                c(k).momp = momploc(im_A, im_C, ss_msk);
                c(k).rfp = prctile(im_C(ss_msk), 80);
            else
                c(k).momp = nan();
                c(k).rfp = nan();
            end
            c(k).area = rp(k).Area;
            c(k).edge = edginess(ss_msk, im_A, roi_y, roi_x);
        end
        fprintf('%d / %d processed\n', frm, n_frm);
        % calculate jitter estimate
        lo_res_A = imresize(im_A, jitter_scale);
        if isempty(old_im)
            dx = [];
            dy = [];
        else
            [dx, dy] = getshift(old_im, lo_res_A, scaled_max_jitter);
        end
        old_im = lo_res_A;
    catch err
        disp(err.message);
        res(frm) = res(frm - 1);
        res(frm).is_gap = true();
        continue
    end
    if ~isempty(dx)
        res(frm).dx = dx / jitter_scale;
        res(frm).dy = dy / jitter_scale;
    end
    res(frm).t = f(frm).datenum;
    res(frm).c = c;
end
