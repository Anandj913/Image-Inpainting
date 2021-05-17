function [d] = findDistance(pixA, pixB)
% compute euclidean distance between pixA and pixB
d  = sum((pixA - pixB) .^ 2);
end
