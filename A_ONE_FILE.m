clear all
close all
clc

%------------------- Constants --------------------------------------------
% Рабочая папка по-умолчанию
defaultPath = 'D:\RSA\DATA\testData\1k';

% Если 0 - будет сохраняться изображение в режиме градации серого. Если 1 -
% в режиме цветовой карты jet. Если 2 - будут сохраняться оба изображения.
imgType = 2;

% Высота полета
h = 300;

% средняя скорость ЛА (м/с)
speed = [34];

% ширина ДН по азимуту: если ЛА на
% участке полёта летел
% стабильно, то лучше делать больше
beam = 14;

% для X-диапазона
f_geter = 8160e6;

% для L-диапазона
% f_geter = 0;
%--------------------------------------------------------------------------

% Выбираем файл данных
[file, filePath] = uigetfile('*.BIN', 'Select data file', defaultPath);

% Если файл не выбран - выходим
if(file == 0)
    disp('Нужно выбрать файл данных');
    return
end

% Берём его имя без расширения
[~, fileName, ~] = fileparts(file);

% Если рабочая папка не существует - создаём её
if(exist(strcat(filePath, fileName), 'dir') ~= 7)
    mkdir(strcat(filePath, fileName));
end

% Инициализация переменной для хранения времени выполения preprocessScript
preprocessTime = 0;

% Если в рабочей папке нет *.mat-файла или файла header.txt
if(exist(strcat(filePath, fileName, '\', fileName, '.mat'), 'file') ~= 2) || exist(strcat(filePath, fileName, '\', 'header.txt'), 'file') ~= 2
    %Засекаем время выполнения
    tic
    
    % Конвертация .BIN файла данных в массив данных raw и
    % строку header, содержащую информацию из хидера .BIN-файла.
    [header, raw] = preprocessScript(filePath, file);
    
    % Сохраняем header
    saveHeader(header, filePath, fileName);
    
    % Сохраняем масив данных raw в .mat-файл
    saveRaw(raw, filePath, fileName);

    preprocessTime = toc;
        
    fprintf('%s preprocess - %u min, %u sec.\n', file, fix(preprocessTime / 60), fix(mod(preprocessTime, 60)));
    disp('------------------------------------------------------------------');
end

totalPostTime = 0;

for V = speed
    % Если изображение с такой скоростью есть - пропускаем
    if(exist(strcat(filePath, fileName, '\', fileName, '_v', num2str(V), '_', 'gray.png'), 'file') == 2 || exist(strcat(filePath, fileName, '\', fileName, '_v', num2str(V), '_', 'jet.png'), 'file') == 2)
        continue
    end
    
    %Засекаем время выполнения
    tic
    
    % Обработка данных.
    [img,img_name] = processScript(strcat(filePath, fileName, '\', fileName, '.mat'), h, V, beam, f_geter);

    % Сохраняем изображение
    saveImg(img, strcat(filePath, fileName, '\'), img_name, imgType);
    
    % Добавляем к общему времени
    totalPostTime = totalPostTime + toc;
    
    fprintf('%s (speed = %u) process and postprocess - %u min, %u sec.\n', file, V, fix(toc / 60), fix(mod(toc, 60)));
end

disp('------------------------------------------------------------------');
fprintf('Total process and postprocess: %u min, %u sec.\n', fix(totalPostTime / 60), fix(mod(totalPostTime, 60)));
fprintf('Total: %u min, %u sec.\n', fix((preprocessTime + totalPostTime) / 60), fix(mod(preprocessTime + totalPostTime, 60)));
disp('__________________________________________________________________');
