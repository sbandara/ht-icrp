function im = bgmesh(im, dx, dy)
% BGMESH  Subtract background by mesh grid interpolation of tile modes.
%   IM = BGMESH(IM, DX, DY) determines local background estimates with
%   tile size DX by DY in image IM. DX and DY must be even numbers. Sam
assert(mod(dx, 2) == 0, 'specified tile width is uneven number of pixels');
assert(mod(dy, 2) == 0, ...
    'specified tile height is uneven number of pixels');
bg = blockproc(im, [dy, dx], @bg_sub);
x = dx / 2 : dx : size(im, 2);
y = dy / 2 : dy : size(im, 1);
x0 = min(x);
x1 = max(x);
y0 = min(y);
y1 = max(y);
bg = interp2(x, y, bg, x0 : x1, (y0 : y1)');
im = im(y0 : y1, x0 : x1) - bg;

function bg = bg_sub(im)
% local background estimate is obtained by finding the mode of the
% log-transformed intensity distribution.
[n_I, I] = hist(log(im.data(:)), im.blockSize(1) * im.blockSize(2) / 100);
n_I = conv(n_I, normpdf(-5 : 5, 0, 3), 'same');
[~, bg] = max(n_I);
bg = exp(I(bg));
