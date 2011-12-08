close all;clear;clc;

%% File Path
filePath = '/home/emily/Desktop/PETS2001/';
fileName = 'im';
fileSave = 'Res_p16/';

%% Parameters
speedlimit=40;
N = 100; %Number of negative samples
threshold = 2.50;
st_im = 131;
MAXSEARCH = [150, 150];
NumberOfFrames =200;
threshCount = 0;
detectorAssumption = st_im+8;
blockSize = 16;
shift = floor(blockSize/2);
predictFrame = 2;
sizeThresh = 25;
retrainBlocks = false;
TempSize = [96 48];
blockThresh = 0.00;
lowThresh = 0.50;
predPos = [];
loopCounter=1;
bbColor = 'g';
models = [];
confCounter = 1;

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
resizedTemplate = imresize(originalTemplate, TempSize);

positiveSamples(1).image = originalTemplate;


%% Collect Initial Samples
%N negative samples and 1 positive sample
[svm_mod posFeatures negSamples negFeatures blockHighWide] = CollectSamples(im0, originalTemplate, origin, N, blockSize, TempSize);
blocksHigh = blockHighWide(1);
blocksWide = blockHighWide(2);
numBlocks = blocksHigh*blocksWide;

pastBlocks = templateToBlockSet(originalTemplate, blockSize, shift, blocksHigh, blocksWide, TempSize);
newTemp = blocksToTemp(pastBlocks, blocksHigh, blocksWide, blockSize, shift);

%% Set up Origins
[hp wp zp]=size(template);
radius=round(max([hp,wp])/3);
actualOrigin = origin;
close all;

%% Loop
for frame = st_im+1:st_im+NumberOfFrames
    
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
    %if(detectSearchArea(3) > MAXSEARCH(1))
    %    detectSearchArea(3) = MAXSEARCH(1);
    %end
    %if(detectSearchArea(4) > MAXSEARCH(2))
     %   detectSearchArea(4) = MAXSEARCH(2);
    %end
    
    %WEIGHT MAP
    if(loopCounter ==1)
        sampFeature = GenerateFeatures(resizedTemplate, blockSize);
        NumFeatures = size(sampFeature,2);
        NumBlocks = numBlocks;
        Weight=getBlockWeight(NumBlocks,NumFeatures,svm_mod);
        Weight = full(Weight);
        weightMap = reshape(Weight(:), blocksWide, blocksHigh)';

        bb = findRectangles(weightMap);
        bb = findActualRect(bb, shift);
        pastBB{1} = bb;
        models = trainLatentSVM(bb,blockSize,positiveSamples,negSamples, TempSize);
    end

    %Score Maps - find top detection in neighborhood
    [score location] = newScoreMap(predPos, threshCount, detectSearchImg, originalTemplate, svm_mod, blockSize, TempSize, models, bb);
    
    pastScore{loopCounter} = score;
    
    %Find Confidence of the detector
    conf = max(max(score));
    
    %Find new origin
    origin = [location(2), location(1)];
    actualOrigin = [origin(1)+detX, origin(2)+detY];

    %Find new template for the classifier
    original_cur_temp = im(actualOrigin(2):actualOrigin(2)+sizeTemp(1)-1, actualOrigin(1):actualOrigin(1)+sizeTemp(2)-1, :);
    resizedTemplate = imresize(original_cur_temp, TempSize);   
    
    %CONF MAP FOR BLENDED TEMPLATE
    %Guang's blockSVM stuff
    feaTest = GenerateFeatures(resizedTemplate, blockSize);
    feaPos = posFeatures;
    feaNeg = negFeatures;
    NumBlocks = numBlocks;
    NumFeatures = size(feaPos, 2);
    svm_model = svm_mod;
    NumPos = size(feaPos, 1);
    NumNeg = size(feaNeg, 1);
    block=blockSVM(feaTest,feaPos,feaNeg,NumBlocks,NumFeatures,svm_model,NumPos,NumNeg);

    map = reshape(block',blocksWide,blocksHigh)';  % Change it as yours!!
    
    pastBlocks = collectPastBlocks(pastBlocks, map, resizedTemplate, blocksWide, blocksHigh, blockSize, shift, blockThresh, TempSize);
    %END
    
    pastConf(loopCounter) = conf;
    pastWeights(loopCounter).map = weightMap;

    %If the confidence is high or first few frames retrain classifier
    %NOTE: this assumes the detector works for the first assumption frames
    if(conf > threshold || frame <= detectorAssumption)
        clear posFeat newPosFeat;
        bbColor = 'g';
        threshCount = 0;
        if(mod(loopCounter-1, 5) == 0)
            [svm_mod posFeatures negSamples positiveSamples negFeatures] = retrainClassifier(im, original_cur_temp, svm_mod, N, actualOrigin, posFeatures, positiveSamples, blockSize, TempSize, bb, models);
        else
            num = size(positiveSamples, 2);
            posSamples(num+1).image = resizedTemplate;
            newPosFeat = GenerateFeatures(resizedTemplate, blockSize);
            posFeatures = [posFeatures; newPosFeat];
            svm_model = SVMClassification(posFeatures, negFeatures);
            disp('no new negative samples');
        end
        bb = retrainLatentSVM(bb, models, original_cur_temp, TempSize, blockSize, shift);
        pastBB{confCounter+1} = bb;
        confCounter= confCounter+1;
        models = retrainLatSVM(bb,blockSize,positiveSamples,negSamples, TempSize, pastBB);
    elseif(conf>lowThresh)
        bbColor = 'c';
        %threshCount = 0;
        threshCount = threshCount+1;
        %Testing Theory: Blended Template
        blendTemplate = combinePastPresentTemp(pastBlocks, resizedTemplate, map, blockThresh, shift, blockSize);
        if(mod(loopCounter-1, 5) == 0)
            [svm_mod posFeatures negSamples positiveSamples negFeatures] = retrainClassifier(im, blendTemplate, svm_mod, N, actualOrigin, posFeatures, positiveSamples, blockSize, TempSize, bb, models);
        else
            num = size(positiveSamples, 2);
            posSamples(num+1).image = resizedTemplate;
            newPosFeat = GenerateFeatures(resizedTemplate, blockSize);
            posFeatures = [posFeatures; newPosFeat];
            svm_model = SVMClassification(posFeatures, negFeatures);
            disp('no new negative samples');
        end
        bb = retrainLatentSVM(bb, models, blendTemplate, TempSize, blockSize, shift);
        pastBB{confCounter+1} = bb;
        confCounter= confCounter+1;
        models = retrainLatSVM(bb,blockSize,positiveSamples,negSamples, TempSize, pastBB);
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

    %DisplayBlocks(map,blockSize,resizedTemplate,shift,actualOrigin, blockThresh);
    
    drawnow;
    disp(num2str(frame));
    OLDORIGINS(loopCounter,:) = pos2;
    saveas(figure(1), sprintf([fileSave 'im_%04d.jpg'], frame));
    loopCounter=loopCounter+1;
    clear negFeat posFeat;
end

dlmwrite('Latent16.txt', OLDORIGINS);


