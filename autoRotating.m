function outputImage = autoRotating(inputImage)
%autoRotating:用于自动将图像旋转至长度大于高度
%inputImage:输入图像，可以为任意类型图像
%outputImage:输出图像，与输入图像类型一致
%versin:1.0.2
%author:jinshuguangze
%data:4/9/2018

    %默认不旋转
    outputImage=inputImage;
    
    %入口判断，判断是否为数组型数组
    if(~isnumeric(inputImage))
        disp('请输入图像！');
        return;
    end
    
    %旋转条件判断
    if(size(inputImage,1)>size(inputImage,2))
        outputImage=imrotate(inputImage,90,'nearest','loose');
    end
end

