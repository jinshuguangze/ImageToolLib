for i=1:size(pureFruitDataCell,2)
    %预设选项
    options = fitoptions('Method','Smooth','SmoothingParam',0.001);
    %对输入进行重塑
    [xLeft,yLeft]=prepareCurveData(pureFruitDataCell{i}.outerLeft(:,1),...
        pureFruitDataCell{i}.outerLeft(:,2));
    [xRight,yRight]=prepareCurveData(pureFruitDataCell{i}.outerRight(:,1),...
        pureFruitDataCell{i}.outerRight(:,2));
    [xMid,yMid]=prepareCurveData(pureFruitDataCell{i}.skeleton(:,1),...
        pureFruitDataCell{i}.skeleton(:,2));
    %曲线拟合
    [funcLeft{i},gdnessLeft{i},outLeft{i}] = fit(xLeft,yLeft,'smooth',options);
    [funcRight{i},gdnessRight{i},outRight{i}] = fit(xRight,yRight,'smooth',options);
    [funcMid{i},gdnessMid{i},outMid{i}] = fit(xMid,yMid,'poly2');
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
        
        valueMax=[];%初始化极大值点集合
        valueMin=[];%初始化极小值点集合
        for j=1:size(extremeLeft,1)
            if extremeLeft(j,2)
                valueMax=[valueMax,abs(funcLeft{i}(j)-funcMid{i}(j))];%极大值
            else
                valueMin=[valueMin,abs(funcLeft{i}(j)-funcMid{i}(j))];%极小值
            end
        end
        advLeft(i)=mean(valueMax)-mean(valueMin);%计算两者平均值的差，如果没有极大值极小值，则为NaN
    end
    
    extremeRight=[];%初始化左曲线极值点数组
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
        
        valueMax=[];%初始化极大值点集合
        valueMin=[];%初始化极小值点集合
        for j=1:size(extremeRight,1)
            if extremeRight(j,2)
                valueMax=[valueMax,abs(funcRight{i}(j)-funcMid{i}(j))];%极大值
            else
                valueMin=[valueMin,abs(funcRight{i}(j)-funcMid{i}(j))];%极小值
            end
        end  
        advRight(i)=mean(valueMax)-mean(valueMin);%计算两者平均值的差，如果没有极大值极小值，则为NaN
    end
end

clear options;
clear xLeft;
clear yLeft;
clear xRight;
clear yRight;
clear xMid;
clear yMid;
clear funcLeft;
clear gdnessLeft;
clear outLeft;
clear funcRight;
clear gdnessRight;
clear outRight;
clear funcMid;
clear gdnessMid;
clear outMid;
clear derifuncLeft1;
clear derifuncLeft2;
clear derifuncRight1;
clear derifuncRight2;
clear extremeLeft;
clear extremeRight;
clear i;
clear j;
clear valueMax;
clear valueMin;