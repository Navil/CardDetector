
filelist=dir('Datensatz');
filelist=filelist(~[filelist.isdir]);
filelist = filelist(arrayfun(@(x) x.name(1), filelist) ~= '.');
filelist = arrayfun(@(x) strcat('Datensatz/',x.name),filelist,'UniformOutput',0);

l = length(filelist);

for n=1:l
    path=filelist(n);
    path=path{1};
    detectCards(path,'fastMode');
end