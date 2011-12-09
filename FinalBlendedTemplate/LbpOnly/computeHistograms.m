%Compute Histograms
function feature = computeHistograms(im, blockSize)
% 4 bins 3D histogram
binSize = 4;
denom = floor(256/binSize);
sizeTemp = size(im);
width = sizeTemp(2);
height = sizeTemp(1);
counter = 0;
endWidth = floor(width/blockSize)*blockSize - blockSize+1;
endHeight = floor(height/blockSize)*blockSize - blockSize+1;
    
%Compute 3D histogram
hist=[];
for y=1:blockSize/2:endHeight
	for x=1:blockSize/2:endWidth
        hist_3d = zeros(binSize, binSize, binSize);
		cur_block = im(y:y+blockSize-1, x:x+blockSize-1, :);
        for j=1:blockSize
		    for i=1:blockSize
			   R = cur_block(j, i, 1);
			   G = cur_block(j, i, 2);
			   B = cur_block(j, i, 3);
			   r = floor(R/denom)+1;
			   g = floor(G/denom)+1;
			   b = floor(B/denom)+1;
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
        counter = counter+1;
		hist(:,counter) = hist_3d(:);
        hist(:,counter) = hist(:,counter)/norm(hist(:,counter));
	end
end

feature = hist(:)';

    
%hist = hist_3d(:)';
