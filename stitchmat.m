function stitchmat(row, col, mov1_expdir, mov2_expdir, varargin)
% STITCHMAT  Connect trace packs from two time segments.
%   STITCHMAT(ROW, COL, MOV1_EXPDIR, MOV2_EXPDIR, MODE) connects trace
%   packs from the well at ROW and COL from two time segments. MOV1_EXPDIR
%   must be the directory in which trace packs from the first segment are
%   located. MOV2_EXPDIR must be the directory in which trace packs from
%   the second segment are located. MODE can be 'auto' (the default) or
%   'click'. In automatic mode, images are aligned using images expected in
%   the subdirectory 'Images/' each of MOV1_EXPDIR and MOV2_EXPDIR. In
%   click mode, the user is be asked to connect one identity of cells by
%   clicking, and the distance is used as a displacement estimate.
%   Connected trace packs are written into the current directory. Sam
MIN_DIST2 = 8 ^ 2;
IMG_SEARCH = 'Images/r%02dc%02df%02dp01-ch1sk';
IMG_PATTERN = 'r\d+c\d+f\d+p01-ch1sk(\d+)fk';
mode_is_auto = true();
if length(varargin) == 2
    assert(strcmp(varargin{1}, 'mode'), 'invalid argument');
    mode_is_auto = strcmp(varargin{2}, 'auto');
    if ~mode_is_auto
        assert(strcmp(varargin{2}, 'click'), ...
            'invalid option for parameter mode');
    end
end
if mov1_expdir(end) ~= '/'
    mov1_expdir = [mov1_expdir, '/'];
end
if mov2_expdir(end) ~= '/'
    mov2_expdir = [mov2_expdir, '/'];
end
matfile = [wellname(row, col), '.mat'];
fp1 = load([mov1_expdir, matfile]);
x1_end = fp1.x(end, :);
y1_end = fp1.y(end, :);
frmidx1 = [0, fp1.frmidx'];
n_site = length(fp1.frmidx);
fp2 = load([mov2_expdir, matfile]);
x2_start = fp2.x(1, :);
y2_start = fp2.y(1, :);
assert(n_site == length(fp2.frmidx), 'number of sites do not match');
frmidx2 = [0, fp2.frmidx'];
flds = {'area', 'cfp', 'edge', 'fret', 'momp', 'rfp', 'x', 'y'};
for f = 1 : length(flds)
    fp.(flds{f}) = [];
end
for site = 1 : n_site
    idx_2_0 = frmidx2(site) + 1;
    idx_2_1 = frmidx2(site + 1);
    x2_site_start = x2_start(idx_2_0 : idx_2_1);
    y2_site_start = y2_start(idx_2_0 : idx_2_1);
    idx_1_0 = frmidx1(site) + 1;
    idx_1_1 = frmidx1(site + 1);
    x1_site_end = x1_end(idx_1_0 : idx_1_1);
    y1_site_end = y1_end(idx_1_0 : idx_1_1);
    if mode_is_auto
        % estimate stage error, read last image of first movie
        sca = 0.25;
        files = dir([mov1_expdir, sprintf(IMG_SEARCH, row, col, site), ...
            '*.tiff']);
        sk_max = 1;
        img_file = [];
        for k = 1 : length(files)
            tok = regexp(files(k).name, IMG_PATTERN, 'tokens');
            if isempty(tok)
                continue
            end
            sk = str2double(tok{1}{1});
            if sk > sk_max
                sk_max = sk;
                img_file = [mov1_expdir, 'Images/', files(k).name];
            end
        end
        im1 = imread(img_file);
        im1 = imresize(im1, sca);
        % read first image of second movie
        img_file = [mov2_expdir, 'Images/', ...
            sprintf('r%02dc%02df%02dp01-ch1sk1fk1fl1.tiff', row, col, ...
            site)];
        im2 = imread(img_file);
        im2 = imresize(im2, sca);
        % find shift between two images, first is reference and select
        % cells from current site
        [dx, dy] = getshift(im1, im2, 16);
        dx = dx / sca;
        dy = dy / sca;
    else
        % this means we want to find the shift by clicking
        scatter(x1_site_end, y1_site_end, 'k');
        hold on;
        scatter(x2_site_start, y2_site_start, 'r');
        hold off;
        text(300, 500, 'Click an identity of cells, the red one first.');
        [cx, cy] = ginput(2);
        dx = cx(2) - cx(1);
        dy = cy(2) - cy(1);
    end
    x2_site_start = x2_site_start + dx;
    y2_site_start = y2_site_start + dy;
    % find nearest neighbor
    n_cells = length(x1_site_end);
    idx_next = nan(n_cells, 1);
    n_match = 0;
    for k = 1 : n_cells
        d = (x2_site_start - x1_site_end(k)).^2 + (y2_site_start - ...
            y1_site_end(k)).^2;
        [min_d, idx] = min(d);
        if min_d < MIN_DIST2
            idx_next(k) = idx;
            n_match = n_match + 1;
        end
    end
    is_good = ~isnan(idx_next);
    idx_good = idx_next(is_good);
    for f = 1 : length(flds)
        f1 = fp1.(flds{f});
        f1 = f1(:, idx_1_0 : idx_1_1);
        f2 = fp2.(flds{f});
        f2 = f2(:, idx_2_0 : idx_2_1);
        fp.(flds{f}) = [fp.(flds{f}), [f1(:, is_good); f2(:, idx_good)]];
    end
    fp.dx = [fp1.dx, dx, fp2.dx];
    fp.dy = [fp1.dy, dy, fp2.dy];
    save(matfile, '-struct', 'fp');
end
