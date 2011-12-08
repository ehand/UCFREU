function boxFeat = computeBoxFeatures(im, blockSize)

boxFeat = GenerateFeatures(im, blockSize);



% binSize = 8;
% sizeTemp = size(im);
% width = sizeTemp(2);
% height = sizeTemp(1);
% endWidth = floor(width/blockSize)*blockSize - blockSize+1;
% endHeight = floor(height/blockSize)*blockSize - blockSize+1;
% histFeat=[];
% hist_3d = zeros(binSize, binSize, binSize);
% 
% for y=1:floor(blockSize/2):endHeight
%     for x=1:floor(blockSize/2):endWidth
% 		cur_block = im(y:y+blockSize-1, x:x+blockSize-1, :);
%         %Histogram
%         for j=1:blockSize
% 		    for i=1:blockSize
% 			   R_hist = cur_block(j, i, 1);
% 			   G_hist = cur_block(j, i, 2);
% 			   B_hist = cur_block(j, i, 3);
% 			   r = floor(R_hist/(256/binSize))+1;
% 			   g = floor(G_hist/(256/binSize))+1;
% 			   b = floor(B_hist/(256/binSize))+1;
% 			   if(r==binSize+1)
% 				  r = binSize;
% 			   end
% 			   if(g==binSize+1)
% 				  g = binSize;
% 			   end
% 			   if(b==binSize+1)
% 				  b = binSize;
% 			   end
% 			   hist_3d(r,g,b) = hist_3d(r,g,b)+1;
% 		    end
%         end
%         tempHist = hist_3d(:)';
%         tempHist = tempHist/norm(tempHist);
% 		histFeat = [histFeat tempHist];
%     end
% end
% 
% boxFeat = histFeat;


% R = im(:,:,1);
% G = im(:,:,2);
% B = im(:,:,3);
% 
% [R_Hist n] = imhist(R);
% [G_Hist n] = imhist(G);
% [B_Hist n] = imhist(B);
% 
% 
% boxFeat = [R_Hist' G_Hist' B_Hist'];
