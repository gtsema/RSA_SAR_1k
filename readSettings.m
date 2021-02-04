function [fs, f0, B, T, RDF, PRF, n] = readSettings(path)

fid = fopen(path);
tline = fgetl(fid);
count = 1;

fs = 1100e6;

while ischar(tline)
    tline = fgetl(fid);
    switch count
        case 1
            T = 1e-6 * str2double(cell2mat(regexp(tline, '\d+', 'match'))); %duration
        case 2
            PRF = 1e6 / str2double(cell2mat(regexp(tline, '\d+', 'match'))); %period
        case 4
            f0 = 1e6 * str2double(cell2mat(regexp(tline, '\d+', 'match'))); %frequency
        case 5
            B = 1e6 * str2double(cell2mat(regexp(tline, '\d+', 'match'))); %deviation
        case 12
            n1 = str2double(cell2mat(regexp(tline, '\d+', 'match'))); %base
        case 14
            n = n1 + str2double(cell2mat(regexp(tline, '\d+', 'match'))); %stop
    end
    count = count + 1;
end

fclose(fid);

RDF = floor(fs / B);
end

