close all;clear;clc;
tic
%% File Path
filePath = '/home/emily/Desktop/Airport1A_2/';
fileName = 'Airport1_';

%% Parameters
speedlimit=40;
N = 100; %Number of negative samples
threshold = 0.40;
st_im = 28;
NumberOfFrames = 794;
threshCount = 0;
detectorAssumption = st_im+1;
blockSize = 16;
shift = floor(blockSize/2);
predictFrame = 2;
sizeThresh = 25;
retrainBlocks = false;
sizeTemp = [128 64];
blockThresh = 0.00;
threshRange = 0.13;

loopCounter=1;

%% Initiation of the 1st frame
%im0 =read(video,st_im);
im0 = imread(sprintf([filePath fileName '%04d.jpg'], st_im));
[height width ~]=size(im0);
figure(1),imshow(im0);
hold on;

%% Manually labelling
goodSize = 0;
while(goodSize == 0)
    figure(1);imshow(im0);
    hold on;
    h=imrect;
    p = uint16(getPosition(h));
    wide = p(3);
    high = p(4);
    if(wide>sizeThresh && high>sizeThresh)
        goodSize = 1;
    end
end
if(mod(high, shift) == 0)
    blocksHigh = floor(high/shift)-2;
else
    blocksHigh = floor(high/shift)-2;
end
if(mod(wide, shift) == 0)
    blocksWide = floor(wide/shift)-2;
else
    blocksWide = floor(wide/shift)-2;
end
numBlocks = (blocksWide*blocksHigh);
blockConfThresh = floor(numBlocks/3);


template=(im0(p(2):p(2)+p(4)-1,p(1):p(1)+p(3)-1,:));
%template = imresize(template, sizeTemp);
originalTemplate = template;
sizeTemp = size(originalTemplate);
template=double(template);
origin = [p(1), p(2)];


pastBlocks = templateToBlockSet(originalTemplate, blockSize, shift, blocksHigh, blocksWide);

newTemp = blocksToTemp(pastBlocks, blocksHigh, blocksWide, blockSize, shift);

positiveSamples(1).image = originalTemplate;
R = originalTemplate(:,:,1);
G = originalTemplate(:,:,2);
B = originalTemplate(:,:,3);
R = fliplr(R);
G = fliplr(G);
B = fliplr(B);
reverseTemp(:,:,1) = R;
reverseTemp(:,:,2) = G;
reverseTemp(:,:,3) = B;
positiveSamples(2).image = reverseTemp;

%% Collect Initial Samples
%N negative samples and 1 positive sample
[svm_mod posFeatures negSamples negFeatures] = CollectSamples(im0, originalTemplate, positiveSamples(2).image, origin, N, blockSize, 1);

%% Train All Blocks
%[blockModel, posBlockFeat, negBlockFeat] = trainAllBlocksInit(positiveSamples, negSamples, blockSize, shift);

%% Set up Origins
[hp wp zp]=size(template);
radius=round(max([hp,wp])/2)+80;
actualOrigin = origin;
close all;

%% Loop
for frame = st_im+1:NumberOfFrames
    retrainBlocks = false;
    
    im = imread(sprintf([filePath fileName '%04d.jpg'], frame));
    
    previousOrigins(frame, :) = actualOrigin;
    
    if(loopCounter>predictFrame)
        changeX = previousOrigins(loopCounter, 1)-previousOrigins(loopCounter-1, 1);
        changeY = previousOrigins(loopCounter, 2)-previousOrigins(loopCounter-1, 2);
        if(changeX<=0)
            changeX=changeX-5;
        else
            changeX=changeX+5;
        end
        if(changeY<=0)
            changeY=changeY-5;
        else
            changeY=changeY+5;
        end
        if(abs(changeX)<speedlimit || abs(changeY)<speedlimit)
            pX = previousOrigins(loopCounter, 1)+changeX;
            pY = previousOrigins(loopCounter, 2)+changeY;
        end
    end
    
    detY = actualOrigin(2)-radius+35;
    detX = actualOrigin(1)-radius+35;

    % search area for the detector
    if threshCount == 0
        %check = [detY+radius*2+sizeTemp(1), detX+radius*2+sizeTemp(2)];
        check = [detY+radius*2+floor(sizeTemp(1)/2), detX+radius*2+floor(sizeTemp(2)/2)];
    else
        detY = detY - radius*threshCount;
        detX = detX - radius*threshCount;
        check = [detY+radius*(2+2*threshCount)+floor(sizeTemp(1)/2), detX+radius*(2+2*threshCount)+floor(sizeTemp(2)/2)];
    end
    if(check(1)>height)
        check(1) = height;
    end
    if(check(2)>width)
        check(2) = width;
    end
    if detX < 1
        detX = 1;
    end
    if detY < 1
        detY = 1;
    end
    detectSearchImg=(im(detY:check(1), detX:check(2),:));
    detectSearchArea=[detX,detY,check(2)-detX,check(1)-detY];

    %Score Maps - find top detection in neighborhood
    [score location] = scoreMap(im, detectSearchArea, detectSearchImg, originalTemplate, svm_mod, blockSize, frame);

    %Find Confidence of the detector
    conf = max(max(score));
    
    if loopCounter==1
        threshold = conf;
    else
        threshold = mean(pastConf);
    end
    
    %Find new origin
    origin = [location(2), location(1)];
    actualOrigin = [origin(1)+detX, origin(2)+detY];

    %Find new template for the classifier
    original_cur_temp = im(actualOrigin(2):actualOrigin(2)+sizeTemp(1), actualOrigin(1):actualOrigin(1)+sizeTemp(2), :);
    
    %Guang's blockSVM stuff
    feaTest = GenerateFeatures(original_cur_temp, blockSize, frame);
    feaPos = posFeatures;
    feaNeg = negFeatures;
    NumBlocks = numBlocks;
    NumFeatures = size(feaPos, 2);
    svm_model = svm_mod;
    NumPos = size(feaPos, 1);
    NumNeg = size(feaNeg, 1);
    block=blockSVM(feaTest,feaPos,feaNeg,NumBlocks,NumFeatures,svm_model,NumPos,NumNeg);
    
    if(mod(high, shift) == 0)
        blocksHigh = floor(high/shift)-2;
    else
        blocksHigh = floor(high/shift)-2;
    end
    if(mod(wide, shift) == 0)
        blocksWide = floor(wide/shift)-2;
    else
        blocksWide = floor(wide/shift)-2;
    end
    map = reshape(block',blocksWide,blocksHigh)';  % Change it as yours!!

%     finalMap = map;
%     finalMap(find(map>blockThresh))=0;
%     finalMap(find(finalMap~=0))=1;
%     map = finalMap;
    
    %Add current template to posSamples
    positiveSamples(loopCounter).image = original_cur_temp;
    pastBlocks = collectPastBlocks(pastBlocks, map, original_cur_temp, blocksWide, blocksHigh, blockSize, shift, blockThresh);
    

    pastConf(loopCounter) = conf;
    pastMap(loopCounter).map = map;

    %If the confidence is high or first few frames retrain classifier
    %NOTE: this assumes the detector works for the first assumption frames
    if(threshold+threshRange> conf > threshold-threshRange || frame <= detectorAssumption || retrainBlocks)
        [svm_mod posFeatures negSamples positiveSamples negFeatures] = retrainClassifier(im, original_cur_temp, svm_mod, N, actualOrigin, posFeatures, positiveSamples, blockSize, frame);
        threshCount = 0;
    else
        %actualOrigin = [pX, pY];
        threshCount = threshCount+1;
        %Testing Theory Number 1: Blended Template
        pastNum = size(positiveSamples, 2);
        blendTemplate = combinePastPresentTemp(pastBlocks, original_cur_temp, map, blockThresh, shift, blockSize);
        %THEN WE WANT TO RETRAIN CLASSIFIER AGAIN
        [svm_mod posFeatures negSamples positiveSamples negFeatures] = retrainClassifier(im, blendTemplate, svm_mod, N, actualOrigin, posFeatures, positiveSamples, blockSize, frame);
        posPred = [pX, pY, sizeTemp(2), sizeTemp(1)];
    end
    %End Retrain Classifier
    
    %% drawing
    hold off;
    figure(1);
    imshow(im);
    hold on;
    
    %Find actual Position
    pos2 = [actualOrigin(1), actualOrigin(2), sizeTemp(2), sizeTemp(1)];

    disp(conf);
    disp('confidence');  
    
    %plot(pos(find(pos(1:frame,1)),1), pos(find(pos(1:frame,2)),2),'Color','g','LineWidth',2);
    
    %Display classifier box
    if((conf<threshold+threshRange && conf > threshold-threshRange) || frame <= detectorAssumption)
        rectangle('Position', pos2, 'EdgeColor', 'g', 'LineWidth', 2);
    else
        if exist('posPred', 'var')
            rectangle('Position', posPred, 'EdgeColor', 'y', 'LineWidth', 2);
        end
        DisplayBlocks(map,blockSize,original_cur_temp,shift,actualOrigin, blockThresh);
    end
    rectangle('Position', detectSearchArea, 'EdgeColor', 'b', 'LineWidth', 2);

    %DISPLAY BLOCKS WAS HERE. I MOVED IT ABOVE. LET'S SEE WHAT HAPPENS!
    
    drawnow;
    disp(num2str(frame));
    toc
    
    saveas(figure(1), sprintf('Res_4/im_%04d.jpg', frame));
    loopCounter=loopCounter+1;
end


