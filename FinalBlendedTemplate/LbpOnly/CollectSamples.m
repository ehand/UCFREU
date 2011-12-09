function [svm_mod posFeatures negSamples negFeatures numBlocks] = CollectSamples(im0, template, reverseTemp, templateOrigin, N, blockSize, frame)

scale = 3;

sizeofTemplate = size(template);
[rows, cols, ~] = size(im0);

%Collect Positive Samples
[posFeatures numBlocks] = GenerateFeaturesInit(template, blockSize);
posFeatures = [posFeatures; GenerateFeatures(reverseTemp, blockSize, frame)];

%This calculates how many templates can fit in the space of the image
horChange = cols/sizeofTemplate(2);
vertChange = rows/sizeofTemplate(1);

shiftVert = sizeofTemplate(1);
shiftHor = sizeofTemplate(2)/scale;

cnt = 0;
numVertChange = floor(vertChange);
numHorizontalChange = floor(horChange)-2;

numHorizontalChange = numHorizontalChange*scale-10;

noCntr = 0;
topShift = 50;

%fig1 = figure;
for j=1:numVertChange
    for i=1:numHorizontalChange
        %Calculate the top/bottom/left/right of the new sample
        top = floor((j-1)*shiftVert+topShift);
        bottom = floor((j-1)*shiftVert+shiftVert+topShift);
        left = floor((i-1)*shiftHor);
        right = floor((i-1)*shiftHor+sizeofTemplate(2));
        
        if top==0
            top = 1;
        end
        if left==0
            left = 1;
        end
        
        %Avoid positive sample
        if (bottom < templateOrigin(2) && top < templateOrigin(2)) || (top > templateOrigin(2)+sizeofTemplate(1) && bottom > templateOrigin(2)+sizeofTemplate(1))
            if left > 0 && right < cols && top > 0 && bottom < rows
                temp=(im0(top:bottom-1,left:right-1,:));
                cnt = cnt+1;
                negSamples(cnt).image = temp;
                disp(cnt);
                negFeatures(cnt, :) = GenerateFeatures(temp, blockSize, frame);
            end
        %This is a check to see if the samples are passing over the template    
        else
            noCntr = noCntr+1;            
        end
        
        if cnt == N
            break;
        end
    end
    if cnt == N
        break;
    end
end


svm_mod = SVMClassification(posFeatures, negFeatures);


