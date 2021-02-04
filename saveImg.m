function saveImg(img, path, name, mode)
    switch mode
        case 0
            saveGrayscale(img, path, name);
        case 1
            saveJetscale(img, path, name);
        case 2
            saveGrayscale(img, path, name);
            saveJetscale(img, path, name);
    end
end

function saveGrayscale(img, path, name)
    map = setMap(-1, 256);
    img_ = ind2rgb(im2uint8(img), map);
    imwrite(img_, strcat(path, '\', name, '_gray.png'));
end

function saveJetscale(img, path, name)
    img_ = ind2rgb(im2uint8(img), jet(128));
    imwrite(img_, strcat(path, '\', name, '_jet.png'));
end