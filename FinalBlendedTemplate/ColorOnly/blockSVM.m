function block=blockSVM(feaTest,feaPos,feaNeg,NumBlocks,Numfeatures,svm_model,NumPos,NumNeg)

% Given the whole feature vector, this function will return the svm scores for
% each blocks.

% featest----feature vector of the Testing sample  <1 * #features>
% feaPos----feature table of all positive samples  <#samples * #features>
% feaNeg----feature table of all negative samples  <#samples * #features>
% Numfeatures---dimensions of the feature vector
% NumBlocks---Number of blocks in one template (105 in our case)
% svm_model---- trained svm model
% NumPos----Number of positive samples
% NumNeg----Number of negative samples

bb=-svm_model.rho;
w=sum(repmat(svm_model.sv_coef,1,Numfeatures).*svm_model.SVs);
SumPos=NumPos*bb+sum(feaPos*w');
SumNeg=NumNeg*bb+sum(feaNeg*w');
A=-SumNeg/SumPos;
B=-1/(A*NumPos+NumNeg);
NumfeaBlock=Numfeatures/NumBlocks-1;

for i = 1:NumBlocks    
    beta(i)=B*(A*sum(feaPos(:,((i-1)*NumfeaBlock+1:i*NumfeaBlock)),1)+sum(feaNeg(:,((i-1)*NumfeaBlock+1:i*NumfeaBlock))))...
        *w((i-1)*NumfeaBlock+1:i*NumfeaBlock)';
    
    block(i) = beta(i) +  feaTest((i-1)*NumfeaBlock+1:i*NumfeaBlock) * w((i-1)*NumfeaBlock+1:i*NumfeaBlock)';    
end
a=1;
