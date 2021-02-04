function map = setMap(gain,shades)
  factor = 10^gain;
  map = ones(shades,3);
  
  for i = 1:1:shades
      map(i,:) = map(i,:) * log10(factor*(i-1) + 1) / log10(factor*(shades-1) + 1);
  end
end