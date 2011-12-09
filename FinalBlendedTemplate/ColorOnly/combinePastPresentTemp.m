%This function will, given the past template, and the present template as
%well as the block score map, create a blended template.
function blend = combinePastPresentTemp(pastBlocks, present, map, thresh, shift, blockSize)
sizeTemp = size(present);
sizeMap = size(map);
mapWidth = sizeMap(2);
mapHeight = sizeMap(1);
blend = zeros(sizeTemp);

blend = blocksToTemp(pastBlocks, mapHeight, mapWidth, blockSize, shift);
sizeBlend = size(blend);

width = sizeTemp(2)-sizeBlend(2);
height = sizeTemp(1)-sizeBlend(1);
blend = padarray(blend, [0, width], 'post');
blend = padarray(blend, [height, 0], 'post');

for j=1:mapHeight
    for i=1:mapWidth
        yStart = (j-1)*shift+1;
        xStart = (i-1)*shift+1;
        %Assign Appropriate Values from Present to Blend
        if(map(j,i)>thresh)
            blend(yStart:yStart+blockSize-1, xStart:xStart+blockSize-1, :) = present(yStart:yStart+blockSize-1, xStart:xStart+blockSize-1, :);
        end
    end
end
