function DisplayBlocks(map, blockSize, template, shift, origin, threshold)
figure(2);
imshow(template);
hold on;
sizeTemp = size(template);
height = sizeTemp(1);
width = sizeTemp(2);
i=1;
j=1;
addX = origin(1);
addY = origin(2);

for j=1:size(map, 1)
    for i=1:size(map, 2)
        if map(j,i)>threshold
            x=(i-1)*shift+1;
            y=(j-1)*shift+1;
            pos = [x+addX, y+addY, blockSize, blockSize];
            rectangle('Position', pos, 'EdgeColor', 'r', 'LineWidth', 1);
        end
    end
end
drawnow;
hold off;
