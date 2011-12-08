%Generate Hog Features
function feature = GenerateHOGFeatures(im, blockSize)

sizeTemp = size(im);
width = sizeTemp(2);
height = sizeTemp(1);
counter = 0;
endWidth = floor(width/blockSize)*blockSize - blockSize+1;
endHeight = floor(height/blockSize)*blockSize - blockSize+1;

%Scanning
for j=1:floor(blockSize/2):endHeight
    for i=1:floor(blockSize/2):endWidth
        cur_block = im(j:j+blockSize-1, i:i+blockSize-1, :);
        R = cur_block(:, :, 1);
        G = cur_block(:, :, 2);
        B = cur_block(:, :, 3);
        counter = counter+1;
        feature(:, counter) = HOG(R);
        feature(:, counter) = feature(:, counter)/norm(feature(:, counter));
        counter = counter+1;
        feature(:, counter) = HOG(G);
        feature(:, counter) = feature(:, counter)/norm(feature(:, counter));
        counter = counter+1;
        feature(:, counter) = HOG(B);
        feature(:, counter) = feature(:, counter)/norm(feature(:, counter));
    end
end

feature = feature(:);
feature = feature';