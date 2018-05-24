f=imread('C:/Users/阿坤/Desktop/image2.jpg');
outputImage=regionFilter(f,'Canny',2000,50);
im=autoReducing(outputImage);
oop=imbinarize(rgb2gray(im{1}),'adaptive','Sensitivity',0.58,'ForegroundPolarity','dark');
im1=imclose(oop,strel('disk',25));
imshow(im1);

%-----------------------------------------------
f=imread('C:/Users/阿坤/Desktop/image4.jpg');
%outputImage=regionFilter(f,'Canny',2000,50);
im=autoReducing(f);
oop=imbinarize(rgb2gray(im{1}),'adaptive','Sensitivity',0.599,'ForegroundPolarity','dark');
im1=imclose(oop,strel('disk',20));
imshow(im1);

