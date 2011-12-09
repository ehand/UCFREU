function DisplayBlocks(map, blockSize, template, shift, origin, threshold, frame)

% sizeTemp = size(template);
% height = sizeTemp(1);
% width = sizeTemp(2);
% i=1;
% j=1;
% addX = origin(1);
% addY = origin(2);
% 
% for j=1:size(map, 1)
%     for i=1:size(map, 2)
%         if map(j,i)>threshold
%             x=(i-1)*shift+1;
%             y=(j-1)*shift+1;
%             pos = [x+addX, y+addY, blockSize, blockSize];
%             rectangle('Position', pos, 'EdgeColor', 'r', 'LineWidth', 1);
%         end
%     end
% end
%

% display = imagesc(map);
% display = imresize(display, [size(template,1), size(template,2)]);
% figure(2);imshow(display);
mapBig = imresize(map, [size(template,1), size(template,2)]);
figure(2);image(mapBig*100);
saveas(figure(2),sprintf('Res_5/map%04d.jpg', frame));