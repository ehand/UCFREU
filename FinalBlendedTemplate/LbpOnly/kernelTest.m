[heart_scale_label, heart_scale_inst] = libsvmread('/home/emily/libsvm-3.1/heart_scale');

%Split Data
train_data = heart_scale_inst(1:150,:);
train_label = heart_scale_label(1:150,:);
test_data = heart_scale_inst(151:270,:);
test_label = heart_scale_label(151:270,:);
pre = train_data*train_data';
pre2 = test_data*train_data';

% Linear Kernel
model_linear = svmtrain(train_label, train_data, '-t 0');
tic
[predict_label_L, accuracy_L, dec_values_L] = svmpredict(test_label, test_data, model_linear);
toc

% Precomputed Kernel
model_precomputed = svmtrain(train_label, [(1:150)', pre], '-t 4');
tic
[predict_label_P, accuracy_P, dec_values_P] = svmpredict(test_label, [(1:120)', pre2], model_precomputed);
toc

disp(accuracy_L); % Display the accuracy using linear kernel
disp(accuracy_P); % Display the accuracy using precomputed kernel