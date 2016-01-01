%author: Julian Lemmel
%
% Script to create a Structure with two fields containing
% binary Patterns for all the files that are located in the "Patterns"
% Folder along with their names.
%
% There must only be files that can be opened by imread located in the
% "Patterns" Folder!
%

function makePatterns()
% MAKEPATTERNS loads the files inside the directory and calls the make function,
% which prepares the icons for the matching
filelist=dir('Patterns/Symbole');
filelist=filelist(~[filelist.isdir]);
filelist = filelist(arrayfun(@(x) x.name(1), filelist) ~= '.');
filelist = arrayfun(@(x) strcat('Patterns/Symbole/',x.name),filelist,'UniformOutput',0);

symbols=make(filelist);

filelist=dir('Patterns/Bilder');
filelist=filelist(~[filelist.isdir]);
filelist = filelist(arrayfun(@(x) x.name(1), filelist) ~= '.');
filelist = arrayfun(@(x) strcat('Patterns/Bilder/',x.name),filelist,'UniformOutput',0);

letters=make(filelist);

save('patterns.mat','symbols','letters')

end

function patterns=make(filelist)
patterns=struct();

n = length(filelist);
% for every file inside the directory return the patterns
for i=1:n
    path=filelist(i);
    path=path{1};
	
    symbolIm=imread(path); % a single symbol
    if ~isfloat(symbolIm)
		symbolIm = im2double(symbolIm); % cast to double
    end
	% preprocessing - applying grayscale with otsu
    gray=rgb2gray(symbolIm);
    thresh=threshOtsu(gray);
    binaryIm = false(size(gray));
    binaryIm(gray > thresh) = 1;
	
	%scale the image, to use it for fixed size comparison
    binaryIm=imresize(binaryIm,[40 40]);
	
	%save the image with the name as a key-value pair
    [~,fname,~]=fileparts(path);
    patterns(i).name=fname;
    patterns(i).value=~binaryIm;
end

end

