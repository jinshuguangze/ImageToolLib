function outputImage = autoFixing(inputImage)
%autoFixing:旋转角果图像以达到固定的角度
%inputImage:可以输入单例图像或图像细胞数组
%version:1.0.0
%author:jinshuguangze
%data:5/5/2018

    p=inputParser;%构造入口检测对象
    p.addRequired('inputImage',@(x)validateattributes({'cell','numeric'},...
        {'row'},'autoFixing','inputImage',1));
    p.parse(inputImage);
    inputImage=p.Results.inputImage;
    
    if ~iscell(inputImage)%将单例图和转换为细胞数组处理表
        handleList{1}=inputImage;
    else
        handleList=inputImage;
    end
    
    for i=1:size(handleList,2)
        validateattributes(handleList{i},{'numeric'},{'3d','nonnegative'},'autoFixing');%入口检测
        Start=0;%初始化记录起点
        End=0;%初始化记录终点
        [row,col,~]=size(handleList{i});
        if row>=col%角果呈竖状
            for j=1:col/2
                if ~Start%判断是否已经有了起始点
                    if handleList{i}(1,j)%优先权，左点大于右点
                        Start=[1,j];
                    elseif handleList{i}(1,col-j+1)
                        Start=[1,col-j+1];
                    end
                end
                
                if ~End%判断是否已经有了终末点
                    if handleList{i}(row,j)%优先权，左点大于左点
                        End=[row,j];
                    elseif handleList{i}(row,col-j+1)
                        End=[row,col-j+1];
                    end
                end
            end
        else%角果呈横状
            for j=1:row/2
                if ~Start%判断是否已经有了起始点
                    if handleList{i}(j,1)%优先权，上点大于下点
                        Start=[j,1];
                    elseif handleList{i}(row-j+1,1)
                        Start=[row-j+1,1];
                    end
                end
                
                if ~End%判断是否已经有了终末点
                    if handleList{i}(j,row)%优先权，上点大于下点
                        End=col-j+1;
                    elseif handleList{i}(row-j+1,col)
                        End=[row-j+1,col];
                    end
                end
            end
        end
        
        angle=arctan((End(1)-Start(1))/(End(2)-Start(2)));%获取旋转角度
        outputImage{i}=imrotate(handleList{i},angle,'bicubic','loose');%旋转
    end
end

