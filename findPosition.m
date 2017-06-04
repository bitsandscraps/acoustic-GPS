% EE405C<Network of Smart Systems> Final Project - Wed 1(Acoustic GPS)
% findPosition.m
% Copyright 2017 by KIM Kwanwoo and PARK Jongeui
% First written: 2017-05-24
% Last updated:  2017-06-04

function position = findPosition( R )
% R must be a row vector
global X
global Y
INITIAL = [0.5 0.5 0];
OPTIONS = optimoptions(@lsqnonlin, 'Algorithm', 'levenberg-marquardt', ...
                       'display', 'off');
targetFunc = @(r) sum((sqrt((r(1) - X) .^ 2 + (r(2) - Y) .^2) ...
                       + r(3) - R) .^2);
position = lsqnonlin(targetFunc, INITIAL, [], [], OPTIONS);
end
