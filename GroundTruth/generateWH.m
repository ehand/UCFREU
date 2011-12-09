pathname = '../';
filename = 'im_0931.jpg';
im = imread([pathname filename]);
imshow(im);
h = imrect();
p = getPosition(h);