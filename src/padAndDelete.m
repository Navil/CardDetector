function [ cleaned ] = padAndDelete( binaryInversed )
%UNTITLED Delete labels that are at the edges of the image.
%   Detailed explanation goes here

cleaned = padarray(binaryInversed, [1 1], 1);
labeledInv = bwlabel(cleaned);
cleaned(labeledInv == 1) = 0;
cleaned = cleaned(2:end-1, 2:end-1);

end

