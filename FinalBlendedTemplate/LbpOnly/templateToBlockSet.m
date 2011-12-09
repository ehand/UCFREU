%This function will, given a template, create a structure containing all
%blocks
function blocks = templateToBlockSet(template, blockSize, shift, blocksHigh, blocksWide)
count = 0;
for j=1:blocksHigh
    for i=1:blocksWide
        count = count+1;
        blocks(count).block = template((j-1)*shift+1:(j-1)*shift+blockSize, (i-1)*shift+1:(i-1)*shift+blockSize, :);
    end
end