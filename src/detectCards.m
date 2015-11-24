
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
%   opt. FASTMODE           if set to true, built in MATLAB functions
%                           are used to increase performance speed
%
%   opt. SHOWCARDS          creates a new figure and shows each segmented
%                           card.
%
%
% see also: DETECTCARDVALUE, DETECTSYMBOL.

% Authors: Christopher Dick (0946375), Timon Höbert(1427936)
clc


%% Preprocessing

% check arguments
% TODO: Fehlerbehandlung falls input 2 und 3 keine boolean
narginchk(1, 3);
l=length(varargin);
fastMode=false;
showCards=false;
if l>0
    fastMode = cell2mat(varargin(1));
    if l>1
    showCards = cell2mat(varargin(2));
    end
end

switch nargin
    case 1
    case 2
        if strcmp(varargin{1}, 'fastMode') 
            fastMode = true;
        elseif strcmp(varargin{1}, 'showCards')
            showCards = true;
        end
    case 3
        if max(strcmp('fastMode', varargin))
            fastMode = true;
            if max(strcmp('showCards', varargin))
                showCards = true;
            else 
                error('Invalid optional parameters.')
            end
        else
            error('Invalid optional parameters.')
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
    [labeledIm, numLabels] = bwlabel(binaryIm);
else
    [labeledIm, numLabels] = ccl(binaryIm);
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
       [value, symbol, valueBox, symbolBox] = detectCardValue(cards{i}, fastMode);
       text = strcat(symbol, ':', value);
       cardBox(counter, 1:4) = bb;
       valueBoxes(counter,  1:4) = valueBox;
       symbolBoxes(counter, 1:4) = symbolBox;
       texts{counter} = text;
        disp(text);
   end
   
   if showCards == true
        figure;
        imshow(cards{1,counter});
   end
    
    counter = counter + 1;
end

cardBox = cardBox(1:counter, :);
valueBoxes = valueBoxes(1:counter, :);
valueBoxes(: , 1:2) = valueBoxes(: , 1:2) + cardBox(: , 1:2);
symbolBoxes = symbolBoxes(1:counter, :);
symbolBoxes(: , 1:2) = symbolBoxes(: , 1:2) + cardBox(: , 1:2);
texts = texts{1:counter, :};
annotIm = insertObjectAnnotation(annotIm, 'rectangle', ...
                                        cardBox, texts, ...
                                        'TextBoxOpacity', 0.8, ...
                                        'FontSize', 52);
                                    

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

figure;
imshow(annotIm);



