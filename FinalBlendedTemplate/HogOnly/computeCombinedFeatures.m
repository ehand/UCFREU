function [feature numBlocks] = computeCombinedFeatures(im, blockSize)

binSize = 4;
sizeTemp = size(im);
width = sizeTemp(2);
height = sizeTemp(1);
counter = 0;
endWidth = floor(width/blockSize)*blockSize - blockSize+1;
endHeight = floor(height/blockSize)*blockSize - blockSize+1;
bwIm = rgb2gray(im);
blockWide = 0;
blockHigh = 0;
histFeat=[];
hist_3d = zeros(binSize, binSize, binSize);
% %PRE ALLOCATE
% hogFeat = zeros(81, columns);
% lbpFeat = zeros(columns, 256);
%histFeat = zeros(1, columns*binSize^3);
for y=1:floor(blockSize/2):endHeight
	for x=1:floor(blockSize/2):endWidth
		cur_block = im(y:y+blockSize-1, x:x+blockSize-1, :);
        cur_bw_block = bwIm(y:y+blockSize-1, x:x+blockSize-1);
        %Histogram
        %for j=1:blockSize
	%	    for i=1:blockSize
	%		   R_hist = cur_block(j, i, 1);
	%		   G_hist = cur_block(j, i, 2);
	%		   B_hist = cur_block(j, i, 3);
	%		   r = floor(R_hist/64)+1;
	%		   g = floor(G_hist/64)+1;
	%		   b = floor(B_hist/64)+1;
	%		   if(r==5)
	%			  r = 4;
	%		   end
	%		   if(g==5)
	%			  g = 4;
	%		   end
	%		   if(b==5)
	%			  b = 4;
	%		   end
	%		   hist_3d(r,g,b) = hist_3d(r,g,b)+1;
	%	    end
        %end
        %HOG
        counter = counter+1;
        hogFeat(:, counter) = HOG(cur_bw_block);
        hogFeat(:, counter) = hogFeat(:, counter)/norm(hogFeat(:, counter));
        %lbpFeat(counter, :) = LBP(cur_bw_block);
        %lbpFeat(counter, :) = lbpFeat(counter, :)/norm(lbpFeat(counter, :));
        %tempHist = hist_3d(:)';
        %tempHist = tempHist/norm(tempHist);
	%	histFeat = [histFeat tempHist];
        blockWide = blockWide+1;
    end
    blockHigh = blockHigh+1;
end

blockWide = blockWide/blockHigh;

numBlocks = [blockHigh blockWide];

%lbpFeat = lbpFeat';
%feature = lbpFeat(:)';
feature = hogFeat(:)';
%feature = [hogFeat(:)' lbpFeat(:)' histFeat];
