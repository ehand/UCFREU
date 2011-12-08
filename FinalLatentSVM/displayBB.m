%This function will, given a template and bounding boxes, display the
%bounding boxes for the latent SVM
function displayBB(bb, temp)

figure(2);
imshow(temp);
hold on;

for i=1:size(bb,2)
    rectangle('Position', bb(i).rect, 'EdgeColor', 'c', 'LineWidth', 1);
end
drawnow;
hold off;
v=1;
