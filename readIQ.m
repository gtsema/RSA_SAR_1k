function result = readIQ(rawDataFile)
    result = [];
    load(rawDataFile);
    result = [result; complex(rawRe,rawIm)];
end