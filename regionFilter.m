function outputImage = regionFilter(inputImage,method,length,varargin)
%regionFilter:对输入图像进行基于实现了解选定物体尺寸的区域过滤
%inputImage:输入图像，可以为RGB，灰度和二值图像
%method:识别边缘的方法，能使用‘Sobel’，‘Prewitt’，‘Roberts’，‘Log’，‘Zerocross’，’Canny‘，’Approxcanny‘这七种方法
%length:感兴趣物体的估计长度，这决定了该横向长度以下的物体会被极大地过滤掉
%width:感兴趣物体的估计宽度，这决定了该纵向长度以下的物体会被极大地过滤掉，如果不输入，则数值默认和长度相等
%outputImage:处理后输出的图像，与输入图像类型一致
%version:1.0.5
%author:jinshuguangze
%data:5/22/2018

    p=inputParser;%构造入口检查对象
    p.addRequired('inputImage',@(x)validateattributes(x,{'numeric'},...
        {'3d','real','nonnegative'},'regionFilter','inputImage',1));
    p.addRequired('method',@(x)any(validatestring(x,...
        {'Sobel','Prewitt','Roberts','Log','Zerocross','Canny','Approxcanny'},'regionFilter','method',2)));
    p.addRequired('length',@(x)validateattributes(x,{'numeric'},...
        {'scalar','integer','positive'},'regionFilter','length',3));    
    p.addOptional('width',0,@(x)validateattributes(x,{'numeric'},...
        {'scalar','integer','positive'},'regionFilter','width',4));
    p.parse(inputImage,method,length,varargin{:});
    inputImage=p.Results.inputImage;
    method=p.Results.method;
    length=p.Results.length;
    width=p.Results.width;
    
    if ndims(inputImage)==3%如果输入图像是RGB图像，则转成灰度图像
        handleImage=rgb2gray(inputImage);
    else
        handleImage=inputImage;
    end
    
    if ~width%如果宽度无输入，则数值与长度相等
        width=length;
    end
    
    edgeImage=edge(handleImage,method);%对图像进行边缘检测
    closeImage=imclose(imclose(edgeImage,strel('line',width,0)),strel('line',length,90));%对图像进行两方向上的线模板闭合
    openImage=imopen(closeImage,strel('square',min(length,width)));%对图像进行开操作，过滤柄端和杂质
    %两图像取并得到输出图像
    
    row=size(openImage,1);%图像的行数
    col=size(openImage,2);%图像的列数
    inputImage=im2double(inputImage);%双精度化
    outputImage=ones(row,col,3);%构造空白背景的输出图像
    for i=1:row
        for j=1:col
            if openImage(i,j)
                outputImage(i,j,:)=inputImage(i,j,:);%填充
            end
        end
    end         
end