clear all
close all
clc

%------------------- Constants --------------------------------------------
% Тип поиска *.BIN-файлов.  Если finder = 1 - алгоритм будет рекурсивно
% искать все *.BIN-файлы в выбранной папке и её подпапках. Если finder = 0
% - будут использованы только те *.BIN-файлы, которые находятся в выбранной
% папке.
finder = 0;

% Если 0 - будет сохраняться изображение в режиме градации серого. Если 1 -
% в режиме цветовой карты jet. Если 2 - будут сохраняться оба изображения.
imgType = 1;

% Рабочая папка по-умолчанию
defaultPath = 'D:\MATLAB PRJ\testData';

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

% Выбираем папку с файлами данных
path = uigetdir(defaultPath, 'Select folder');

if(path == 0)
    disp('Нужно выбрать папку с файлами данных');
    return
else
    path = strcat(path, '\');
end

% В зависимости от значения finder ищем и записываем в dataFiles пути
% *.BIN-файлов либо рекурсивно в папке path и её подпапках, либо только в
% папке path.
dataFiles = {};
if(finder == 0)
    dirContent = dir(strcat(path, '*.BIN'));
    for i = 1 : numel(dirContent)
        dataFiles = [dataFiles strcat(dirContent(i).folder, '\', dirContent(i).name)];
    end
elseif(finder == 1)
    dataFiles = [dataFiles getBinFiles(path)];
end

% Выходим, если список пустой
if(size(dataFiles, 1) == 0)
    disp('В этой папке не обнаружены файлы данных');
    return
end

for i = 1 : numel(dataFiles)
    
    [filePath, fileName, fileExt] = fileparts(char(dataFiles(i)));
    filePath = strcat(filePath, '\');
    file = strcat(fileName, fileExt);
    
    % Если рабочая папка не существует - создаём её
    if((exist(strcat(filePath, fileName), 'dir')) ~= 7)
        mkdir(strcat(filePath, fileName));
    end
    
    % Инициализация переменной для хранения времени выполения preprocessScript
    preprocessTime = 0;
    
    % Если в рабочей папке нет *.mat-файла или файла header.txt
    if(exist(strcat(filePath, fileName, '\', fileName, '.mat'), 'file') ~= 2) || exist(strcat(filePath, fileName, '\', 'header.txt'), 'file') ~= 2
        % Засекаем время для preprocess
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
        
        % Засекаем время для postprocess
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
end
