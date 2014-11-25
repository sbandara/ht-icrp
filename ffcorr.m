function im = ffcorr(im, obj)
% FFCORR  Perform flat-field correction according to calibration.
%   IM = FFCORR(IM, OBJ) Approximate flat-field correction of image IM
%   that was taken with a certain imaging setup OBJ. Currently, only
%   'PE1334-10xLWD' ("live-cell operetta" with 10x long WD objective) is
%   a valid option. IM must be background-subtracted.   Sam 10/31/2013
%   Calibration protocol: 3 uL TetraSpeck (4.0 um, Invitrogen T7283,
%   Megason lab has) in 30 uL PBST, let settle in 1 well of COSTAR3603.
persistent coeff;
assert(isa(im, 'float'), '`im` must be float (single or double)');
% load tiles of median bead intensities from calibration file.
assert(strcmp(obj, 'PE1334-10xLWD'), 'objective not calibrated');
if isempty(coeff)
   coeff = load([obj, '.mat']);
end
[ny, nx] = size(coeff.I);
% interpolate `gain` matrix from tiles of medians
dx = coeff.wdt / nx;
dy = coeff.hgt / ny;
gain = interp2((0.5 : nx) * dx, (0.5 : ny) * dy, coeff.I, ...
   0.5 * dx : (nx - 0.5) * dx, (0.5 * dy : (ny - 0.5) * dy)', 'spline');
% center and crop image `im` to valid range of `gain`
px0 = round(size(im) ./ 2 - size(gain) ./ 2);
px1 = px0 + size(gain) - 1;
im = im(px0(1) : px1(1), px0(2) : px1(2));
% normalize
im = im ./ gain;
