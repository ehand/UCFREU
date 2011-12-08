%Collect Block Samples
%This will, given a block, find its position in the template and find all
%corresponding blocks in all negative and positive samples
function [negFeatures posFeatures] = CollectBlockSamples(block, negSamples, position, posSamples, blockSize)
%position = findBlockPos(template, block, shift);

for i=1:size(negSamples, 2)
    newBlock = negSamples(i).image(position(1):position(1)+blockSize, position(2):position(2)+blockSize, :);
    negFeatures(i, :) = GenerateFeatures(newBlock, blockSize);
end

for i=1:size(posSamples, 2)
    newBlock = posSamples(i).image(position(1):position(1)+blockSize, position(2):position(2)+blockSize, :);
    posFeatures(i, :) = GenerateFeatures(newBlock, blockSize);
end

