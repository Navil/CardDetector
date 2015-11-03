function [ value, symbol ] = detectCardValue( card )
%UNTITLED2 Summary of this function goes here
%   CARD An image matrix of a single card with borders.
%   VALUE The value of the card.
%   SYMBOL A binary image of the symbol of the card.

% ajsdlkj


%% Value recognition of segmented card

%  check image if already in double type, if not: convert
if ~isfloat(card)
    card = im2double(card);
end

% check if read is intensity image, convert if not
if ndims(card) > 2;
    greyIm = rgb2gray(card);
else
    greyIm = card;
end

smoothedIm = imgaussfilt(greyIm, 'filtersize', 9);

thld = graythresh(smoothedIm);
binaryIm = false(size(smoothedIm));
binaryIm(smoothedIm > thld) = 1;


inv = ~binaryIm;
padded = padAndDelete(inv);

bb = regionprops(padded, 'BoundingBox');
minSquare = numel(padded);
minLabel = 0;
biggestBox = 0;
biggestLabel = 0;
for i = 1:length(bb)
    originArea = bb(i).BoundingBox(1) * bb(i).BoundingBox(2);
    boxArea = bb(i).BoundingBox(3) * bb(i).BoundingBox(4);
    if originArea < minSquare
        minSquare = originArea;
        minLabel = i;
    end
    if boxArea > biggestBox
        biggestBox = boxArea;
        biggestLabel = i;
    end
end

symbol = imcrop(padded, bb(biggestLabel).BoundingBox);

%{
box = bb(minLabel).BoundingBox;
refPoint =  [box(1) (box(2)+box(4))];
minSquare = numel(padded);
symbolLabel = 0;
for i = 1:length(bb)
    if i == minLabel
        continue;
    end
    box = bb(i).BoundingBox;
    compPoint = [box(1) (box(2)+box(4))];
    tmpSquare = prod(abs(compPoint - refPoint));
    if tmpSquare < minSquare
        minSquare = tmpSquare;
        symbolLabel = i;
    end        
end

symbol2 = imcrop(padded, bb(symbolLabel).BoundingBox);
%}

boundBox = bb(minLabel).BoundingBox;
cropX = boundBox(1) + boundBox(3);
cropWidth = size(padded,2) - 2 * cropX;
croppedCard = logical(imcrop(padded, [cropX, 1, cropWidth, size(padded, 1)]));

[labels, numLabels] = bwlabel(croppedCard);
areas = zeros(numLabels,1);

for i = 1:numLabels
    areas(i) = sum(labels(:) == i);
end

[maxArea, maxIdx] = max(areas);
limit = maxArea * 0.9;
value = sum(areas(:) >= limit);


end

