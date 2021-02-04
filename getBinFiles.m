function [binFiles] = getBinFiles(path)
    binFiles = {};
    dirContent = dir(path);
    
    for i = 1 : numel(dirContent)
        if(dirContent(i).isdir == 0 && isBinFile(dirContent(i).name))
            binFiles = [binFiles strcat(dirContent(i).folder, '\', dirContent(i).name)];
        elseif(dirContent(i).isdir == 1 && ~strcmp(dirContent(i).name, '.') && ~strcmp(dirContent(i).name, '..'))
            binFiles = [binFiles getBinFiles(strcat(dirContent(i).folder, '\', dirContent(i).name))];
        end
    end
end

function isBin = isBinFile(fname)
    [~, ~, ext] = fileparts(fname);
    isBin = strcmp(ext,'.BIN');
end