for i=1:205
    im = imread(sprintf('Res_p2im_%04d.jpg', i));
    figure(1);
    imshow(im);
    saveas(figure(1),sprintf('Res_p2/im_%04d.jpg',i));
end