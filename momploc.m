function momp = momploc(im_uni, im_momp, ss_msk)
% MOMPLOC  Calculate death metric "momp" by localization of MOMP reporter.
%   MOMP = MOMPLOC(IM_UNI, IM_MOMP, SS_MSK) determines "momp" from an image
%   IM_UNI of a uniformly localized GFP, an image of the IMS-RP reporter
%   construct, and a mask matrix SS_MSK of the cell of interest. Sam
a = im_uni(ss_msk);
max_a = max(a);
ss_max = (im_uni == max_a) & ss_msk;
idx_lin_max = find(ss_max(:), 1, 'first');
[roi_y, roi_x] = ind2sub(size(ss_max), idx_lin_max);
roi_momp = im_momp(roi_y - 2 : roi_y + 2, roi_x - 2 : roi_x + 2);
momp = prctile(roi_momp(:), 5);
