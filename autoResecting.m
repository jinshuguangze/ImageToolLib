function outputImage = autoResecting(inputImage)
%autoResecting:去除角果的柄和末端等无效物质
%inputImage:可以输入单例图像或图像细胞行向量
%outputImage:去除物质后的图像细胞数组
%version:1.2.0
%author:jinshuguangze
%data:5/6/2018
    
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
        [row,col,~]=size(handleList{i});
        if row>=col%角果呈竖状
            count=zeros(1,row);%初始化计数器
            for j=1:row%计算每行的像素个数
                for k=1:col
                    if handleList{i}(j,k,:)~=1
                        count(j)=count(j)+1;
                    end
                end
            end
            
            count=count/max(count);%数组归一化
            level=graythresh(count);%利用大津方法找出最大阈值
            signTop=find(count>=level,1,'first');%找出顶部第一个满足阈值的序号
            signBottom=find(count>=level,1,'last');%找出底部第一个满足阈值的序号
            if ~isempty(signTop)%将头部置1
                handleList{i}(1:signTop-1,:,:)=1;
            end
            if ~isempty(signBottom)%将尾部置1
                handleList{i}(signBottom+1:end,:,:)=1;
            end
            
        else%角果呈横状
            count=zeros(1,col);%初始化计数器
            for j=1:col%计算每列的像素个数
                for k=1:row
                    if handleList{i}(k,j,:)~=1
                        count(j)=count(j)+1;
                    end
                end
            end
            
            count=count/max(count);%数组归一化
            level=graythresh(count);%利用大津方法找出最大阈值
            signLeft=find(count>=level,1,'first');%找出顶部第一个满足阈值的序号
            signRight=find(count>=level,1,'last');%找出底部第一个满足阈值的序号
            if ~isempty(signLeft)%将头部置1
                handleList{i}(:,1:signLeft-1,:)=1;
            end
            if ~isempty(signRight)%将尾部置1
                handleList{i}(:,signRight+1:end,:)=1;
            end
        end
    end
    
    outputImage=handleList;%输出
end