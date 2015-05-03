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

n_frm = 0;
f = struct('name', {}, 'row', {}, 'col', {}, 'site', {}, 'ch', {}, ...
    'frm', {});

if nargin == 3
    % index only images in well (row, col)
    
else
    % index all images
    
end
