function [ value, symbol, valueBox, symbolBox ] = detectCardValue(card, fastMode)
% DETECTCARDVALUE(CARD, FASTMODE) Detects the location of the symbol and
%                                value of a card in the upper left corner.
%   CARD An image matrix of a single card with borders.
%   VALUE The value of the card.
%   SYMBOL A binary image of the symbol of the card.



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

if fastMode == true
    smoothedIm = imfilter(greyIm,fspecial('gaussian',9,0.5));
    %smoothedIm = imgaussfilt(greyIm, 'filtersize', 9);
    thld = graythresh(smoothedIm);
else
    smoothedIm = gauss(greyIm, 9, 0.5);
    thld = threshOtsu(smoothedIm);
end

binaryIm = false(size(smoothedIm));
binaryIm(smoothedIm > thld) = 1;


inv = ~binaryIm;
padded = padAndDelete(inv);
%filtPadded = medfilt2(padded);
filtPadded = padded;

bb = regionprops(filtPadded, 'BoundingBox');
minDiagonal = norm(size(filtPadded));
valueLabel = 0;
cardArea = numel(card);
isPictureCard = false;
for i = 1:length(bb)
    originDiagonal = norm([bb(i).BoundingBox(1) bb(i).BoundingBox(2)]);
    boxArea = bb(i).BoundingBox(3) * bb(i).BoundingBox(4);
    if boxArea < 0.1 * cardArea
        if originDiagonal < minDiagonal
            minDiagonal = originDiagonal;
            valueLabel = i;
        end      
    else 
        isPictureCard = true;
    end
end


% find the label (=symbol) right under the prev. found value label
% by finding the min distance between the lower left corner of the value's
% bounding box and the upper left corner of the remaining bboxes
box = bb(valueLabel).BoundingBox;
refPoint =  [box(1) (box(2)+box(4))];
minDistance = norm(size(filtPadded));
symbolLabel = 0;
for i = 1:length(bb)
    if i == valueLabel
        continue;
    end
    box = bb(i).BoundingBox;
    compPoint = [box(1) box(2)];
    distance = norm(refPoint - compPoint);
    if distance < minDistance
        minDistance = distance;
        symbolLabel = i;
    end        
end

valueBox = bb(valueLabel).BoundingBox;
symbolBox= bb(symbolLabel).BoundingBox;

symbolIm = imcrop(card, symbolBox);

%patternmatching

if isPictureCard
    % do pattern matching with the letter
    
    %use this Valueimage for patternmatching
    cropBox = bb(valueLabel).BoundingBox;
    cropBox(3) = bb(valueLabel).BoundingBox(4);
    cropBox = cropBox + [-3 -3 +6 +6];
    croppedValue = imcrop(smoothedIm,cropBox);
    value=detectSymbol(croppedValue, false);
    
    valueBox = cropBox;
    
    %croppedValue = imcrop(smoothedIm,bb(valueLabel).BoundingBox + [-3 -3 +6 +6]);
    %valueOcr = (ocr(croppedValue, 'TextLayout', 'Block'));
    %value = valueOcr.Text;
else
    % crop the center of the card for symbol counting
    % edges are cut out by taking the max x-value of the upper left value
    boundBox = bb(valueLabel).BoundingBox;
    cropX = boundBox(1) + boundBox(3);
    cropWidth = size(padded,2) - 2 * cropX;
    croppedCard = logical(imcrop(padded, [cropX, 1, cropWidth, size(padded, 1)]));

    [labels, numLabels] = bwlabel(croppedCard);
    areas = zeros(numLabels,1);

    for i = 1:numLabels
        areas(i) = sum(labels(:) == i);
    end

    % count all symbols that are at least 90% in size as the biggest symbol
    [maxArea, ~] = max(areas);
    limit = maxArea * 0.9;
    value = sum(areas(:) >= limit);
    if value == 1
        value = 'Ass';
    else
        value = num2str(value);
    end
end
    
symbol = detectSymbol(symbolIm, true);


end

