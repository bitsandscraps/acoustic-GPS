function idx = find_timing_offset( x, f, fs )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
m = round(fs / f);
singlePeriod = cos(0:(2 * pi / m):(12 * pi));
convResult = abs(conv(x, singlePeriod, 'valid'));
threshold = max(convResult) * 0.8;
found = find(convResult > threshold);
idx = found(1);
end

