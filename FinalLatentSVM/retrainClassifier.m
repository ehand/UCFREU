%Retrain Classifier
function [svm_model posFeat negSamples posSamples negFeat] = retrainClassifier(im, template, svm_mod, N, templateOrigin, posFeat, posSamples, blockSize, TempSize, bb, models)
scale = 50;
sizeTemp = size(template);
resizedOriginalTemp = imresize(template, TempSize);
sizeIm = size(im);
height = sizeIm(1);
width = sizeIm(2);
reScore = zeros(floor(height/scale)-sizeTemp(1), floor(width/scale)-sizeTemp(2));
counter = 0;
numSamples = N;
confMap = zeros(N, 1);
confMap(find(confMap==0)) = -inf;
featMap = zeros(N, size(GenerateFeatures(zeros(TempSize(1), TempSize(2), 3), blockSize), 2));
negCnt = 0;

for k=1:size(bb,2)
    negBoxes{k} = [];
end
score = zeros(size(bb,2), 1);

%Densely Scan the Entire Frame to get a Score Map
for i=1:floor(width/scale)
    left = (i-1)*scale+1;
    for j=1:floor(height/scale)
        top = (j-1)*scale+1;
        %Edge Checking!
        if(top<(height-sizeTemp(1)) && left<(width-sizeTemp(2))) %Don't go out of bounds
            if(top<(templateOrigin(2)-sizeTemp(1)) || top>(templateOrigin(2)+sizeTemp(1)) || left<(templateOrigin(1)-sizeTemp(2)) || left>(templateOrigin(1)+sizeTemp(2)))%Don't get template as a negative sample
                temp = im(top:(top+sizeTemp(1)-1), left:(left+sizeTemp(2)-1), :);
                resizedTemp = imresize(temp, TempSize);
%                 for k=1:size(bb,2)
%                     box = resizedTemp(bb(k).rect(2):bb(k).rect(2)+bb(k).rect(4)-1, bb(k).rect(1):bb(k).rect(1)+bb(k).rect(3)-1,:);
%                     boxFeat{k} = computeBoxFeatures(box, blockSize);
%                     testing_instance_matrix = boxFeat{k};
%                     testing_label_vector=ones(size(testing_instance_matrix,1),1);
%                     [predicted_label, accuracy, decision_values] = svmpredict(testing_label_vector, testing_instance_matrix, models{k});
%                     map{k}(j,i) = decision_values;
%                     score(k) = decision_values;
%                 end
                sampleFeat = GenerateFeatures(resizedTemp, blockSize);
                testing_instance_matrix = sampleFeat;
                testing_label_vector=ones(size(testing_instance_matrix,1),1);
                [predicted_label, accuracy, decision_values] = svmpredict(testing_label_vector, testing_instance_matrix, svm_mod);
                reScore(j,i) = decision_values;
                if(confMap(find(confMap == min(confMap)))<decision_values)
                    pos = find(confMap == min(confMap));
                    if(size(pos,1)>1)
                        pos = pos(1,1);
                    end
                    confMap(pos) = decision_values;
                    featMap(pos, :) = sampleFeat;
%                     for k=1:size(bb,2)
%                         negBoxes{k} = [negBoxes{k}; boxFeat{k}];
%                     end
                    negCnt = negCnt+1;
                    negSamples(negCnt).image = resizedTemp;
                    
                end
                counter = counter+1;
            end
        end
    end
end

negFeat = featMap;

%find max for each score map
%Find new bounding boxes
% for i=1:size(bb,2)
%     R = map{i}(:);
%     [num idx] = max(R);
%     [x y] = ind2sub(size(map{i}),idx);
%     
%     %change position for each block and save in bbox
%     bb(i).rect(1) = x;
%     bb(i).rect(2) = y;
% end


% %Densely Scan the Entire Frame to get a Score Map
% for i=1:floor(width/scale)
%     left = (i-1)*scale+1;
%     for j=1:floor(height/scale)
%         top = (j-1)*scale+1;
%         bottom = top+sizeTemp(1);
%         %Edge Checking!
%         if(top<(height-sizeTemp(1)) && left<(width-sizeTemp(2))) %Don't go out of bounds
%             if(top<(templateOrigin(2)-sizeTemp(1)) || top>(templateOrigin(2)+sizeTemp(1)) || left<(templateOrigin(1)-sizeTemp(2)) || left>(templateOrigin(1)+sizeTemp(2)))%Don't get template as a negative sample
%                 temp = im(top:(top+sizeTemp(1)-1), left:(left+sizeTemp(2)-1), :);
%                 resizedTemp = imresize(temp, TempSize);
%                 sampleFeat = GenerateFeatures(resizedTemp, blockSize);
%                 testing_instance_matrix = sampleFeat;
%                 testing_label_vector=ones(size(testing_instance_matrix,1),1); % Create a vector; its value doesn't matter
%                 [predicted_label, accuracy, decision_values] = svmpredict(testing_label_vector, testing_instance_matrix, svm_mod);
%                 reScore(j,i) = decision_values;
%                 counter = counter+1;
%             end
%         end
%     end
% end
% 
% %FIND N HIGHEST VALUES of scoremap and retrain classifier.... with new
% %positive samples and new negative samples
% 
% %Find N top values of the matrix
% linearReScore=reScore(:);
% value=zeros(N,1);
% index=zeros(N,1);
% for i=1:N
%     [value(i),index(i)]=max(linearReScore);
%     linearReScore(index(i))=-inf;
% end;
% 
% 
% %NEGATIVE SAMPLES
% %Compute Origin of Negative Sample
% sizeRe = size(reScore);
% rows = sizeRe(1);
% 
% cnt = 0;
% for i=1:N
%     %Get actual indices
%     col = floor(index(i)/rows) + 1;
%     [~,y]=deal(fix(index(i)/rows), (index(i)/rows)-fix(index(i)/rows));
%     row = floor(y*rows) + 1;
%     col = col*scale;
%     row = row*scale;
%     %Get Individual Templates
%     if(row < height-sizeTemp(1) && col < width-sizeTemp(2))
%         temp_cur = im(row:(row+sizeTemp(1)-1), col:(col+sizeTemp(2)-1), :);
%         cnt = cnt+1;
%         tempResize = imresize(temp_cur, TempSize);
%         negFeat(cnt, :) = GenerateFeatures(tempResize, blockSize);
%         negSamples(cnt).image = tempResize;
%     end;
% end
% 
num = size(posSamples, 2);

posSamples(num+1).image = resizedOriginalTemp;

newPosFeat = GenerateFeatures(resizedOriginalTemp, blockSize);
posFeat = [posFeat; newPosFeat];


svm_model = SVMClassification(posFeat, negFeat);

disp('end of retrain classifier');





