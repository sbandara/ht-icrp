function rc = r0merge(pth_base, r0fret, frfret, rng_row, rng_col, n_site)
% R0MERGE  Attach RFP fluorescence estimate from initial time point.
%   RC = R0MERGE(PTH_BASE, R0FRET, FRFRET, RNG_ROW, RNG_COL, N_SITE) reads
%   RFP fluorescence of images in subdirectory R0FRET of PTH_BASE, and
%   assigns it to FRET traces of movie in subdirectory FRFRET. Trace packs
%   must be located directly in PTH_BASE. RNG_ROW and RNG_COL designate
%   the range of wells to iterate over, and N_SITE is the number of sites
%   per well. RC is the exit code for use in bash scripts. Sam
if pth_base(end) ~= '/'
    pth_base = [pth_base, '/'];
end
ptn0 = [pth_base, r0fret, '/r%02dc%02df%02dp01-ch%dsk1fk1fl1.tiff'];
ptn1 = [pth_base, frfret, '/r%02dc%02df%02dp01-ch%dsk1fk1fl1.tiff'];
for row = rng_row
    for col = rng_col
        packfile = wellname(row, col);
        try
            fretpack = load([packfile, '.mat']);
        catch
            fprintf('failed to load data package for well %s.\n', ...
                packfile);
            continue
        end
        fretpack.rfp0 = nan(1, size(fretpack.fret, 2));
        idx0 = 1;
        for site = 1 : n_site
            % background intensity must be subtracted to make alignment by
            % correlation possible
            sca = 0.25;
            fname = sprintf(ptn0, row, col, site, 2);
            im_cfp0 = double(imread(fname));
            im_cfp0 = bgmesh(im_cfp0, 170, 128);
            im_cfp0 = imresize(im_cfp0, sca);
            fname = sprintf(ptn1, row, col, site, 2);
            im_cfp1 = double(imread(fname));
            im_cfp1 = bgmesh(im_cfp1, 170, 128);
            im_cfp1 = imresize(im_cfp1, sca);
            [dx, dy] = getshift(im_cfp0, im_cfp1, 16);
            dx = dx / sca;
            dy = dy / sca;
            fprintf('dx: %f  dy: %f\n', dx, dy);
            % wrap call to standard extract procedure
            f0 = struct('name', {}, 'row', {}, 'col', {}, 'site', {}, ...
                'frm', {}, 'ch', {});
            for k = 1 : 3
                f0(k).name = sprintf(ptn0, row, col, site, k);
                f0(k).row = row;
                f0(k).col = col;
                f0(k).site = site;
                f0(k).frm = 1;
                f0(k).ch = k;
                f0(k).datenum = nan;
            end
            res = extract(f0, 1, row, col, site);
            rfp0 = [res.c.rfp];
            idx1 = fretpack.frmidx(site);
            r0_obj = res.c;
            fp_obj = struct('x', {}, 'y', {});
            for k = idx0 : idx1
                fp_obj(k - idx0 + 1).x = fretpack.x(1, k);
                fp_obj(k - idx0 + 1).y = fretpack.y(1, k);
            end
            t = struct('c', {r0_obj, fp_obj}, 'dx', {0, dx}, 'dy', ...
                {0, dy});
            [~, t] = trackbidir(t);
            for k = idx0 : idx1
                loc_idx = k - idx0 + 1;
                prev = t(2).c(loc_idx).prev;
                if prev == 0
                    continue
                end
                next = t(1).c(prev).next;
                if next == loc_idx
                    fretpack.rfp0(k) = rfp0(prev);
                end
            end
            idx0 = idx1 + 1;
        end
        save([packfile, '-RFP0.mat'], '-struct', 'fretpack');
    end
end
rc = 0;
