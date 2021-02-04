function [output_img, img_name] = doImg_rd_simple(gain, shades, resol, cut_near, cut_far, db_cut_level_hi, db_cut_level_lo, c, f_geter, az_begin, az_end, V, h, beam, rawDataFile, headerFile)

    [fs, f0, chirpBandwidth, chirpT, rangeDecimationFactor, PRF, ~] = readSettings(headerFile);
    
    f_mid = (2*(f0 + f_geter) + chirpBandwidth) / 2;
    fs = fs / rangeDecimationFactor;
    dr = c / fs / 2;
    h_samp = ceil(h / dr);
    offset_cut = ceil(fs * chirpT); 
    end_cut = ceil(2*h_samp) + offset_cut;    
            
    raw = readIQ(rawDataFile);
%     map = setMap(gain, shades);

    raw = raw(1+round(end*az_begin):round(end*az_end), 1+offset_cut:end_cut);
    
    tNear = chirpT;

    processed = SAR_process(conj(double(raw)),V,f_mid,PRF,fs,beam,tNear,chirpBandwidth,chirpT);
    
    img = SARpostprocess(processed, h, dr, V, PRF, resol, cut_near, cut_far, db_cut_level_hi, db_cut_level_lo);
    
    [~, fname, ~] = fileparts(rawDataFile);
    output_img = mat2gray(img);
    
    img_name = strcat(fname, '_v', num2str(V));
end