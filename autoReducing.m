function outputImage = autoReducing(inputImage)
%autoReducing:自动调整图像大小以致于刚好放下图像
%inputImage:可以输入单例图像或图像细胞行向量
%outputImage:自动调整后的图像细胞数组
%version:1.0.9
%author:jinshuguangze
%data:5/7/2018

    outputImage={};%初始化输出
    if iscell(inputImage) && isrow(inputImage)%将单例图和转换为细胞数组处理表
        handleList=inputImage;
    elseif (islogical(inputImage) || isnumeric(inputImage))...
            && (ismatrix(inputImage) || ndims(inputImage)==3)%正常的RGB/灰度/二值图像
        handleList{1}=inputImage;
    else
        disp('输入类型错误！');
        return;
    end

    for i=1:size(handleList,2)
        validateattributes(handleList{i},{'numeric'},{'3d','nonnegative'},'autoFixing');%入口检测
        handleList{i}=im2double(handleList{i});%将图像双精度化
        while true%循环直到满足要求
            [row,col,~]=size(handleList{i});%重新计算长度和宽度
            if handleList{i}(1,:,:)==1
                handleList{i}(1,:,:)=[];
            elseif handleList{i}(row,:,:)==1
                handleList{i}(row,:,:)=[];
            elseif handleList{i}(:,1,:)==1
                handleList{i}(:,1,:)=[];
            elseif handleList{i}(:,col,:)==1
                handleList{i}(:,col,:)=[];
            else
                break;
            end
        end
    end
    
    outputImage=handleList;%输出
end

