function img = SARpostprocess(img,h,dr,V,PRF,resol,cut_near,cut_far,db_cut_level_hi,db_cut_level_lo)
    img_final = abs(img);
    img_final_m = imresize(img_final, [(1/resol) * V * size(img_final, 1) / PRF   (1/resol) * dr * size(img_final, 2)], 'bilinear'); % resize to metric scale
    
    R1 = 1 : size(img_final_m, 2);
    R2 = sqrt(((1/resol) * h + R1) .^ 2 - ((1/resol) * h) .^ 2);
    for k = 1 : size(img_final_m, 1)
        post(k, :) = interp1(R2, img_final_m(k, :), R1, 'PCHIP'); % nonlinear interpolation, earth surface projection
    end

    img = abs(post)/max(max(abs(post)));
    img = flip(img);
  
    img(img > 10 ^ (db_cut_level_hi / 10)) = 10 ^ (db_cut_level_hi / 10);
    img(img < 10 ^ (db_cut_level_lo / 10)) = 10 ^ (db_cut_level_lo / 10);

end
