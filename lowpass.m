function filter_matrix = lowpass(order, cutoff)
% LOWPASS  Create a lowpass filter for the filter2 function.
%   FILTER_MATRIX = LOWPASS(ORDER, CUTOFF) creates a lowpass filter with
%   size ORDER x ORDER and cutoff CUTOFF between 0 and 1.
assert(cutoff > 0 && cutoff < 1);
[f1, f2] = freqspace(order, 'meshgrid');
d = find(f1 .^ 2 + f2 .^ 2 < cutoff ^ 2);
Hd = zeros(order);
Hd(d) = ones(size(d));
filter_matrix = fsamp2(Hd);
