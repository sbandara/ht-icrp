function [f, n_frm] = regcolumbus(img_path, row, col)
% REGPATH  Discover operetta image files exported by Columbus.
%   [F, N_FRM] = REGPATH(IMG_PATH) registers all image files it can find
%   in the directory specified by IMG_PATH.
%   [F, N_FRM] = REGPATH(IMG_PATH, ROW, COL) registers those image files in
%   directory IMG_PATH that were taken from the well specified by at ROW
%   and COL.
%   The result structure F has fields identifying row, column, site,
%   channel, and frame index (order in time), in addition to the name of
%   the image file. N_FRM is the largest index among all frames. Yvonne

COLUMBUS_INDEX_FILE = 'ImageIndex.ColumbusIDX.csv';
idxM = ClbIdx([img_path, COLUMBUS_INDEX_FILE]);


f = struct('name', {}, 'row', {}, 'col', {}, 'site', {}, 'ch', {}, ...
	   'frm', {}, 'datenum', {});

n = 0;
for k = 1 : length(idxM)
    if nargin == 3 && (idxM(k).Row ~= row || idxM(k).Column ~= col)
        continue
    end
    n = n + 1;
    f(n).row = idxM(k).Row;
    f(n).col = idxM(k).Column;
    f(n).name = idxM(k).sourcefilename;
    f(n).site = str2double(idxM(k).Field);
    f(n).ch = idxM(k).Channel;
    f(n).frm = str2double(idxM(k).Timepoint);
end
n_frm = max([f.frm]);
