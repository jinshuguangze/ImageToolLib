I=imread('C:/Users/阿坤/Desktop/image4.jpg');
J1=regionFilter(I,'Canny',2000,50);
J2=colorFilter(I,[220,255;180,240;80,120]/255,strel('disk',30),strel('disk',10));
K=imbinarize(J1(:,:,1),'adaptive','Sensitivity',0.599,'ForegroundPolarity','dark');
inputImage=imclose(K,strel('disk',20));
inputImage=autoReducing(inputImage);
fruitCell=regionExpanding_Binary(inputImage,50,'method','Canny','operator','Low');
num=size(fruitCell,1);