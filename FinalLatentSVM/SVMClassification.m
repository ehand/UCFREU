%SVM Classification
function svm_model = SVMClassification(posFeat, negFeat)

% Modify the path here !!!
addpath '/home/emily/libsvm-3.1/matlab';

sizePos = size(posFeat);
sizeNeg = size(negFeat);

training_label_vector1 = [ones(1,sizePos(1)),-1*ones(1,sizeNeg(1))];
training_instance_matrix1 = [posFeat; negFeat];
svm_model = svmtrain(training_label_vector1', training_instance_matrix1, '-t 0');

% % Training
% for i=1:sizePos(1)
%     training_label_vector(i)=1;
%     training_instance_matrix(i, :) = posFeat(i,:);
% end
% 
% for i=1:sizeNeg(1)
%     training_instance_matrix((i+sizePos(1)), :) = negFeat(i,:);
%     training_label_vector(i+sizePos(1)) = -1;
% end
% 
% svm_model = svmtrain(training_label_vector', training_instance_matrix, '-t 0'); %-t 0 is linear something??
% v=1;

