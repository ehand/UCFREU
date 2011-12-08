function [totalScore location] = newScoreMap(predPos, threshCount, search, template, svm_mod, blockSize, TempSize, models, bb)

sizeTemp = size(template);
sizeIm = size(search);
width = sizeIm(2);
height = sizeIm(1);
scale = 5;
numBB = size(bb,2)+1;
%resizeTemp = imresize(template, TempSize);
bb(numBB).rect = [0,0,size(template, 2), size(template, 1)];
models{numBB} = svm_mod;

%Densely Scan the Neighborhood
for i=1:floor(width/scale)
    absLeft = (i-1)*scale+1;
    for j=1:floor(height/scale)
        absTop = (j-1)*scale+1;
        if(absTop<(height-sizeTemp(1)) && absLeft<(width-sizeTemp(2)))
            temp = search(absTop:(absTop+sizeTemp(1)-1), absLeft:(absLeft+sizeTemp(2)-1), :);
            resizeTemp = imresize(temp, TempSize);
            for k=1:numBB-1
                left = bb(k).rect(1);
                right = bb(k).rect(1)+bb(k).rect(3)-1;
                top = bb(k).rect(2);
                bottom = bb(k).rect(2)+bb(k).rect(4)-1;
                if(bottom<=TempSize(1) && right<=TempSize(2)) %This needs to be fixed. There is a better parameter for this.
                    partTemp = resizeTemp(top:bottom, left:right, :);
                    sampleFeat = computeBoxFeatures(partTemp, blockSize);
                    testing_instance_matrix = sampleFeat;
                    testing_label_vector=ones(size(testing_instance_matrix,1),1);
                    if(isempty(predPos))
                        [predicted_label, accuracy, decision_values] = svmpredict(testing_label_vector, testing_instance_matrix, models{k});
                        cur_score = decision_values;
                    else
                        cur_score = calculateCost([j, i], predPos, models{k}, threshCount, testing_instance_matrix);
                    end
                    score{k}(j,i) = cur_score;
                else
                    score{k}(j,i) = 0;
                end
                
            end
            sampleFeat = GenerateFeatures(resizeTemp, blockSize);
            testing_instance_matrix = sampleFeat;
            testing_label_vector=ones(size(testing_instance_matrix,1),1); % Create a vector; its value doesn't matter
            if(isempty(predPos))
                [predicted_label, accuracy, decision_values] = svmpredict(testing_label_vector, testing_instance_matrix, models{numBB});
                cur_score = decision_values;
            else
                cur_score = calculateCost([j, i], predPos, svm_mod, threshCount, testing_instance_matrix);
            end
            score{numBB}(j,i) = cur_score;
        end
    end
end

totalScore = score{1}+score{2}+score{3}+score{4}+score{5}+score{6}+score{7};

D = totalScore(:);
[num idx] = max(D);
[x y] = ind2sub(size(totalScore),idx);
location = [(x-1)*scale (y-1)*scale];
disp('end of score map');

v=1;
