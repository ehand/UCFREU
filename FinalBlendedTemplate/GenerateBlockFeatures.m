function features = GenerateBlockFeatures(blockSize, template)
sizeTemp = size(template);
width = sizeTemp(2);
height = sizeTemp(1);
shift = blockSize/2;
cnt = 0;

for j=1:shift:height-blockSize
    for i=1:shift:width-blockSize
        cnt = cnt+1;
        tempBlock = template(j:j+blockSize, i:i+blockSize, :);
        features(cnt, :) = GenerateFeatures(tempBlock, blockSize);
    end
end