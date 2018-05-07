function outputImage = autoFixing(inputImage)
%autoFixing:旋转角果图像以达到固定的竖直角度
%inputImage:可以输入单例图像或图像细胞数组
%outputImage:旋转后的图像细胞数组
%version:1.0.6
%author:jinshuguangze
%data:5/5/2018
    
    outputImage={};%初始化输出
    if iscell(inputImage)%将单例图和转换为细胞数组处理表
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
        Start=0;%初始化记录起点
        End=0;%初始化记录终点
        [row,col,~]=size(handleList{i});
        if row>=col%角果呈竖状
            for j=1:col/2
                if ~Start%判断是否已经有了起始点
                    if handleList{i}(1,j,:)~=1%优先权，左点大于右点
                        Start=[1,j];
                    elseif handleList{i}(1,col-j+1,:)~=1
                        Start=[1,col-j+1];
                    end
                end
                
                if ~End%判断是否已经有了终末点
                    if handleList{i}(row,j,:)~=1%优先权，左点大于左点
                        End=[row,j];
                    elseif handleList{i}(row,col-j+1,:)~=1
                        End=[row,col-j+1];
                    end
                end
            end
        else%角果呈横状
            for j=1:row/2
                if ~Start%判断是否已经有了起始点
                    if handleList{i}(j,1,:)~=1%优先权，上点大于下点
                        Start=[j,1];
                    elseif handleList{i}(row-j+1,1,:)~=1
                        Start=[row-j+1,1];
                    end
                end
                
                if ~End%判断是否已经有了终末点
                    if handleList{i}(j,row,:)~=1%优先权，上点大于下点
                        End=col-j+1;
                    elseif handleList{i}(row-j+1,col,:)~=1
                        End=[row-j+1,col];
                    end
                end
            end
        end
        
        angle=atan((End(2)-Start(2))/(End(1)-Start(1)));%获取旋转角度
        tform=affine2d([cos(angle),sin(angle),0;-sin(angle),cos(angle),0;1,1,1]);%构造2D变换对象
        outputImage{i}=imwarp(handleList{i},tform,'nearest','FillValues',1);%旋转，最近邻域插值，使用白色来填充区域
    end
end

