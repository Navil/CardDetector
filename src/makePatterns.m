%author: Julian Lemmel
%
% Script to create a Structure with two fields containing
% binary Patterns for all the files that are located in the "Patterns"
% Folder along with their names.
%
% There must only be files that can be opened by imread located int he
% "Patterns" Folder!
%


filelist=dir('Patterns');
filelist=filelist(~[filelist.isdir]);
filelist = filelist(arrayfun(@(x) x.name(1), filelist) ~= '.');

patterns=struct();

n = length(filelist);
for i=1:n
    path=strcat('Patterns/',filelist(i).name);
    symbolIm=imread(path);
    if ~isfloat(symbolIm)
    symbolIm = im2double(symbolIm);
    end
    gray=rgb2gray(symbolIm);
    thresh=threshOtsu(gray);
    binaryIm = false(size(gray));
    binaryIm(gray > thresh) = 1;
    binaryIm=imresize(binaryIm,[40 40]);
    [~,fname,~]=fileparts(path);
    patterns(i).name=fname;
    patterns(i).value=binaryIm;
end


save('patterns.mat','patterns')

