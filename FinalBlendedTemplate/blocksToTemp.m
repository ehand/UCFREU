%This function will, given a block set block height and block width, return
%a template
function temp = blocksToTemp(blockSet, blockHeight, blockWidth, blockSize, shift)
count = 0;
for j=1:blockHeight
    for i=1:blockWidth
        count = count+1;
        temp((j-1)*shift+1:(j-1)*shift+blockSize, (i-1)*shift+1:(i-1)*shift+blockSize, :) = blockSet(count).block;
    end
end