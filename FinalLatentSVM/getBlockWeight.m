function Weight=getBlockWeight(NumBlocks,Numfeatures,svm_model)

% return the SVM weight for each block. The weight reflects how
% discriminative the block is.
% Numfeatures---dimensions of the feature vector
% NumBlocks---Number of blocks in one template (105 in our case)
% svm_model---- trained svm model


w=sum(repmat(svm_model.sv_coef,1,Numfeatures).*svm_model.SVs);
NumfeaBlock=round(Numfeatures/NumBlocks);
w=reshape(w(:),NumfeaBlock,NumBlocks);
w(w<0)=0;
Weight=sum(w);


