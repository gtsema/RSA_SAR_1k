% Сохраняет строку header в файл header.txt, расположенный в path.
function saveHeader(header, path, name)
    fid = fopen(strcat(path, name,'/header.txt'),'w');
    fprintf(fid, header);
    fclose(fid);
end