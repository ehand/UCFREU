close all;clear;clc;

%% File Path
filePath = '/home/emily/Desktop/ewap_dataset/seq_eth/Seq/';
fileName = 'im';

%% Parameters
speedlimit=40;
N = 100; %Number of negative samples
threshold = 0.40;
st_im = 930;
NumberOfFrames = st_im+168;
threshCount = 0;
detectorAssumption = st_im+8;
blockSize = 16;
shift = floor(blockSize/2);
predictFrame = 2;
sizeThresh = 25;
retrainBlocks = false;
sizeTemp = [128 64];
blockThresh = 0.00;
lowThresh = 0.10;
predPos = [];
loopCounter=1;
bbColor = 'g';

%% Initiation of the 1st frame
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

template=(im0(p(2):p(2)+p(4)-1,p(1):p(1)+p(3)-1,:));
%template = imresize(template, sizeTemp);
originalTemplate = template;
sizeTemp = size(originalTemplate);
template=double(template);
origin = [p(1), p(2)];

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
[svm_mod posFeatures negSamples negFeatures blockHighWide] = CollectSamples(im0, originalTemplate, positiveSamples(2).image, origin, N, blockSize, 1);
blocksHigh = blockHighWide(1);
blocksWide = blockHighWide(2);
numBlocks = blocksHigh*blocksWide;

pastBlocks = templateToBlockSet(originalTemplate, blockSize, shift, blocksHigh, blocksWide);
newTemp = blocksToTemp(pastBlocks, blocksHigh, blocksWide, blockSize, shift);

%% Set up Origins
[hp wp zp]=size(template);
radius=round(max([hp,wp])/2);
actualOrigin = origin;
close all;

%% Loop
for frame = st_im+1:NumberOfFrames
    retrainBlocks = false;
    usePred = false;
    
    im = imread(sprintf([filePath fileName '%04d.jpg'], frame));
    
    previousOrigins(loopCounter, :) = actualOrigin;
    
    if(loopCounter>predictFrame)
        changeX = double(previousOrigins(loopCounter, 1))-double(previousOrigins(loopCounter-1, 1));
        changeY = double(previousOrigins(loopCounter, 2))-double(previousOrigins(loopCounter-1, 2));
        
        if(abs(changeX)<speedlimit || abs(changeY)<speedlimit)
            pX = double(previousOrigins(loopCounter, 1))+changeX;
            pY = double(previousOrigins(loopCounter, 2))+changeY;
            predPos = [pY, pX];
        end
    end
    
    detY = actualOrigin(2)-radius;
    detX = actualOrigin(1)-radius;

    % search area for the detector
    if threshCount == 0
        check = [detY+radius*2+sizeTemp(1), detX+radius*2+sizeTemp(2)];
    else
        detY = detY - radius*threshCount/2;
        detX = detX - radius*threshCount/2;
        check = [detY+radius*(2+2*threshCount)/2+sizeTemp(1), detX+radius*(2+2*threshCount)/2+sizeTemp(2)];
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
    [score location] = scoreMap(predPos, threshCount, detectSearchImg, originalTemplate, svm_mod, blockSize, frame);

    %Find Confidence of the detector
    conf = max(max(score));
    
    %Find new origin
    origin = [location(2), location(1)];
    actualOrigin = [origin(1)+detX, origin(2)+detY];

    %Find new template for the classifier
    original_cur_temp = im(actualOrigin(2):actualOrigin(2)+sizeTemp(1)-1, actualOrigin(1):actualOrigin(1)+sizeTemp(2)-1, :);
    
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

    map = reshape(block',blocksWide,blocksHigh)';  % Change it as yours!!
    
    %Add current template to posSamples
    numPosSamples = size(positiveSamples,2);
    positiveSamples(numPosSamples+1).image = original_cur_temp;
    pastBlocks = collectPastBlocks(pastBlocks, map, original_cur_temp, blocksWide, blocksHigh, blockSize, shift, blockThresh);

    pastConf(loopCounter) = conf;
    pastMap(loopCounter).map = map;

    %If the confidence is high or first few frames retrain classifier
    %NOTE: this assumes the detector works for the first assumption frames
    if(conf > threshold || frame <= detectorAssumption)
        clear posFeat newPosFeat;
        [svm_mod posFeatures negSamples positiveSamples negFeatures] = retrainClassifier(im, original_cur_temp, svm_mod, N, actualOrigin, posFeatures, positiveSamples, blockSize, frame);
        bbColor = 'g';
        threshCount = 0;
    elseif(conf>lowThresh)
        bbColor = 'c';
        threshCount = threshCount+1;
        %Testing Theory: Blended Template
        pastNum = size(positiveSamples, 2);
        blendTemplate = combinePastPresentTemp(pastBlocks, original_cur_temp, map, blockThresh, shift, blockSize);
        %THEN WE WANT TO RETRAIN CLASSIFIER AGAIN
        clear posFeat newPosFeat;
        [svm_mod posFeatures negSamples positiveSamples negFeatures] = retrainClassifier(im, blendTemplate, svm_mod, N, actualOrigin, posFeatures, positiveSamples, blockSize, frame);
    else
        bbColor = 'm';
        actualOrigin = [pX, pY];
        
        threshCount = threshCount+1;
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
    rectangle('Position', pos2, 'EdgeColor', bbColor, 'LineWidth', 2);
    rectangle('Position', detectSearchArea, 'EdgeColor', 'b', 'LineWidth', 2);

    %DisplayBlocks(map,blockSize,original_cur_temp,shift,actualOrigin, blockThresh, frame);
    
    drawnow;
    disp(num2str(frame));
    
    saveas(figure(1), sprintf('Res_20/im_%04d.jpg', frame));
    OLDORIGINS(loopCounter, :) = actualOrigin;
    loopCounter=loopCounter+1;
    
    clear negFeat posFeat;
end

dlmwrite('LBP20.txt', OLDORIGINS);



