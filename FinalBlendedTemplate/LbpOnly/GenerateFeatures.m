%Generate Features
function feature = GenerateFeatures(im, blockSize, frame)


%%COLOR HISTOGRAM
%histFeat = computeHistograms(im, blockSize);

%%LBP Features
%lbpFeat = GenerateGrayLBPFeatures(im, blockSize);
  
%%GRAY VALUES
  
%%HOG Features
%hogFeat = GenerateGrayHOGFeatures(im, blockSize);

%%Concatenate All Features
%feature = [hogFeat lbpFeat histFeat];

feature = computeCombinedFeatures(im, 16);
