%this function will, given a set of bounding boxes, train SVMs for each
%bounding box and return the models for each
function models = trainLatentSVM(bb, blockSize, pos, neg, TempSize)

posFeat = [];
negFeat = [];
for i=1:size(bb,2)
    for j=1:size(pos,2)
        pos(j).image = imresize(pos(j).image, TempSize);
        temp = pos(j).image(bb(i).rect(2):bb(i).rect(2)+bb(i).rect(4)-1, bb(i).rect(1):bb(i).rect(1)+bb(i).rect(3)-1, :);
        posFeat = [posFeat;computeBoxFeatures(temp, blockSize)];
    end
    for k=1:size(neg, 2)
        neg(k).image = imresize(neg(k).image, TempSize);
        temp = neg(k).image(bb(i).rect(2):bb(i).rect(2)+bb(i).rect(4)-1, bb(i).rect(1):bb(i).rect(1)+bb(i).rect(3)-1, :);
        negFeat = [negFeat; computeBoxFeatures(temp, blockSize)];
    end
    models{i} = SVMClassification(posFeat, negFeat);
    posFeat = [];
    negFeat = [];
end