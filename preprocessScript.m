function [str_header, raw] = preprocessScript(path, file)

fid = fopen(strcat(path, file));
headerLen = 1024;
cycleHeaderLen = 128;
header = fread(fid,[1 headerLen],'ubit8=>char');
str_header = string(header);
tline = strsplit(str_header,'\n');

chirpT = 1e-6 * str2double(cell2mat(regexp(tline(2), '\d+', 'match'))); 
f0 = 1e6 * str2double(cell2mat(regexp(tline(5), '\d+', 'match')));
chirpBandwidth = 1e6 * str2double(cell2mat(regexp(tline(6), '\d+', 'match')));
n1 = str2double(cell2mat(regexp(tline(13), '\d+', 'match')));
samples = n1 + str2double(cell2mat(regexp(tline(15), '\d+', 'match')));

fs = 1100e6;
rangeDecimationFactor = floor(fs / chirpBandwidth);
chirpSamples = chirpT * fs;
t = - chirpSamples / fs / 2 : 1 / fs : samples / fs - chirpSamples / fs / 2 - 1 / fs;
sarShift = exp(- 2i * pi * ((f0-fs) + chirpBandwidth / 2) .* t);


cycleDataLen = floor(samples / 2) * 3;
cycleLen = ceil((cycleHeaderLen + cycleDataLen) / 512) * 512;
idx = cycleLen - cycleDataLen;

fseek(fid,0,'eof');
nCycles = fix((ftell(fid) - headerLen) / cycleLen); 
fseek(fid,headerLen + cycleHeaderLen,'bof');

raw = zeros(nCycles,ceil(samples/rangeDecimationFactor));

for i = 1:nCycles
    data_str = fread(fid,samples,'ubit12=>double');
    data_str = data_str' - 2048;
    raw(i,:) = 2 * decimate(data_str .* sarShift, rangeDecimationFactor);
    fseek(fid,idx,'cof');
end

fclose(fid);

end