function feature = computeCombinedColorFeatures(im, blockSize)

binSize = 8;
sizeTemp = size(im);
width = sizeTemp(2);
height = sizeTemp(1);
counter = 0;
endWidth = floor(width/blockSize)*blockSize - blockSize+1;
endHeight = floor(height/blockSize)*blockSize - blockSize+1;
bwIm = rgb2gray(im);
histFeat=[];

for y=1:floor(blockSize/2):endHeight
	for x=1:floor(blockSize/2):endWidth
        hist_3d = zeros(binSize, binSize, binSize);
		cur_block = im(y:y+blockSize-1, x:x+blockSize-1, :);
        cur_bw_block = bwIm(y:y+blockSize-1, x:x+blockSize-1);
        %Histogram
        for j=1:blockSize
		    for i=1:blockSize
			   R_hist = cur_block(j, i, 1);
			   G_hist = cur_block(j, i, 2);
			   B_hist = cur_block(j, i, 3);
			   r = floor(R_hist/(256/binSize))+1;
			   g = floor(G_hist/(256/binSize))+1;
			   b = floor(B_hist/(256/binSize))+1;
			   if(r==binSize+1)
				  r = binSize;
			   end
			   if(g==binSize+1)
				  g = binSize;
			   end
			   if(b==binSize+1)
				  b = binSize;
			   end
			   hist_3d(r,g,b) = hist_3d(r,g,b)+1;
		    end
        end
        %HOG
        R = cur_block(:,:,1);
        G = cur_block(:,:,2);
        B = cur_block(:,:,3);
        counter = counter+1;
        hogFeat(:, counter) = HOG(R);
        hogFeat(:, counter) = hogFeat(:, counter)/norm(hogFeat(:, counter));
        lbpFeat(counter, :) = LBP(R);
        lbpFeat(counter, :) = lbpFeat(counter, :)/norm(lbpFeat(counter, :));
        counter = counter+1;
        hogFeat(:, counter) = HOG(G);
        hogFeat(:, counter) = hogFeat(:, counter)/norm(hogFeat(:, counter));
        lbpFeat(counter, :) = LBP(G);
        lbpFeat(counter, :) = lbpFeat(counter, :)/norm(lbpFeat(counter, :));
        counter = counter+1;
        hogFeat(:, counter) = HOG(B);
        hogFeat(:, counter) = hogFeat(:, counter)/norm(hogFeat(:, counter));
        lbpFeat(counter, :) = LBP(B);
        lbpFeat(counter, :) = lbpFeat(counter, :)/norm(lbpFeat(counter, :));

        tempHist = hist_3d(:)';
        tempHist = tempHist/norm(tempHist);
		histFeat = [histFeat tempHist];
	end
end

lbpFeat = lbpFeat';

feature = [hogFeat(:)' lbpFeat(:)' histFeat];