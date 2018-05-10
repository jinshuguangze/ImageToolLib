function outputImage = autoFixing(inputImage)
%autoFixing:旋转角果图像以达到固定的竖直角度
%inputImage:可以输入单例图像或图像细胞行向量
%outputImage:旋转后的图像细胞数组
%version:1.1.4
%author:jinshuguangze
%data:5/5/2018
    
    outputImage={};%初始化输出
    if iscell(inputImage) && isrow(inputImage)%将单例图和转换为细胞数组处理表
        handleList=inputImage;
    elseif ismatrix(inputImage)
        handleList{1}=inputImage;
    else
        disp('输入类型错误！');
        return;
    end
    
    for i=1:size(handleList,2)
        validateattributes(handleList{i},{'numeric'},{'3d','nonnegative'},'autoFixing');%入口检测
        handleList{i}=im2double(handleList{i});%将图像双精度化
        Start=[];%初始化记录起点
        End=[];%初始化记录终点
        [row,col,~]=size(handleList{i});
        if row>=col%角果呈竖状
            for j=1:ceil(row/2)
                if isempty(Start)%如果还没有起始点
                    IndexStart=find(handleList{i}(j,:,:)<1);%寻找所有不为白的像素
                    if ~isempty(IndexStart)
                        Start=[j,floor((IndexStart(1)+IndexStart(end))/2)];%起始点为两端中点
                    end
                end
                
                if isempty(End)%如果还没有终末点
                    IndexEnd=find(handleList{i}(row-j+1,:,:)<1);%寻找所有不为白的像素
                    if ~isempty(IndexEnd)
                        End=[row-j+1,floor((IndexEnd(1)+IndexEnd(end))/2)];%终末点为两端中点
                    end
                end
            end
        else%角果呈横状
            for j=1:ceil(col/2)
                if isempty(Start)%如果还没有起始点
                    IndexStart=find(handleList{i}(:,j,:)<1);%寻找所有不为白的像素
                    if ~isempty(IndexStart)
                        Start=[floor((IndexStart(1)+IndexStart(end))/2),j];%起始点为两端中点
                    end
                end
                
                if isempty(End)%如果还没有终末点
                    IndexEnd=find(handleList{i}(:,row-j+1,:)<1);%寻找所有不为白的像素
                    if ~isempty(IndexEnd)
                        End=[floor((IndexEnd(1)+IndexEnd(end))/2),row-j+1];%终末点为两端中点
                    end
                end
            end
        end
        
        if ~(isempty(Start) || isempty(End) || isequal(Start,End))%同时存在起始点和终点且两者不是同一个点
            angle=atan((End(2)-Start(2))/(End(1)-Start(1)));%获取旋转角度
            tform=affine2d([cos(angle),sin(angle),0;-sin(angle),cos(angle),0;1,1,1]);%构造2D变换对象
            outputImage{i}=imwarp(handleList{i},tform,'nearest','FillValues',1);%旋转，最近邻域插值，使用白色来填充区域
        end
    end
end

