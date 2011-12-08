function out = calculateCost(detectorPos, predPos, ttSVM, threshCount, detectorFeature)
   % Compute similarity between two objects.
   % The similarity is a combination of different terms

   thre_dist=50+10*threshCount;   % increase the distance threshold if target is lost.   tt.miss---#frames target is lost

  % Obtain the absolute distance between detection and prediction
   dist0 = sqrt((detectorPos(2)-predPos(2)).^2+(detectorPos(1)-predPos(1)).^2);

   % Check if the distance is valid
   %if dist0>thre_dist
   %    out=0;
   %    return;
   %end

   % distance score
   lambda=2000;
   dist = exp(-(dist0.^2)/lambda);    % The larger distance, the lower score

   % SVM score
   [~, ~, svmscore] = svmpredict(1, detectorFeature, ttSVM);

   if threshCount<3    % if the tracker is not lost or only lost for a very short term
       out = 0.7*svmscore + 0.3*dist;
   else  % if the tracker is lost for a long term
       out = svmscore;
   end
end