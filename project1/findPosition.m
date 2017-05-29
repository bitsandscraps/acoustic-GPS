function r = findPosition( X, Y, R )
targetFunc = @(r) sum(sqrt((r(1) - X) .^ 2 + (r(2) - Y) .^2 + r(3) - R) .^2);
r = lsqnonlin(targetFunc, [0.5 0.5 0]);
end

