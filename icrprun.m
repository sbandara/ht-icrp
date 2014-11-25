function rc = icrprun(pth_base, pth_cr, str_row, str_col, str_site)
% ICRPRUN  Main entry point for IC-RP analysis.
%   RC = ICRPRUN(PTH_BASE, PTH_CR, STR_ROW, STR_COL) processes all movies
%   in PTH_CR, a subdirectory of PTH_BASE, in the well in row STR_ROW and
%   column STR_COL. If images were taken on multiple sites, this will be
%   recognized and all sites processed.
%   RC = ICRPRUN(PTH_BASE, PTH_CR, STR_ROW, STR_COL, STR_SITE) is identical
%   to the above, except that only the site designated by STR_SITE is
%   processed. This helps distribute load over more orchestra nodes. Use
%   `mergesites` to combine multisite results into a single trace pack.
%   RC is the return code for Unix/LSF deployment. Sam
row = str2double(str_row);
col = str2double(str_col);
fprintf(['registering IC-RP and MOMP-RP files in ', pwd(), '\n']);
[f, n_frm] = register_path([pth_base, '/', pth_cr], row, col);
if ~n_frm
    fprintf('no fret images from row%02d col%02d\n', row, col);
    rc = 0;
    return
end
n_site = max([f.site]);
fprintf('%d site(s) in row%02d col%02d\n', n_site, row, col);
for k = 1 : length(f)
    f(k).name = [pth_base, '/', pth_cr, '/', f(k).name];
end
fret = [];
offset = 0;
frmidx = zeros(n_site, 1);
if nargin == 5
    sites = str2double(str_site);
    fprintf('operating on site %d\n', sites);
else
    sites = 1 : n_site;
end
for site = sites
    fl_cr = extract(f, n_frm, row, col, site);
    if isempty(fl_cr)
        fprintf(['no results for ', wellname(row, col),'\n']);
        continue
    end
    tr_idx = trackbidir(fl_cr);
    n_t = size(tr_idx, 1);
    n_cells = size(tr_idx, 2);
    if isempty(fret)
        if nargin == 5
            fret = nan(n_t, n_cells);
        else
            fret = nan(n_t, n_cells * n_site * 2);
        end
        area = fret;
        cfp = fret;
        x = fret;
        y = fret;
        momp = fret;
        rfp = fret;
        edge = fret;
        is_gap = false(n_t, 1);
    end
    for t = 1 : size(tr_idx, 1)
        is_gap(t) = is_gap(t) | fl_cr(t).is_gap;
        for c = 1 : n_cells
            if tr_idx(t, c)
                fret(t, c + offset) = fl_cr(t).c(tr_idx(t, c)).fr;
                area(t, c + offset) = fl_cr(t).c(tr_idx(t, c)).area;
                cfp(t, c + offset) = fl_cr(t).c(tr_idx(t, c)).b;
                x(t, c + offset) = fl_cr(t).c(tr_idx(t, c)).x;
                y(t, c + offset) = fl_cr(t).c(tr_idx(t, c)).y;
                momp(t, c + offset) = fl_cr(t).c(tr_idx(t, c)).momp;
                rfp(t, c + offset) = fl_cr(t).c(tr_idx(t, c)).rfp;
                edge(t, c + offset) = ...
                    median(fl_cr(t).c(tr_idx(t, c)).edge);
            end
        end
    end
    offset = offset + n_cells;
    frmidx(site) = offset;
    if (site == n_site) || (nargin == 5)
        dx = [fl_cr.dx]; %#ok<*NASGU>
        dy = [fl_cr.dy];
    end
end
if size(fret, 2) > offset
    % trim pre-allocated memory from result matrices
    fret(:, offset + 1 : end) = [];
    area(:, offset + 1 : end) = [];
    cfp(:, offset + 1 : end) = [];
    x(:, offset + 1 : end) = [];
    y(:, offset + 1 : end) = [];
    momp(:, offset + 1 : end) = [];
    rfp(:, offset + 1 : end) = [];
    edge(:, offset + 1 : end) = [];
end
if nargin == 5
    save([pth_base, '/', wellname(row, col), '-', str_site, '.mat'], ...
        'fret', 'is_gap', 'area', 'cfp', 'momp', 'rfp', 'x', 'y', ...
        'edge', 'dx', 'dy', 'frmidx');
else
    save([pth_base, '/', wellname(row, col), '.mat'], 'fret', ...
        'is_gap', 'area', 'cfp', 'momp', 'rfp', 'x', 'y', 'edge', 'dx', ...
        'dy', 'frmidx');
end
fprintf('output written to MAT file. OK.\n');
rc = 0;
