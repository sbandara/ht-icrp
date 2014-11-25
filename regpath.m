function [f, n_frm] = regpath(img_path, arg_row, arg_col)
% REGPATH  Discover operetta image files and extract meta information.
%   [F, N_FRM] = REGPATH() registers all image files it can find in the
%   current directory.
%   [F, N_FRM] = REGPATH(IMG_PATH) registers all image files it can find
%   in the directory specified by IMG_PATH.
%   [F, N_FRM] = REGPATH(IMG_PATH, ARG_ROW, ARG_COL) registers those image
%   files in directory IMG_PATH that were taken from the well specified by
%   at ARG_ROW and ARG_COL.
%   The result structure F has fields identifying row, column, site,
%   channel, and frame index (order in time), in addition to the name of
%   the image file. N_FRM is the largest number of frames taken per well
%   and can be understood as the length of a live-cell movie. Sam
if nargin == 0
    file_ptn = '';
else
    if img_path(end) ~= '/'
        file_ptn = [img_path, '/'];
    else
        file_ptn = img_path;
    end
end
if nargin == 3
    file_ptn = [file_ptn, sprintf('r%02dc%02d', arg_row, arg_col)];
end
assert(nargin ~= 2, 'incomplete specification of target wellor directory');
file_ptn = [file_ptn, '*.tiff'];
f = dir(file_ptn);
f = rmfield(f, 'date');
f = rmfield(f, 'isdir');
f = rmfield(f, 'bytes');
% File naming convention changed recently, so it could be either of those:
fmt1 = 'r(\d+)c(\d+)f(\d+)p01rc(\d)-ch1sk(\d+)fk';
fmt2 = 'r(\d+)c(\d+)f(\d+)p01-ch(\d)sk(\d+)fk';
k = 0;
n_frm = 0;
while k < length(f)
    k = 1 + k;
    tok = regexp(f(k).name, fmt1, 'tokens');
    if isempty(tok)
        tok = regexp(f(k).name, fmt2, 'tokens');
    end
    if isempty(tok)
        fprintf(['unable to match ', f(k).name]);
        f(k) = [];
        continue
    end
    tok = tok{1};
    f(k).row = str2double(tok{1});
    f(k).col = str2double(tok{2});
    f(k).site = str2double(tok{3});
    f(k).ch = str2double(tok{4});
    f(k).frm = str2double(tok{5});
    if f(k).frm > n_frm
        n_frm = f(k).frm;
    end
end
