function keepFiles(PATHNAME, filetype)


d = dir([PATHNAME '\*.*']);

for fi = 1:length(d)
    [filepath, name, ext] = fileparts(d(fi).name);
    if(~d(fi).isdir && ~strcmp(ext,{filetype}))
        delete(fullfile(PATHNAME, d(fi).name));
    end
end
 