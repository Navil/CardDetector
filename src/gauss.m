function [ smoothedIm ] = gauss( inputIm, filtersize, sigma )
%GAUSS smoothes the input image.
%   GAUSS(FILENAME, FILTERSIZE, SIGMA)  smoothes the input image using a 
%                                       gaussian filter with a FILTERSIZE
%                                       for both rows and columns and a
%                                       specified SIGMA.
%                                       FILTERSIZE must be a positive,
%                                       odd number. 
%                                       SIGMA must be a positive number.

%Make filtersize uneven, if needed
if mod(filtersize,2) == 0 
    filtersize = filtersize+1;
end

%Calculate position of middle
kernel = zeros(filtersize);
middle = (filtersize+1)/2;

%Creating the filter kernel
for x = 1:filtersize
    for y = 1:filtersize
        kernel(x,y) = exp(-((x-middle)^2 + (y-middle)^2)/(2*sigma^2));
    end
end

%sum of elements in kernel should be 1
kernSum = sum(kernel(:));
kernel(:) = kernel(:)./kernSum;

%Create a resizedIm, which is the inputIm with replicated border, to avoid
%edge problems.
[rows, columns, channels] = size(inputIm);
borderSize = middle-1;
resizedIm = padarray(inputIm, [borderSize borderSize], 'replicate');

result = zeros(size(inputIm));


%Iterate over all pixels and convolute them with the kernel. Store the sum
%of convolution in result
for c = 1:channels
    for x = (borderSize+1):(rows+borderSize)
        for y = (borderSize+1):(columns+borderSize)
            extractedArea = resizedIm((x-borderSize):(x+borderSize), (y-borderSize):(y+borderSize), c);
            convolution = kernel .* extractedArea;
            result((x-borderSize),(y-borderSize), c) = sum(convolution(:));
        end
    end
end

smoothedIm = result;

end

