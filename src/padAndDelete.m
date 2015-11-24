function [ cleaned ] = padAndDelete( binaryIm )
%PADANDDELETE Delete regions that touch the edges of the image.
%   CLEANED = PADANDDELETE(BINARYINVERSED) takes a binary image with noise
%                           regions that are touching the edge and fills
%                           those regions with background color. This is
%                           achieved by first padding the input image with
%                           a single white line on each edge, which will be
%                           then labeled as region 1. This region then is
%                           set to 0, and the padded edge is being removed.

cleaned = padarray(binaryIm, [1 1], 1);
labeledInv = bwlabel(cleaned);
cleaned(labeledInv == 1) = 0;
cleaned = cleaned(2:end-1, 2:end-1);

end

