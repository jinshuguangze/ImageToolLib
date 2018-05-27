function outputImage = autoCutting(inputImage)
%autoCutting:用于自动切割左右额外边缘以获得信息密度更大的图像
%inputImage:输入图像，可以是RGB图像或者灰度图像
%outputImage:输出图像，经过剪切
%version:1.1.5
%author:jinshuguangze
%data:4/9/2018

    p=inputParser;%构造检测器对象
    p.addRequired('inputImage',@(x)validateattributes(x,{'numeric'},...
        {'3d','integer' ,'nonnegative'},'autoCutting','inputImage',1));
    p.parse(inputImage);
    inputImage=p.Results.inputImage;
    
    %利用霍夫变换找出合适线段
    if ndims(inputImage)==3%若是RGB图像，则灰度化
        grayImage=rgb2gray(inputImage);
    else
        grayImage=inputImage;
    end
    edgeImage=edge(grayImage,'Log');%可加参数
    [Hough,Theta,Rho]=hough(edgeImage,'RhoResolution',1,'Theta',-45:0.1:45);
    Points=houghpeaks(Hough,10,'Threshold',0.5*max(Hough(:)));%'NHoodSize':Default
    Lines=houghlines(edgeImage,Theta,Rho,Points,'FillGap',20,'MinLength',40);
    
    %初始化
    maxLeft=0;
    minRight=size(inputImage,2);
    midpointX=minRight/2;      

    %找出两个合适切割点
    for temp=1:length(Lines)
        xLeft=0;%默认线段在右侧
        x1=Lines(temp).point1(1);
        x2=Lines(temp).point2(1);       

        if((midpointX-x1)*(midpointX-x2)<=0)%判断线段两端点是否在中线同一侧
            continue;%不在同一侧，此线段跳过
        else
            if(midpointX-x1>0)
                xLeft=1;%线段在左侧
            end
        end   
                    
        if(xLeft)%找出更接近中线的切割点
            if(maxLeft<max(x1,x2))
                maxLeft=max(x1,x2);
            end
         else
            if(minRight>min(x1,x2))
                minRight=min(x1,x2);
            end
        end
    end
    
    %图像切割
    outputImage=imcrop(inputImage,[maxLeft,0,minRight-maxLeft,size(inputImage,1)]);
end

