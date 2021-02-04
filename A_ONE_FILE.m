clear all
close all
clc

%------------------- Constants --------------------------------------------
% ������� ����� ��-���������
defaultPath = 'D:\RSA\DATA\testData\1k';

% ���� 0 - ����� ����������� ����������� � ������ �������� ������. ���� 1 -
% � ������ �������� ����� jet. ���� 2 - ����� ����������� ��� �����������.
imgType = 2;

% ������ ������
h = 300;

% ������� �������� �� (�/�)
speed = [34];

% ������ �� �� �������: ���� �� ��
% ������� ����� �����
% ���������, �� ����� ������ ������
beam = 14;

% ��� X-���������
f_geter = 8160e6;

% ��� L-���������
% f_geter = 0;
%--------------------------------------------------------------------------

% �������� ���� ������
[file, filePath] = uigetfile('*.BIN', 'Select data file', defaultPath);

% ���� ���� �� ������ - �������
if(file == 0)
    disp('����� ������� ���� ������');
    return
end

% ���� ��� ��� ��� ����������
[~, fileName, ~] = fileparts(file);

% ���� ������� ����� �� ���������� - ������ �
if(exist(strcat(filePath, fileName), 'dir') ~= 7)
    mkdir(strcat(filePath, fileName));
end

% ������������� ���������� ��� �������� ������� ��������� preprocessScript
preprocessTime = 0;

% ���� � ������� ����� ��� *.mat-����� ��� ����� header.txt
if(exist(strcat(filePath, fileName, '\', fileName, '.mat'), 'file') ~= 2) || exist(strcat(filePath, fileName, '\', 'header.txt'), 'file') ~= 2
    %�������� ����� ����������
    tic
    
    % ����������� .BIN ����� ������ � ������ ������ raw �
    % ������ header, ���������� ���������� �� ������ .BIN-�����.
    [header, raw] = preprocessScript(filePath, file);
    
    % ��������� header
    saveHeader(header, filePath, fileName);
    
    % ��������� ����� ������ raw � .mat-����
    saveRaw(raw, filePath, fileName);

    preprocessTime = toc;
        
    fprintf('%s preprocess - %u min, %u sec.\n', file, fix(preprocessTime / 60), fix(mod(preprocessTime, 60)));
    disp('------------------------------------------------------------------');
end

totalPostTime = 0;

for V = speed
    % ���� ����������� � ����� ��������� ���� - ����������
    if(exist(strcat(filePath, fileName, '\', fileName, '_v', num2str(V), '_', 'gray.png'), 'file') == 2 || exist(strcat(filePath, fileName, '\', fileName, '_v', num2str(V), '_', 'jet.png'), 'file') == 2)
        continue
    end
    
    %�������� ����� ����������
    tic
    
    % ��������� ������.
    [img,img_name] = processScript(strcat(filePath, fileName, '\', fileName, '.mat'), h, V, beam, f_geter);

    % ��������� �����������
    saveImg(img, strcat(filePath, fileName, '\'), img_name, imgType);
    
    % ��������� � ������ �������
    totalPostTime = totalPostTime + toc;
    
    fprintf('%s (speed = %u) process and postprocess - %u min, %u sec.\n', file, V, fix(toc / 60), fix(mod(toc, 60)));
end

disp('------------------------------------------------------------------');
fprintf('Total process and postprocess: %u min, %u sec.\n', fix(totalPostTime / 60), fix(mod(totalPostTime, 60)));
fprintf('Total: %u min, %u sec.\n', fix((preprocessTime + totalPostTime) / 60), fix(mod(preprocessTime + totalPostTime, 60)));
disp('__________________________________________________________________');
