%Find Rectangles
%This function will, given a weight map, calculate the 6 highest weighted
%areas.
function bb = findRectangles(map)
width = size(map, 2);
height = size(map, 1);

sumMap = zeros(height,width, 3);
oldMax = 0;

for k=1:6
    for j=1:height
        for i=1:width
            if(j+3<=height && i+3<=width)
                map1 = map(j:j+3, i:i+3);
                sumMap(j,i,1) = sum(map1(:));
            end
            if(j+1<=height && i+7<=width)
                map2 = map(j:j+1, i:i+7);
                sumMap(j,i,2) = sum(map2(:));
            end
            if(j+7<=height && i+1<=width)
                map3 = map(j:j+7, i:i+1);
                sumMap(j,i,3) = sum(map3(:));
            end
            sumMaps = [sumMap(j,i,1) sumMap(j,i,2) sumMap(j,i,3) oldMax];
            newMax = max(sumMaps);
            oldMax = newMax;
            dimension = find(sumMaps == newMax);
            if(dimension ~= 4)
                oldDim = dimension;
                index = [j, i, oldDim];
            end
        end
    end
    if(index(3) == 1)
        bb(k).rect = [index(2), index(1), 4, 4];
        map(index(1):index(1)+3, index(2):index(2)+3) = 0;
    elseif(index(3) == 2)
        bb(k).rect = [index(2), index(1), 7, 2];
        map(index(1):index(1)+1, index(2):index(2)+7) = 0;
    else
        bb(k).rect = [index(2), index(1), 2, 7];
        map(index(1):index(1)+7, index(2):index(2)+1) = 0;
    end
    oldMax = 0;
end






