% EE405C<Network of Smart Systems> Final Project - Wed 1(Acoustic GPS)
% findPosition.m
% Copyright 2017 by KIM Kwanwoo and PARK Jongeui
% First written: 2017-05-24
% Last updated:  2017-05-26

function position = findPosition( R )
X = [0 0.891 0 0.891];
Y = [0 0 0.42 0.42];
INITIAL = [0.5 0.5 0];
OPTIONS = optimoptions(@lsqnonlin, 'Algorithm', 'levenberg-marquardt', ...
                       'display', 'off');
targetFunc = @(r) sum((sqrt((r(1) - X) .^ 2 + (r(2) - Y) .^2) + r(3) - R) .^2);
position = lsqnonlin(targetFunc, INITIAL, [], [], OPTIONS);
end
