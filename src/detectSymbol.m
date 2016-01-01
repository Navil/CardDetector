function [ symbol ] = detectSymbol( inputIm, symBool)
%DETECTSYMBOLS Detects the symbol contained in the image
%   INPUTIM is a color image of the perfectly cropped out symbol of a
%                playing card.
%   
%   SYMBOOL  a boolean indicating if symbol or letter should be matched. If
%            true inputIm is considered a symbol
%

% Loads the patterns, containing a key-value pair consisting of the name and the symbol
load('patterns.mat');

% Checks the flag, if it is true, the image is a symbol, otherwise it is a letter
if  (symBool) 
    patterns=symbols;
else 
    patterns=letters;
end

% Casting to double
if ~isfloat(inputIm)
    inputIm = im2double(inputIm);
end

% Casting to grayimage
if ndims(inputIm) > 2;
    greyIm = rgb2gray(inputIm);
else
    greyIm = inputIm;
end

% Applying otsu
thresh=threshOtsu(greyIm);
binaryIm = false(size(greyIm));
binaryIm(greyIm > thresh) = 1;

% If it is a letter, we use ccl to find the area
if ~symBool
	[labels,numlabel]=ccl(~binaryIm);

	max=0;
	% Iterate through all the labels in the image and find the largest, save the value
	for i=1:numlabel-1
		if sum(labels(labels==i))>max
			x=i;
			max=sum(labels(labels==i));
		end

	end

	% The largest component is now white, the remaining image is black
	labels(labels~=x)=0;
	labels(labels==x)=1;

	% Isolate the letter
	bb = regionprops(labels, 'BoundingBox');
	binaryIm=imcrop(labels,bb(1).BoundingBox);
end

% Rescale the image for fixed comparison
binaryIm=imresize(binaryIm, [40 40]);

% Detect where the pattern and the icon differ the least and return it
if symBool
    dif=abs(binaryIm-~patterns(1).value);
else
    dif=xor(binaryIm,patterns(1).value);
end
min=sum(sum(dif));
mintext=patterns(1).name;

n=length(patterns);
for i=2:n
    
    if symBool
        dif=abs(binaryIm-~patterns(i).value);
    else
        dif=xor(binaryIm,patterns(i).value);
    end
    
    new=sum(sum(dif));
    
	% When the current pattern matches better than the one before, remember it
    if new<min
		min=new;
		mintext=patterns(i).name;
    end
    
end

symbol = mintext;

end

