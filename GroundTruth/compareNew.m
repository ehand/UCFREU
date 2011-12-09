%Compare ground truth and tracking values
TOTALS = [61, 205,119,400,400,98,100,200,200,146,500,200,200,146,124,200,200,250,205,168];
for j=1:1
personNum = j;
if(j~=5)
GT = importdata(['person' num2str(personNum) '.txt']);
TD = importdata(['BlendedTemplate_1/Person' num2str(personNum) '.txt']);
total = TOTALS(j);
%TOLERANCE = 25;
cnt = 0;
width = TD(1,3);
height = TD(1,4);
for i=1:total
    X = abs(GT(i,1)-TD(i,1));
    Y = abs(GT(i,2)-TD(i,2));
    overlap = (X-width)*(Y-height);
    if(X>width || Y>height)
        overlap = 0;
    end
    overall = overlap + 2*X + 2*Y;
    OVERLAP(i) = double(overlap)/double(overall);
    disp(double(overlap)/double(overall));
    if(double(overlap)/double(overall)>0.7)
            cnt = cnt+1;
    end
end
for i=62:400
    OVERLAP(i) = 0;
end

percent(j) = 100*double(cnt)/double(total);
end
end