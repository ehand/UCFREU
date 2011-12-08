%Retrain Classifier
function [svm_model posFeat negSamples posSamples negFeat] = retrainClassifier(im, template, svm_mod, N, templateOrigin, posFeat, posSamples, blockSize, frame)
scale = 50;
sizeTemp = size(template);
sizeIm = size(im);
height = sizeIm(1);
width = sizeIm(2);
reScore = zeros(floor(height/scale)-sizeTemp(1), floor(width/scale)-sizeTemp(2));
counter = 0;
numSamples = N;

%Densely Scan the Entire Frame to get a Score Map
for i=1:floor(width/scale)
    left = (i-1)*scale+1;
    for j=1:floor(height/scale)
        top = (j-1)*scale+1;
        bottom = top+sizeTemp(1);
        %Edge Checking!
        if(top<(height-sizeTemp(1)) && left<(width-sizeTemp(2))) %Don't go out of bounds
            if(top<(templateOrigin(2)-sizeTemp(1)) || top>(templateOrigin(2)+sizeTemp(1)) || left<(templateOrigin(1)-sizeTemp(2)) || left>(templateOrigin(1)+sizeTemp(2)))%Don't get template as a negative sample
                temp = im(top:(top+sizeTemp(1)-1), left:(left+sizeTemp(2)-1), :);
                sampleFeat = GenerateFeatures(temp, blockSize, frame);
                testing_instance_matrix = sampleFeat;
                testing_label_vector=ones(size(testing_instance_matrix,1),1); % Create a vector; its value doesn't matter
                [predicted_label, accuracy, decision_values] = svmpredict(testing_label_vector, testing_instance_matrix, svm_mod);
                reScore(j,i) = decision_values;
                counter = counter+1;
            end
        end
    end
end

%FIND N HIGHEST VALUES of scoremap and retrain classifier.... with new
%positive samples and new negative samples

%Find N top values of the matrix
linearReScore=reScore(:);
value=zeros(N,1);
index=zeros(N,1);
for i=1:N
    [value(i),index(i)]=max(linearReScore);
    linearReScore(index(i))=-inf;
end;


%NEGATIVE SAMPLES
%Compute Origin of Negative Sample
sizeRe = size(reScore);
rows = sizeRe(1);

cnt = 0;
for i=1:N
    %Get actual indices
    col = floor(index(i)/rows) + 1;
    [~,y]=deal(fix(index(i)/rows), (index(i)/rows)-fix(index(i)/rows));
    row = floor(y*rows) + 1;
    col = col*scale;
    row = row*scale;
    %Get Individual Templates
    if(row < height-sizeTemp(1) && col < width-sizeTemp(2))
        temp_cur = im(row:(row+sizeTemp(1)-1), col:(col+sizeTemp(2)-1), :);
        cnt = cnt+1;
        negFeat(cnt, :) = GenerateFeatures(temp_cur, blockSize, frame);
        negSamples(cnt).image = temp_cur;
    end;
end

num = size(posSamples, 2);

posSamples(num+1).image = template;

newPosFeat = GenerateFeatures(template, blockSize, frame);
posFeat = [posFeat; newPosFeat];
R = template(:,:,1);
G = template(:,:,2);
B = template(:,:,3);
R = fliplr(R);
G = fliplr(G);
B = fliplr(B);
reverseTemp(:,:,1) = R;
reverseTemp(:,:,2) = G;
reverseTemp(:,:,3) = B;
posSamples(num+2).image=reverseTemp;
newPosFeat = GenerateFeatures(reverseTemp, blockSize, frame);
posFeat = [posFeat; newPosFeat];

svm_model = SVMClassification(posFeat, negFeat);

disp('end of retrain classifier');





