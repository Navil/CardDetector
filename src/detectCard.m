
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
epsilon = 0.15;
binaryIm = false(size(smoothedIm));
binaryIm(smoothedIm > thld + epsilon) = 1;



%% Segmentation of the cards

% Detect cards by connected component labeling

components = bwconncomp(binaryIm);
labelSizes = cellfun(@numel, components.PixelIdxList);
[sortedLabSiz, srtedLabIdx] = sort(labelSizes, 'descend');
cards = cell([1 1]);
counter = 1;

rp = regionprops(binaryIm, 'BoundingBox');

% for i = srtedLabIdx
%     linIdx = components.PixelIdxList{i};
%     [yMin xMin] = ind2sub(size(originalIm), min(linIdx));
%     [yMax xMax] = ind2sub(size(originalIm), max(linIdx));
%     
%     if xMax < xMin;
%         tmp = xMin;
%         xMin = xMax;
%         xMax = tmp;
%     end
%     
%     if yMax < yMin;
%         tmp = yMin;
%         yMin = yMax;
%         yMax = tmp;
%         clear tmp;
%     end
%     
%     height = yMax -yMin;
%     width = xMax - xMin;
%     
%     cards{counter} = imcrop(originalIm, [xMin yMin width height]);
%     
%     if counter ~= 1;
%         if numel(cards{counter}) <= (numel(cards{1}) * 0.9);
%             cards{counter} = [];
%             break;
%         end
%     end
%     counter = counter + 1;
% end

why;
    




%% Value recognition of segmented card

singleCard = imread('Example_Input_Single.jpeg');
greySingle = rgb2gray(singleCard);
txt = ocr(greySingle);
txt


end