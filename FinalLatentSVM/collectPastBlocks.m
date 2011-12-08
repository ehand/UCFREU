%this function will, given the most recent positive blocks, and the new
%template and score map, replace the positive blocks in the collection with
%the most recent positive blocks from the present template
function pastBlocks = collectPastBlocks(pastBlocks, map, template, blocksWide, blocksHigh, blockSize, shift, threshold, TempSize)

newBlocks = templateToBlockSet(template, blockSize, shift, blocksHigh, blocksWide, TempSize);
count=0;
for j=1:size(map, 1)
    for i=1:size(map,2)
        count=count+1;
        if(map(j,i)>threshold)
            pastBlocks(count).block = newBlocks(count).block;
        end
    end
end
