%Generate features Init
function [features numBlocks] = GenerateFeaturesInit(im, blockSize)

[features numBlocks] = computeCombinedFeatures(im, blockSize);