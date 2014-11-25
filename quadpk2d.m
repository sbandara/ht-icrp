function [dx, dy] = quadpk2d(b)
% QUADPK2D  Calculate sub-pixel shift by quadratic peak interpolation.
%   [DX, DY] = QUADPK2D(B) calculates the sub-pixel shifts DX and DY to
%   the center the peak of 3x3 matrix B.
[X, Y] = meshgrid(-1 : 1, -1 : 1);
A = [ones(length(X(:)), 1), X(:), Y(:), X(:) .^ 2, Y(:) .^ 2, X(:) .* Y(:)];
c = pinv(A) * b(:);
dx = (2 * c(2) * c(5) - c(3) * c(6)) / (c(6) ^ 2 - 4 * c(4) * c(5));
dy = (2 * c(3) * c(4) - c(2) * c(6)) / (c(6) ^ 2 - 4 * c(4) * c(5));
if dx > 1
    dx = 1;
end
if dx < -1
    dx = -1;
end
if dy > 1
    dy = 1;
end
if dy < -1
    dy = -1;
end
