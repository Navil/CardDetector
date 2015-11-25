function [ symbol ] = detectSymbol( inputIm, symBool)
%UNTITLED Summary of this function goes here
%   SYMBOLIM is a color image of the perfectly cropped out symbol of a
%                playing card.
%   SYMBOL   is a string describing the value, i.e., Herz, Karo, Pik, Kreuz
%   
%   symBool  a boolean indicating of symbol of letter should be matched. If
%            true inputIm is considered a symbol
%

load('patterns.mat');

if  (symBool) 
    patterns=symbols;
else 
    patterns=letters;
end

if ~isfloat(inputIm)
    inputIm = im2double(inputIm);
end

if ndims(inputIm) > 2;
    greyIm = rgb2gray(inputIm);
else
    greyIm = inputIm;
end
thresh=threshOtsu(greyIm);
binaryIm = false(size(greyIm));
binaryIm(greyIm > thresh) = 1;

if ~symBool
[labels,numlabel]=ccl(~binaryIm);

max=0;

for i=1:numlabel-1
    
    if sum(labels(labels==i))>max
    x=i;
    max=sum(labels(labels==i));
    end

end

labels(labels~=x)=0;
labels(labels==x)=1;

bb = regionprops(labels, 'BoundingBox');
binaryIm=imcrop(labels,bb(1).BoundingBox);
end

binaryIm=imresize(binaryIm, [40 40]);

if symBool
    dif=abs(binaryIm-patterns(1).value);
else
    dif=xor(binaryIm,patterns(1).value);
end
min=sum(sum(dif));
mintext=patterns(1).name;

n=length(patterns);
for i=2:n
    
    if symBool
        dif=abs(binaryIm-patterns(i).value);
    else
        dif=xor(binaryIm,patterns(i).value);
    end
    
    new=sum(sum(dif));
    
    if new<min
    min=new;
    mintext=patterns(i).name;
    end
    
end

symbol = mintext;

end

