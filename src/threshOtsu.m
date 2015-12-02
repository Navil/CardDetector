function threshold = threshOtsu(grayIm)
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


%getPixels
[rows, columns, ~] = size(grayIm);
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




