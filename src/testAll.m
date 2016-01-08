    
function testAll(path)
% TESTALL	Tests all files in the specified path

% This block checks the directory and saves all files in a list
filelist=dir(path);
filelist=filelist(~[filelist.isdir]);
filelist = filelist(arrayfun(@(x) x.name(1), filelist) ~= '.');
filelist = arrayfun(@(x) strcat(path,'/',x.name),filelist,'UniformOutput',0);

l = length(filelist);

% Iterating through all the files within that directory and calling the main function on them
for n=1:l
    path=filelist(n);
    path=path{1};
    detectCards(path,'fastMode');
end

end