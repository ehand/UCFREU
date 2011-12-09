%Compare ground truth and tracking values
GT = importdata('/home/emily/Desktop/GroundTruth/person4.txt');
TD = importdata('/home/emily/Desktop/GroundTruth/Person4.txt');
total = 400;
cnt = 0;
TOLERANCE = 25;
for i=1:total
    if(TD(i,1)<GT(i+1,1)+TOLERANCE && TD(i,1)>GT(i+1,1)-TOLERANCE)
        if(TD(i,2)<GT(i+1,2)+TOLERANCE && TD(i,2)>GT(i+1,2)-TOLERANCE)
            cnt = cnt+1;
        end
    end
end

percent = double(cnt)/double(total);