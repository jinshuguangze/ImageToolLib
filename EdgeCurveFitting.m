for i=1:size(pureFruitDataCell,2)
    %预设选项
    options = fitoptions('Method','Smooth','SmoothingParam',0.001);
    %对输入进行重塑
    [xLeft,yLeft]=prepareCurveData(pureFruitDataCell{i}.outerLeft(:,1),...
        pureFruitDataCell{i}.outerLeft(:,2));
    [xRight,yRight]=prepareCurveData(pureFruitDataCell{i}.outerRight(:,1),...
        pureFruitDataCell{i}.outerRight(:,2));
    %曲线拟合
    [funcLeft{i},gdnessLeft{i},outLeft{i}] = fit(xLeft,yLeft,'smooth',options);
    [funcRight{i},gdnessRight{i},outRight{i}] = fit(xRight,yRight,'smooth',options);
    %得到导数和二阶导数
    [derifuncLeft1{i},derifuncLeft2{i}]=differentiate(funcLeft{i},pureFruitDataCell{i}.outerLeft(:,1));
    [derifuncRight1{i},derifuncRight2{i}]=differentiate(funcRight{i},pureFruitDataCell{i}.outerRight(:,1));
    
    %左边缘曲线处理
    extremeLeft=[];%初始化左曲线极值点数组
    if ~(isempty(derifuncLeft1) || isempty(derifuncLeft2))%确保导函数值不为空
        for j=1:size(derifuncLeft1{i},1)%寻找所有极值点
            if ~abs(derifuncLeft2{i}(j))<1e-6%排除无效极值点
                if ~derifuncLeft1{i}(j)%如果值直接为0
                    %存储极值点横坐标，第二列中极小值为0，极大值为1
                    extremeLeft=[extremeLeft;pureFruitDataCell{i}.outerLeft(j,1),derifuncLeft2{i}(j)<0];
                elseif j>1 && derifuncLeft1{i}(j-1)*derifuncLeft1{i}(j)<0%如果两者符号相反
                    %存储极值点横坐标，第二列中极小值为0，极大值为1
                    extremeLeft=[extremeLeft;abs(derifuncLeft1{i}(j-1)/(derifuncLeft1{i}(j)-derifuncLeft1{i}(j-1)))*...
                        (pureFruitDataCell{i}.outerLeft(j,1)-pureFruitDataCell{i}.outerLeft(j-1,1))+...
                        pureFruitDataCell{i}.outerLeft(j-1,1),derifuncLeft2{i}(j)<0];
                end
            end
        end
        if ~isempty(extremeLeft)
            estimateLeft=size(find(~extremeLeft(:,2)),1);%角果左半边油菜籽估计值
        else
            estimateLeft=0;
        end
        
        count=0;%初始化有效波峰数
        adv{i}=0;%初始化左侧波峰高度平均值
        if size(extremeLeft,1)>1
            for j=2:(size(extremeLeft,1)-1)
                %防止分段函数等特殊情况的非必要检测
                if  extremeLeft(j-1,2)+extremeLeft(j,2)==1 && extremeLeft(j,2)+extremeLeft(j+1,2)==1
                    count=count+1;%有效性波峰检测计数
                    tempLeft=abs(funcLeft{i}(extremeLeft(j))-funcLeft{i}(extremeLeft(j-1)));%左波峰高度
                    tempRight=abs(funcLeft{i}(extremeLeft(j))-funcLeft{i}(extremeLeft(j+1)));%右波峰高度
                    adv{i}=(adv{i}*(count-1)+min(tempLeft,tempRight))/count;%计算平均值
                end
            end
        end
    end
    
    %右边缘曲线处理
    extremeRight=[];%初始化右曲线极值点数组
    if ~(isempty(derifuncRight1) || isempty(derifuncRight2))%确保导函数值不为空
        for j=1:size(derifuncRight1{i},1)%寻找所有极值点
            if ~abs(derifuncRight2{i}(j))<1e-6%排除无效极值点
                if ~derifuncRight1{i}(j)%如果值直接为0
                    %存储极值点横坐标，第二列中极小值为0，极大值为1
                    extremeRight=[extremeRight;pureFruitDataCell{i}.outerRight(j,1),derifuncRight2{i}(j)<0];
                elseif j>1 && derifuncRight1{i}(j-1)*derifuncRight1{i}(j)<0%如果两者符号相反
                    %存储极值点横坐标，第二列中极小值为0，极大值为1
                    extremeRight=[extremeRight;abs(derifuncRight1{i}(j-1)/(derifuncRight1{i}(j)-derifuncRight1{i}(j-1)))*...
                        (pureFruitDataCell{i}.outerRight(j,1)-pureFruitDataCell{i}.outerRight(j-1,1))+...
                        pureFruitDataCell{i}.outerRight(j-1,1),derifuncRight2{i}(j)<0];
                end
            end
        end
        if ~isempty(extremeRight)
            estimateRight=size(find(extremeRight(:,2)),1);%角果左半边油菜籽估计值
        else
            estimateRight=0;
        end
        
        if size(extremeRight,1)>1
            for j=2:(size(extremeRight,1)-1)
                %防止分段函数等特殊情况的非必要检测
                if  extremeRight(j-1,2)+extremeRight(j,2)==1 && extremeRight(j,2)+extremeRight(j+1,2)==1
                    count=count+1;%有效性波峰检测计数
                    tempLeft=abs(funcRight{i}(extremeRight(j))-funcRight{i}(extremeRight(j-1)));%左波峰高度
                    tempRight=abs(funcRight{i}(extremeRight(j))-funcRight{i}(extremeRight(j+1)));%右波峰高度
                    adv{i}=(adv{i}*(count-1)+min(tempLeft,tempRight))/count;%计算平均值
                end
            end
        end
    end
    
    estimated(i)=estimateLeft+estimateRight;
end

clear i;
clear j;
clear tempLeft;
clear tempRight;
clear count;
clear extremeLeft;
clear extremeRight;
clear xLeft;
clear xRight;
clear yLeft;
clear yRight;
clear funcLeft;
clear gdnessLeft;
clear outLeft;
clear funcRight;
clear gdnessRight;
clear outRight;
clear options;
clear estimateLeft;
clear estimateRight;
clear derifuncLeft1;
clear derifuncLeft2;
clear derifuncRight1;
clear derifuncRight2;