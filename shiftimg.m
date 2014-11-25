function dest = shiftimg(src, dx, dy)
% SHIFTIMG  Shift image by a specified offset with subpixel resolution.
%   DEST = SHIFTIMG(SRC, DX, DY) returns the image SRC shifted by DX and
%   DY pixels. DX and DY do not need to be integers. Boundaries are padded
%   with zeros.
[row, col] = size(src);
x_move_int = floor(dx);
y_move_int = floor(dy);
x_part_lo = dx - x_move_int;
x_part_hi = 1 - x_part_lo;
y_part_lo = dy - y_move_int;
y_part_hi = 1 - y_part_lo;
Hx = zeros(col);
Hy = zeros(row);
% create bilinear shift transformation matrices
Hx = Hx + x_part_hi * (diag(ones(col, 1), 0)) + x_part_lo * ...
    (diag(ones(col - 1, 1), -1));
Hy = Hy + y_part_hi * (diag(ones(row, 1), 0)) + y_part_lo * ...
    (diag(ones(row - 1, 1), -1));
% pad with zeros
if x_move_int < 0
    Hx = [Hx; zeros((-x_move_int), col)];
    Hx(1 : (-x_move_int), :) = [];
else
    Hx = [zeros(x_move_int, col); Hx];
    Hx = Hx(1 : col, :);
end
if y_move_int < 0
    Hy = [Hy; zeros((-y_move_int), row)];
    Hy(1 : (-y_move_int), :)=[];
else
    Hy = [zeros(y_move_int, row); Hy];
    Hy = Hy(1 : row, :);
end
% transform
dest = Hy' * src * Hx;
