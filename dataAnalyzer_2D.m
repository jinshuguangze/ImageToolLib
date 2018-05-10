function dataCell = dataAnalyzer_2D(inputImage,scale)
%dataAnalyzer_2D:输入图像，分析角果各方面数据
%inputImage:可以输入单例图像或图像细胞行向量
%scale:像素和真实长度的比例，单位：毫米/像素
%outputImage:数据细胞数组，每个细胞内含一个数据结构
%version:1.0.9
%author:jinsuguangze
%data:5/8/2018
    
    dataCell={};%初始化输出
    if iscell(inputImage) && isrow(inputImage)%将单例图和转换为细胞数组处理表
        handleList=inputImage;
    elseif ismatrix(inputImage)
        handleList{1}=inputImage;
    else
        disp('输入类型错误！');
        return;
    end
    
    p=inputParser;%构造入口检测对象
    p.addRequired('scale',@(x)validateattributes(x,{'numeric'},...
        {'real','finite','scalar','positive'},'dataAnalyzer_2D','scale',2));
    p.parse(scale);
    scale=p.Results.scale;
    
    for i=1:size(handleList,2)
        validateattributes(handleList{i},{'numeric'},{'3d','nonnegative'},'autoFixing');%入口检测
        handleList{i}=im2double(handleList{i});%将图像双精度化
        [row,~,~]=size(handleList{i});%获取图像尺寸的行数
        outerLeft=[];%初始化左外层点
        outerRight=[];%初始化右外层点
        skeleton=[];%初始化骨架点坐标
        length=0;%初始化骨架长度
        volume=0;%初始化体积
        
        for j=1:row%每行迭代
            rowIndex=find(handleList{i}(j,:,:)<1);%获取一行上的所有角果像素的标号数组
            if ~isempty(rowIndex)%如果该行存在像素
                outerLeft=[outerLeft;j,rowIndex(1)];%存储最左值
                outerRight=[outerRight;j,rowIndex(end)];%存储最右值
                diameter(j,1)=rowIndex(end)-rowIndex(1)+1;%直径（像素）,有跳过的会默认为0
                skeleton=[skeleton;j,rowIndex(1)+floor(diameter(j)/2)];%存储骨架点，向下取整防止只有一个点的情况 
                if j>1
                    %更新骨架长度（毫米）
                    length=length+pdist([skeleton(end,1),skeleton(end,2);skeleton(end-1,1),skeleton(end-1,2)])*scale;
                end        
                volume=volume+pi/4*diameter(j)^2*scale^3;%体积（毫米）
            end
        end
        
        dataCell{i}.outerLeft=outerLeft;%存储左外层点坐标的字段
        dataCell{i}.outerRight=outerRight;%存储右外层点坐标的字段
        dataCell{i}.diameter=diameter*scale;%存储直径字段
        dataCell{i}.skeleton=skeleton;%存储骨架点坐标字段
        dataCell{i}.length=length;%存储骨架长度字段
        dataCell{i}.area=sum(diameter*scale^2);%存储面积字段
        dataCell{i}.volume=volume;%存储体积字段
    end
end

