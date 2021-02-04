% ��������� ������ ������ raw � .mat-����, ������������� � path.
% ������������ ���������� �������� ������� �� �������������� � ������
% �������� � ����������� ������� � ���� ��� ���������� �����.
function saveRaw(raw, path, name)
    rawRe = int16(real(raw));
    rawIm = int16(imag(raw));

    save(strcat(path, name, '\', name,'.mat'), 'rawRe','rawIm', '-v6');
end