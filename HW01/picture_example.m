%% An example for testing functions for image proessing;
clear;
close;

%% read a picture and convert it to infomration bits;
imageFilename              =  'face2.jpg';
imagRGB                    =  imread(imageFilename);
imagGrey                   =  rgb2gray(imagRGB);
[rows,cols]                =  size(imagGrey);

%% display;
figure(100)
subplot(1,2,1);
imshow(imagRGB);
title('Original');
subplot(1,2,2);
imshow(imagGrey);
title('Grey');



