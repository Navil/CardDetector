
function threshOtsu(filename)
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

% apply Otsu to the grayscale image
threshold = otsu(smoothedIm);
binaryIm = true(size(smoothedIm)); 
binaryIm(smoothedIm < threshold) = 0; 
imshow(binaryIm);


end

% Otsu's method is used to seperate backgound and foreground.
% We want to find a threshold, where the means of the foreground and
% background differ the most. Thus we want to maximize the variance between
% the classes and minimize the variance within the classes.
%
% Parameter: a grayscale image
% Returnvalue: the threshold
%
% inspired by: 
% https://en.wikipedia.org/wiki/Otsu%27s_method
% http://www.labbookpages.co.uk/software/imgProc/otsuThreshold.html
% [Bur13] Principles of Digital Image Processing, Advanced Methods
%
% Author: Thomas Anderl
function threshold = otsu(grayIm)

%getPixels
[rows columns colors] = size(grayIm);
numPixels = rows*columns;

%getHistogram
[histoValues] = imhist(grayIm);

sumB = 0; %represents the current sum of the brightness in the background
pixB = 0; %represents the sum of the pixels in the current background
maxVariance = 0.0; %variance between the background and foreground
%maximum between the classes has the same result as minimum within classes

sumBrightness = sum((0:255).*histoValues.'); % sum of the brightness
for brightnessItt=1:256
    pixB = pixB + histoValues(brightnessItt); %num of pixels in background
    if (pixB == 0)
        continue;
    end
    pixF = numPixels - pixB; %num of pixels in foreground
    if (pixF == 0)
        break;
    end
    sumB = sumB +  (brightnessItt-1) * histoValues(brightnessItt);
    meanB = sumB / pixB; %mean brightness of the background
    meanF = (sumBrightness - sumB) / pixF; %mean brightness of the foreground
    
    diffMeanBrightness = meanB-meanF;
    variance = pixB * pixF * (diffMeanBrightness*diffMeanBrightness); %variance
    if ( variance > maxVariance )
        threshold = brightnessItt / 256; %saves the grayValue for the threshold
        maxVariance = variance; %saves the current variance as the new maximum
    end
end
end




