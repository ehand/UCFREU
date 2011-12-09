%Make Scoremap
function [score location] = scoreMap(predPos, threshCount, im, template, svm_mod, blockSize, frame)
%Area = col, row, width, height
sizeIm = size(im);
width = sizeIm(2);
height = sizeIm(1);

sizeTemp = size(template);

scale = 5;
score = zeros(floor(height/scale)-sizeTemp(1), floor(width/scale)-sizeTemp(2));

%Densely Scan the Neighborhood
for i=1:floor(width/scale)
    left = (i-1)*scale+1;
    for j=1:floor(height/scale)
        top = (j-1)*scale+1;       
        %Edge Checking!
        if(top<(height-sizeTemp(1)) && left<(width-sizeTemp(2)))
            temp = im(top:(top+sizeTemp(1)), left:(left+sizeTemp(2)), :);
            sampleFeat = GenerateFeatures(temp, blockSize, frame);
            testing_instance_matrix = sampleFeat;
            testing_label_vector=ones(size(testing_instance_matrix,1),1); % Create a vector; its value doesn't matter
            if(isempty(predPos))
                [predicted_label, accuracy, decision_values] = svmpredict(testing_label_vector, testing_instance_matrix, svm_mod);
                cur_score = decision_values;
            else
                cur_score = calculateCost([top, left], predPos, svm_mod, threshCount, testing_instance_matrix);
            end
            score(j,i) = cur_score;
        end
    end
end

D = score(:);
[num idx] = max(D);
[x y] = ind2sub(size(score),idx);
location = [(x-1)*scale (y-1)*scale];
disp('end of score map');

