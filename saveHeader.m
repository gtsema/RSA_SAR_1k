% ��������� ������ header � ���� header.txt, ������������� � path.
function saveHeader(header, path, name)
    fid = fopen(strcat(path, name,'/header.txt'),'w');
    fprintf(fid, header);
    fclose(fid);
end