function [f, n_frm] = regpath(img_path, row, col)
% REGPATH  Discover operetta image files and extract meta information.
%   [F, N_FRM] = REGPATH() registers all image files it can find in the
%   current directory.
%   [F, N_FRM] = REGPATH(IMG_PATH) registers all image files it can find
%   in the directory specified by IMG_PATH.
%   [F, N_FRM] = REGPATH(IMG_PATH, ROW, COL) registers those image files in
%   directory IMG_PATH that were taken from the well specified by at ROW
%   and COL.
%   The result structure F has fields identifying row, column, site,
%   channel, and frame index (order in time), in addition to the name of
%   the image file. N_FRM is the largest index among all frames. Sam
COLUMBUS_INDEX_FILE = 'columbus-image-index.txt';
if nargin == 0
    img_path = pwd();
end
if img_path(end) ~= '/'
    img_path = [img_path, '/'];
end
assert((nargin == 0) || (nargin == 2) || (nargin == 3), ...
    'incomplete specification of target well or directory');
if nargin == 3
    varargs = {row, col};
else
    varargs = {};    
end
if exist(COLUMBUS_INDEX_FILE, 'file')
    [f, n_frm] = regcolumbus(img_path, varargs{:});
else
    [f, n_frm] = regharmony(img_path, varargs{:});
end
