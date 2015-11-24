function [ symbol ] = detectSymbol( symbolIm, type)
%UNTITLED Summary of this function goes here
%   SYMBOLIM is a color image of the perfectly cropped out symbol of a
%                playing card.
%   SYMBOL   is a string describing the value, i.e., Herz, Karo, Pik, Kreuz
%

load('patterns.mat');

if ~isfloat(symbolIm)
    symbolIm = im2double(symbolIm);
end

gray=rgb2gray(symbolIm);
thresh=threshOtsu(gray);
binaryIm = false(size(gray));
binaryIm(gray > thresh) = 1;
binaryIm=imresize(binaryIm, [40 40]);

min=sum(sum(abs(binaryIm-patterns(1).value)));
mintext=patterns(1).name;

% if  (type == f.df.sdf.sgfljsdlkgkjösldf) etc.pp.
n=length(patterns);
for i=2:n
    new=sum(sum(abs(binaryIm-patterns(i).value)));
    
    if new<min
    min=new;
    mintext=patterns(i).name;
    end
    
end

symbol = mintext;

end

