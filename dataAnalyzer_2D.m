function dataCell = dataAnalyzer_2D(inputImage,scale)
%dataAnalyzer_2D:输入图像，分析角果各方面数据
%inputImage:可以输入单例图像或图像细胞行向量
%scale:像素和真实长度的比例，单位：毫米/像素
%outputImage:数据细胞数组，每个细胞内含一个数据结构
%version:1.2.5
%author:jinsuguangze
%data:5/8/2018
    
    %入口检测模块
    dataCell={};%初始化输出
    if iscell(inputImage) && isrow(inputImage)%将单例图和转换为细胞数组处理表
        handleList=inputImage;
    elseif ismatrix(inputImage)
        handleList{1}=inputImage;
    else
        disp('输入类型错误！');
        return;
    end
    num=size(handleList,2);%处理列表的个数
    
    p=inputParser;%构造入口检测对象
    p.addRequired('scale',@(x)validateattributes(x,{'numeric'},...
        {'real','finite','scalar','positive'},'dataAnalyzer_2D','scale',2));
    p.parse(scale);
    scale=p.Results.scale;
    
    for i=1:num
        validateattributes(handleList{i},{'numeric'},{'3d','nonnegative'},'autoFixing');%入口检测
        handleList{i}=im2double(handleList{i});%将图像双精度化
        [row,~,~]=size(handleList{i});%获取图像尺寸的行数
        outerLeft=[];%初始化左外层点
        outerRight=[];%初始化右外层点
        skeleton=[];%初始化骨架点坐标
        lengthLeft=0;%初始化左边缘长度
        lengthMid=0;%初始化骨架长度
        lengthRight=0;%初始化右边缘长度
        
        %分析像素模块
        for j=1:row%每行迭代
            rowIndex=find(handleList{i}(j,:,:)<1);%获取一行上的所有角果像素的标号数组
            if ~isempty(rowIndex)%如果该行存在像素
                outerLeft=[outerLeft;j,rowIndex(1)];%存储最左值
                outerRight=[outerRight;j,rowIndex(end)];%存储最右值
                diameter(j,1)=rowIndex(end)-rowIndex(1)+1;%直径（像素）
                skeleton=[skeleton;j,rowIndex(1)+floor(diameter(j)/2)];%存储骨架点，向下取整防止只有一个点的情况 
                if j>1
                    %更新左右边缘与骨架长度（像素）
                    lengthLeft=lengthLeft+pdist([outerLeft(end,1),outerLeft(end,2);...
                        outerLeft(end-1,1),outerLeft(end-1,2)]);
                    lengthMid=lengthMid+pdist([skeleton(end,1),skeleton(end,2);...
                        skeleton(end-1,1),skeleton(end-1,2)]);
                    lengthRight=lengthRight+pdist([outerRight(end,1),outerRight(end,2);...
                        outerRight(end-1,1),outerRight(end-1,2)]);
                end
            else
                diameter(j,1)=0;%没有满足的像素直径置零
            end
        end
        
        dataCell{i}.outerLeft=outerLeft;%存储左外层点坐标的字段
        dataCell{i}.outerRight=outerRight;%存储右外层点坐标的字段    
        dataCell{i}.skeleton=skeleton;%存储骨架点坐标字段
        dataCell{i}.diameter=diameter*scale;%存储直径字段
        dataCell{i}.advDiameter=mean(diameter(floor(row/3):ceil(row*2/3)))*scale;%存储平均核心直径
        dataCell{i}.lengthLeft=lengthLeft*scale;%存储左边缘长度字段
        dataCell{i}.lengthMid=lengthMid*scale;%存储骨架长度字段
        dataCell{i}.lengthRight=lengthRight*scale;%存储右边缘长度字段
        dataCell{i}.area=sum(diameter*scale^2);%存储面积字段
        dataCell{i}.fruitCountExp=floor(lengthLeft*scale/5)+floor(lengthRight*scale/5)+2;%存储用经验法估算籽的数目
        
        %曲线拟合模块
        options = fitoptions('Method','Smooth','SmoothingParam',0.001);%预设选项
        [xLeft,yLeft]=prepareCurveData(skeleton(:,1),skeleton(:,2)-outerLeft(:,2));%对输入进行重塑
        [xRight,yRight]=prepareCurveData(skeleton(:,1),outerRight(:,2)-skeleton(:,2));
        funcLeft = fit(xLeft,yLeft,'smooth',options);%曲线拟合
        funcRight = fit(xRight,yRight,'smooth',options);
        [derifuncLeft1,derifuncLeft2]=differentiate(funcLeft,skeleton(:,1));%得到导数和二阶导数
        [derifuncRight1,derifuncRight2]=differentiate(funcRight,skeleton(:,1));
        
        extremeLeft=[];%初始化左曲线极值点数组
        meanLeft=0;%初始化左极大值平均间隔
        if ~(isempty(derifuncLeft1) || isempty(derifuncLeft2))%确保导函数值不为空
            for j=1:size(skeleton,1)%寻找所有极值点
                if ~derifuncLeft1(j) && derifuncLeft2(j)<0%一阶导为0，二阶导为负
                    extremeLeft=[extremeLeft;skeleton(j,1)];%存储至极大值列表
                elseif j>1 && derifuncLeft1(j-1)>0 && derifuncLeft1(j)<0%一阶导两离散点有零点，且为极大值
                    extremeLeft=[extremeLeft;abs(derifuncLeft1(j-1)/(derifuncLeft1(j)-derifuncLeft1(j-1)))*...
                        (skeleton(j,1)-skeleton(j-1,1))+skeleton(j-1,1)];%线性比例放缩
                end
            end
            
            for j=2:size(extremeLeft,1)%创建极大值的间隔数组
                diffLeft(j-1)=extremeLeft(j)-extremeLeft(j-1);
            end
            meanLeft=mean(diffLeft);%求数组平均值
        end
        
        extremeRight=[];%初始化右曲线极值点数组
        meanRight=0;%初始化右极大值平均间隔
        if ~(isempty(derifuncRight1) || isempty(derifuncRight2))%确保导函数值不为空
            for j=1:size(skeleton,1)%寻找所有极值点
                if ~derifuncRight1(j) && derifuncRight2(j)<0%一阶导为0，二阶导为负
                    extremeRight=[extremeRight;skeleton(j,1)];%存储至极大值列表
                elseif j>1 && derifuncRight1(j-1)>0 && derifuncRight1(j)<0%一阶导两离散点有零点，且为极大值
                    extremeRight=[extremeRight;abs(derifuncRight1(j-1)/(derifuncRight1(j)-derifuncRight1(j-1)))*...
                        (skeleton(j,1)-skeleton(j-1,1))+skeleton(j-1,1)];%线性比例放缩
                end
            end

            for j=2:size(extremeRight,1)%创建极大值的间隔数组
                diffRight(j-1)=extremeRight(j)-extremeRight(j-1);
            end            
            meanRight=mean(diffRight);%求数组平均值
        end
        
        if meanLeft && meanRight%如果两者都无异常
            dataCell{i}.fruitCountGap=floor(lengthLeft/meanLeft)+...%存储用极值间隔法估算籽的数目
                floor(lengthRight/meanRight)+2;
        elseif ~meanLeft && meanRight%如果左值缺失，则使用右值数据
            dataCell{i}.fruitCountGap=floor(lengthLeft/meanRight)+...%存储用极值间隔法估算籽的数目
                floor(lengthRight/meanRight)+2;     
        elseif meanLeft && ~meanRight%如果右值缺失，则使用左值数据
            dataCell{i}.fruitCountGap=floor(lengthLeft/meanLeft)+...%存储用极值间隔法估算籽的数目
                floor(lengthRight/meanLeft)+2;                 
        else%如果都没有有效数值，则置0
            dataCell{i}.fruitCountGap=0;%存储用极值间隔法估算籽的数目
        end
    end
    
    %分析体积模块
    for i=1:num%提取平均直径
        advArray(i)=dataCell{i}.advDiameter;
    end
 
    %√法一：大津法，适合正面角果和侧面角果数量相差较近时使用
    advArray=(advArray-min(advArray))/(max(advArray)-min(advArray));
    thresh=graythresh(advArray);

    %法二：梯度下降法，适合角果比较扁平均匀时使用
%     sortArray=sort(advArray);
%     tempMax=0;
%     for i=2:size(sortArray,2)
%         temp=sortArray(i)-sortArray(i-1);
%         if tempMax<temp
%             tempMax=temp;
%             thresh=(sortArray(i)+sortArray(i-1))/2;
%         end
%     end

    %法三：经验法，角果参数参差不齐差异性太大时使用
%    thresh=10*pi*scale;

    %法四：概率法，适合工厂大数量检测时使用
%    advArray=(advArray-min(advArray))/(max(advArray)-min(advArray));
%    thresh=0.5;
    
    mod=0.75;%畸变系数
    for i=1:num%计算体积
        volume=0;%初始化体积
        if advArray(i)<thresh%小于阈值的当做侧面处理
            for j=1:row
                radius=dataCell{i}.diameter(j)/2;
                volume=volume+(1+sqrt(2)/2)*mod*scale*pi*radius^2;%椭圆面积
            end
        else%大于阈值的当做正面处理
            for j=1:row
                radius=dataCell{i}.diameter(j)/2;
                volume=volume+(2-sqrt(2))/mod*scale*pi*radius^2;%椭圆面积
            end
        end
        dataCell{i}.volume=volume;%存储体积字段
    end
end

