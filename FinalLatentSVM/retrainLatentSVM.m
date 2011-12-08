function bb = retrainLatentSVM(bb, models, template, TempSize, blockSize, shift)
%Function for most recent template
%Finds new bounding boxes.

resizedTemp = imresize(template, TempSize);

for j=1:shift:TempSize(1)-shift
	for i=1:shift:TempSize(2)-shift
		for k=1:size(bb,2)
			if(j+bb(k).rect(4)-1<=TempSize(1) && i+bb(k).rect(3)-1 <=TempSize(2))
				temp = resizedTemp(j:j+bb(k).rect(4)-1, i:i+bb(k).rect(3)-1, :);
				features = computeBoxFeatures(temp, blockSize);
				%SVM PREDICT
                testing_instance_matrix = features;
                testing_label_vector=ones(size(testing_instance_matrix,1),1); % Create a vector; its value doesn't matter
                [predicted_label, accuracy, decision_values] = svmpredict(testing_label_vector, testing_instance_matrix, models{k});
                score{k}(j,i) = decision_values;
			end
		end
	end
end

for i=1:size(bb,2)
    score{i}(find(score{i}==0)) = -inf;
end

%find max for each score map
for i=1:size(bb,2)
    D = score{i}(:);
    [num idx] = max(D);
    [y x] = ind2sub(size(score{i}),idx);
    
    %change position for each block and save in bbox
    bb(i).rect(1) = x;
    bb(i).rect(2) = y;
end