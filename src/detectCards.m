
function [cards, annotIm] = detectCards(filename, varargin)
% DETECTCARDS Detects playing cards in an image,
%               annotates them with their rank and value,
%               and stores the segmented images in a cell array.
%   CARDS = DETECTCARDS(FILENAME)    reads the image specified by FILENAME
%                           in either .png, .tiff or .jpeg format
%                           as an input and prints the card values as
%                           textual output to the console.
%
%   [CARDS, ANNOTIM] = DETECTCARDS(FILENAME)    additionally stores the
%                           annotated image.
%
%   FILENAME                the name of the image file from which the cards
%                           are to be detected as a string.
%
%   opt. FASTMODE           add 'fastMode' as argument to use built in
%                           MATLAB functions to increase performance speed
%
%   opt. SHOWCARDS          add 'showCards' as argument to create a new
%                           figure and show each segmented card.
%
%   opt. DEBUGMODE          add 'debugMode' as argument to show the
%                           bounding boxes of the detected symbol and value
%                           in the annotated image.
%
%
% see also: DETECTCARDVALUE, DETECTSYMBOL.

% Authors: Christopher Dick (0946375), Timon Höbert(1427936)



%% Preprocessing

% check arguments

narginchk(1, 4);

fastMode = false;
showCards = false;
debugMode = false;

for i = 1:(nargin-1)
    if strcmp(varargin{i}, 'fastMode')
             fastMode = true;
    elseif strcmp(varargin{i}, 'showCards')
             showCards = true;
    elseif strcmp(varargin{i}, 'debugMode')
             debugMode = true;
    end
end
            

% Read in the image file and convert to grey scale
if ~exist(filename, 'file');
    error(['The specified file "%s" does not exist ' ...
            'within the MATLAB environment. \n' ...
        'Please check your input again.'], filename)
end

%  check image if already in double type, if not: convert 
originalIm = imread(filename);
if ~isfloat(originalIm)
    originalIm = im2double(originalIm);
end

% check if read is intensity image, convert if not
if ndims(originalIm) > 2;
    greyIm = rgb2gray(originalIm);
else
    greyIm = originalIm;
end

% smooth the image with a gaussian filter to remove noise
% Create a binary image by threholding with Otsu against background

if fastMode == true
    % built in MATLAB-Function for deubgging
    
    smoothedIm = imfilter(greyIm,fspecial('gaussian',9,0.5));
    %smoothedIm = imgaussfilt(greyIm, 'filtersize', 9);
    thld = graythresh(smoothedIm);
else 
    smoothedIm = gauss(greyIm, 9, 0.5);
    thld = threshOtsu(smoothedIm);
end

%{
 Create a binary image by thresholding against white (card background)
thld = max(max(greyIm));    % find strongest white in picture
epsilon = 0.15;             % range to define the threshold
binaryIm = false(size(greyIm));
binaryIm(greyIm > thld - epsilon) = 1;
%}

binaryIm = false(size(smoothedIm));
binaryIm(smoothedIm > thld) = 1;



%% Segmentation of the cards

% Detect cards by connected component labeling

if fastMode == true
    [labeledIm, ~] = bwlabel(binaryIm);
else
    [labeledIm, ~] = ccl(binaryIm);
end

rp = regionprops(labeledIm, 'BoundingBox');
aspectWidth = 62;
aspectHeight = 88;

% preallocate the cell array for the cards,
% we do not expect more than 10 cards
cards = cell(1, 10);
areas = zeros(size(rp));

% calculate the area of the bbox for each label
for i = 1:length(areas)
    a = rp(i).BoundingBox;
    areas(i) = a(3) * a(4);
end
clear a;
% sort labels by area, biggest, i.e., cards are first
[sortedAreas, areaIdx] = sort(areas, 'descend');

annotIm = originalIm;
counter = 1; % the number of cards detected and segmentated

% the bboxes for the later segmentation and annotation
cardBox = zeros(length(sortedAreas), 4);
valueBoxes = zeros(length(sortedAreas), 4);
symbolBoxes = zeros(length(sortedAreas), 4);
texts = cell(length(sortedAreas), 1);

% iterate over all areas and crop only the biggest labels,
% with the first (biggest) as a reference value for the area
for i = 1: length(sortedAreas)
   bb = rp(areaIdx(i)).BoundingBox;
    cards{1, counter} = imcrop(originalIm, bb);
    
    % stop if label smaller than 90% of the first recognized
   if (sortedAreas(i) <= sortedAreas(1) * 0.9);
       cards{1,counter} = [];
       break;
   else
       % check if card is rotated and correct if necessary
%        ratio = linearMap(bb(3)/bb(4), aspectWidth/aspectHeight, aspectHeight/aspectWidth, 0, 90);
%        if ratio > 3
%             cards{1, counter} = imrotate(cards{1, counter}, ratio);
%        end
       if bb(3) > bb(4)
           cards{1, counter} = imrotate(cards{1, counter}, -90);
       end
       % get the value, symbol and their bboxes for the cropped card
       if debugMode
            [value, symbol, valueBox, symbolBox] = detectCardValue(cards{i}, fastMode);
            valueBoxes(counter,  1:4) = valueBox;
            symbolBoxes(counter, 1:4) = symbolBox;
       else
           [value, symbol]  = detectCardValue(cards{i}, fastMode);
       end
       % create the text that is shown in the annotated image
       text = strcat(symbol, ':', value);
       cardBox(counter, 1:4) = bb;
       texts{counter} = text;
       % show the found card values and symbols on the command window
       disp(text);
   end
   
   % show the segmentated cards if specified
   if showCards == true
        figure;
        imshow(cards{1,counter});
   end
    
    counter = counter + 1;
end
counter = counter - 1;

boxes = cardBox(1:counter, :);
texts = texts(1:counter);


%% Annotation of the original image
if debugMode
    valueBoxes = valueBoxes(1:counter, :);
    valueBoxes(: , 1:2) = valueBoxes(: , 1:2) + boxes(: , 1:2);
    symbolBoxes = symbolBoxes(1:counter, :);
    symbolBoxes(: , 1:2) = symbolBoxes(: , 1:2) + boxes(: , 1:2);
    
    annotIm = (insertObjectAnnotation(annotIm, 'rectangle', ...
                                        valueBoxes, ...
                                        'Valuebox', ...
                                        'TextBoxOpacity', 0.8, ...
                                        'FontSize', 10, 'Color', 'red'));
    annotIm = insertObjectAnnotation(annotIm, 'rectangle', ...
                                        symbolBoxes, ...
                                        'Symbolbox', ...
                                        'TextBoxOpacity', 0.8, ...
                                        'FontSize', 10, 'Color', 'green');
end
    annotIm = insertObjectAnnotation(annotIm, 'rectangle', ...
                                        boxes, texts, ...
                                        'TextBoxOpacity', 0.8, ...
                                        'FontSize', 52);                                 


% show the complete annotated image
figure;
imshow(annotIm);



