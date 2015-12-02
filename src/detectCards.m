
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

cards = cell(1, 10);
areas = zeros(size(rp));

for i = 1:length(areas)
    a = rp(i).BoundingBox;
    areas(i) = a(3) * a(4);
end
clear a;
[sortedAreas, areaIdx] = sort(areas, 'descend');

annotIm = originalIm;
counter = 1;

cardBox = zeros(length(sortedAreas), 4);
valueBoxes = zeros(length(sortedAreas), 4);
symbolBoxes = zeros(length(sortedAreas), 4);
texts = cell(length(sortedAreas), 1);

for i = 1: length(sortedAreas)
   bb = rp(areaIdx(i)).BoundingBox;
    cards{1, counter} = imcrop(originalIm, bb);
    
   if (sortedAreas(i) <= sortedAreas(1) * 0.9);
       cards{1,counter} = [];
       break;
   else
       if debugMode
            [value, symbol, valueBox, symbolBox] = detectCardValue(cards{i}, fastMode);
            valueBoxes(counter,  1:4) = valueBox;
            symbolBoxes(counter, 1:4) = symbolBox;
       else
           [value, symbol]  = detectCardValue(cards{i}, fastMode);
       end
       text = strcat(symbol, ':', value);
       cardBox(counter, 1:4) = bb;
       texts{counter} = text;
        disp(text);
   end
   
   if showCards == true
        figure;
        imshow(cards{1,counter});
   end
    
    counter = counter + 1;
end
counter = counter - 1;

boxes = cardBox(1:counter, :);
texts = texts(1:counter);

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



figure;
imshow(annotIm);



