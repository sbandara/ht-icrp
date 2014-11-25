function rc = mergesites(pth_base)
% MERGESITES  Combine trace results from multisite imaging.
%   RC = MERGESITES(PTH_BASE) combines trace packs from multiple sites per
%   well into a single trace pack. Trace packs are discovered in the folder
%   specified by PTH_BASE. An additional field `frmidx` is attached which
%   designates the index boundaries between sites. You can use this
%   function before `r0merge` and never after. RC is the exit code for use
%   in bash scripts. Sam
if pth_base(end) ~= '/'
    pth_base = [pth_base, '/'];
end
fprintf('detecting site packages in %s\n', pth_base);
file = dir([pth_base, '*.mat']);
well = struct('site', {});
for k = 1 : length(file)
    tok = regexp(file(k).name, '([A-H])(\d\d)-(\d)', 'tokens');
    if isempty(tok)
        continue
    end
    tok = tok{1};
    row = tok{1} - 'A' + 1;
    col = str2double(tok{2});
    s = str2double(tok{3});
    fprintf('%d %d %d\n', row, col, s);
    well(row, col).site(s).fname = file(k).name;
end
for row = 1 : size(well, 1)
    for col = 1 : size(well, 2)
        n_site = length(well(row, col).site);
        if n_site == 0
            continue
        end
        fret = [];
        is_gap = [];
        area = [];
        cfp = [];
        x = [];
        y = [];
        momp = [];
        rfp = [];
        edge = [];
        dx = []; %#ok<*NASGU>
        dy = [];
        frmidx = zeros(n_site, 1);
        for k = 1 : n_site
            pack = load([pth_base, wellname(row, col), '-', num2str(k), ...
                '.mat']);
            fret = [fret, pack.fret]; %#ok<*AGROW>
            if isempty(is_gap)
                is_gap = pack.is_gap;
                dx = pack.dx;
                dy = pack.dy;
            else
                is_gap = is_gap | pack.is_gap;
            end
            area = [area, pack.area];
            cfp = [cfp, pack.cfp];
            x = [x, pack.x];
            y = [y, pack.y];
            momp = [momp, pack.momp];
            rfp = [rfp, pack.rfp];
            edge = [edge, pack.edge];
            frmidx(k) = max(frmidx) + size(pack.fret, 2);
        end
        save([pth_base, wellname(row, col), '.mat'], 'fret', 'is_gap', ...
            'area', 'cfp', 'momp', 'rfp', 'x', 'y', 'edge', 'dx', 'dy', ...
            'frmidx');
    end
end
rc = 0;
