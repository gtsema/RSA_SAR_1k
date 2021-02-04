function [img,img_name] = processScript(rawDataFile, h, V, beam, f_geter)

[path, ~, ~] = fileparts(rawDataFile);

headerFile = strcat(path, '\', 'header.txt');

c = 299792458;
az_begin = 0; % начало обработки вдоль линии полёта (нормированное от 0 до 1)
az_end = 1; % конец обработки вдоль линии полёта (нормированное от 0 до 1)

gain = -1;
shades = 256;
resol = 0.25;
cut_near = 0;
cut_far = 0;

db_cut_level_hi = 0; %  верхний предел контрастности (белый цвет)
db_cut_level_lo = -20; %  нижний предел контрастности (черный цвет)

[img,img_name] = doImg_rd_simple(gain, shades, resol, cut_near, cut_far, db_cut_level_hi, db_cut_level_lo, c, f_geter, az_begin, az_end, V, h, beam, rawDataFile, headerFile);
end