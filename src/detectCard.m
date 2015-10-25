
function detectCard(filename)
% DETECTCARD Detects playing cards in an image and prints their values.
%   DETECTCARD(FILENAME)    reads the image specified by FILENAME
%                           in either .png, .tiff or .jpeg format
%                           as an input and prints the card values as
%                           textual output to the console.

% Authors: Christopher Dick (0946375), Timon Höbert()
clc


%% Preprocessing

% Read in the image file and convert to grey scale
if ~exist(filename, 'file');
    sprinf(['The specified file does not exist within MATLAB environment.\n'...
        'Please check your input again.'])
    return
end

%  check image if already in double type, if not: convert
original = imread(filename);
if ~isfloat(original)
    original = im2double(original);
end

% check if read is intensity image, convert if not
if ndims(original) > 2;
    greyIm = rgb2gray(original);
else
    greyIm = original;
end

%{
 Create a binary image by thresholding against white (card background)
thld = max(max(greyIm));    % find strongest white in picture
epsilon = 0.15;             % range to define the threshold
binaryIm = false(size(greyIm));
binaryIm(greyIm > thld - epsilon) = 1;
%}

% Create a binary image by threholding with Otsu against background
thld = graythresh(greyIm);
epsilon = 0.15;
binaryIm = false(size(greyIm));
binaryIm(greyIm > thld + epsilon) = 1;


% fill holes in cards caused by patterns
% SE = strel('square', 10);
% closedIm = imclose(binaryIm, SE);
closedIm = bwmorph(binaryIm, 'thicken', 10);


%% Segmentation of the cards

% Detect cards by connected component labeling

labels = bwlabel(closedIm);
amounts = histcounts(categorical(labels));



%% Value recognition of segmented card

singleCard = imread('Example_Input_Single.jpeg');
greySingle = rgb2gray(singleCard);
txt = ocr(greySingle);
txt


end