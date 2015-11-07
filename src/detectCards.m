
function [cards] = detectCards(filename)
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

smoothedIm = imgaussfilt(greyIm, 'filtersize', 9);

%{
 Create a binary image by thresholding against white (card background)
thld = max(max(greyIm));    % find strongest white in picture
epsilon = 0.15;             % range to define the threshold
binaryIm = false(size(greyIm));
binaryIm(greyIm > thld - epsilon) = 1;
%}

% Create a binary image by threholding with Otsu against background
thld = graythresh(smoothedIm);
binaryIm = false(size(smoothedIm));
binaryIm(smoothedIm > thld) = 1;



%% Segmentation of the cards

% Detect cards by connected component labeling

[labeledIm, numLabels] = bwlabel(binaryIm);

rp = regionprops(labeledIm, 'BoundingBox');

cards = cell(1, 10);
areas = zeros(size(rp));

for i = 1:length(areas)
    a = rp(i).BoundingBox;
    areas(i) = a(3) * a(4);
end
clear a;
[sortedAreas, areaIdx] = sort(areas, 'descend');

counter = 1;
for i = 1: length(sortedAreas)
   
    cards{1, counter} = imcrop(originalIm, rp(areaIdx(i)).BoundingBox);
    
   if (sortedAreas(i) <= sortedAreas(1) * 0.9);
       cards{1,counter} = [];
       break;
   end
    figure;
    imshow(cards{1,counter});
    counter = counter + 1;
end



