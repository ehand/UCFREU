%Collect Positive Samples
function posRGB = collectPositiveSamples(template, im, origin)
horShift = 2;
vertShift = 2;

tempSize = size(template);
col = origin(1);
row = origin(2);

%BOUNDARY CHECKS!!!
%Above/left Template
for j=1:horShift
    for i=1:vertShift
        temp = im(row-j:(row-j+tempSize(1)), col-i:(col-i+tempSize(2)), :);
        [R G B] = computeHistograms(temp);
        posRGB(i+(j-1)*vertShift+1, :) = [R' G' B'];
    end
end

cont = i+(j-1)*vertShift;

%Below/right Template
for j=1:horShift
    for i=1:vertShift
        temp = im(row+j:(row+j+tempSize(1)), col+i:(col+i+tempSize(2)), :);
        [R G B] = computeHistograms(temp);
        posRGB(i+(j-1)*vertShift + cont, :) = [R' G' B'];
    end
end
