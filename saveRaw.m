% —охран€ет массив данных raw в .mat-файл, расположенный в path.
% ѕроизводитс€ разделение значений массива на действительные и мнимые
% значени€ с последующей записью в файл как переменных среды.
function saveRaw(raw, path, name)
    rawRe = int16(real(raw));
    rawIm = int16(imag(raw));

    save(strcat(path, name, '\', name,'.mat'), 'rawRe','rawIm', '-v6');
end