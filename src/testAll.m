
function testAll(path)

filelist=dir(path);
filelist=filelist(~[filelist.isdir]);
filelist = filelist(arrayfun(@(x) x.name(1), filelist) ~= '.');
filelist = arrayfun(@(x) strcat(path,'/',x.name),filelist,'UniformOutput',0);

l = length(filelist);

for n=1:l
    path=filelist(n);
    path=path{1};
    detectCards(path,'fastMode');
end

end