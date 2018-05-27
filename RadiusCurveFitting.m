for i=1:size(pureFruitDataCell,2)
    %Ԥ��ѡ��
    options = fitoptions('Method','Smooth','SmoothingParam',0.001);
    %�������������
    [xLeft,yLeft]=prepareCurveData(pureFruitDataCell{i}.outerLeft(:,1),...
        pureFruitDataCell{i}.outerLeft(:,2));
    [xRight,yRight]=prepareCurveData(pureFruitDataCell{i}.outerRight(:,1),...
        pureFruitDataCell{i}.outerRight(:,2));
    [xMid,yMid]=prepareCurveData(pureFruitDataCell{i}.skeleton(:,1),...
        pureFruitDataCell{i}.skeleton(:,2));
    %�������
    [funcLeft{i},gdnessLeft{i},outLeft{i}] = fit(xLeft,yLeft,'smooth',options);
    [funcRight{i},gdnessRight{i},outRight{i}] = fit(xRight,yRight,'smooth',options);
    [funcMid{i},gdnessMid{i},outMid{i}] = fit(xMid,yMid,'poly2');
    %�õ������Ͷ��׵���
    [derifuncLeft1{i},derifuncLeft2{i}]=differentiate(funcLeft{i},pureFruitDataCell{i}.outerLeft(:,1));
    [derifuncRight1{i},derifuncRight2{i}]=differentiate(funcRight{i},pureFruitDataCell{i}.outerRight(:,1));
    
    %���Ե���ߴ���
    extremeLeft=[];%��ʼ�������߼�ֵ������
    if ~(isempty(derifuncLeft1) || isempty(derifuncLeft2))%ȷ��������ֵ��Ϊ��
        for j=1:size(derifuncLeft1{i},1)%Ѱ�����м�ֵ��
            if ~abs(derifuncLeft2{i}(j))<1e-6%�ų���Ч��ֵ��
                if ~derifuncLeft1{i}(j)%���ֱֵ��Ϊ0
                    %�洢��ֵ������꣬�ڶ����м�СֵΪ0������ֵΪ1
                    extremeLeft=[extremeLeft;pureFruitDataCell{i}.outerLeft(j,1),derifuncLeft2{i}(j)<0];
                elseif j>1 && derifuncLeft1{i}(j-1)*derifuncLeft1{i}(j)<0%������߷����෴
                    %�洢��ֵ������꣬�ڶ����м�СֵΪ0������ֵΪ1
                    extremeLeft=[extremeLeft;abs(derifuncLeft1{i}(j-1)/(derifuncLeft1{i}(j)-derifuncLeft1{i}(j-1)))*...
                        (pureFruitDataCell{i}.outerLeft(j,1)-pureFruitDataCell{i}.outerLeft(j-1,1))+...
                        pureFruitDataCell{i}.outerLeft(j-1,1),derifuncLeft2{i}(j)<0];
                end
            end
        end
        
        valueMax=[];%��ʼ������ֵ�㼯��
        valueMin=[];%��ʼ����Сֵ�㼯��
        for j=1:size(extremeLeft,1)
            if extremeLeft(j,2)
                valueMax=[valueMax,abs(funcLeft{i}(j)-funcMid{i}(j))];%����ֵ
            else
                valueMin=[valueMin,abs(funcLeft{i}(j)-funcMid{i}(j))];%��Сֵ
            end
        end
        advLeft(i)=mean(valueMax)-mean(valueMin);%��������ƽ��ֵ�Ĳ���û�м���ֵ��Сֵ����ΪNaN
    end
    
    extremeRight=[];%��ʼ�������߼�ֵ������
    if ~(isempty(derifuncRight1) || isempty(derifuncRight2))%ȷ��������ֵ��Ϊ��
        for j=1:size(derifuncRight1{i},1)%Ѱ�����м�ֵ��
            if ~abs(derifuncRight2{i}(j))<1e-6%�ų���Ч��ֵ��
                if ~derifuncRight1{i}(j)%���ֱֵ��Ϊ0
                    %�洢��ֵ������꣬�ڶ����м�СֵΪ0������ֵΪ1
                    extremeRight=[extremeRight;pureFruitDataCell{i}.outerRight(j,1),derifuncRight2{i}(j)<0];
                elseif j>1 && derifuncRight1{i}(j-1)*derifuncRight1{i}(j)<0%������߷����෴
                    %�洢��ֵ������꣬�ڶ����м�СֵΪ0������ֵΪ1
                    extremeRight=[extremeRight;abs(derifuncRight1{i}(j-1)/(derifuncRight1{i}(j)-derifuncRight1{i}(j-1)))*...
                        (pureFruitDataCell{i}.outerRight(j,1)-pureFruitDataCell{i}.outerRight(j-1,1))+...
                        pureFruitDataCell{i}.outerRight(j-1,1),derifuncRight2{i}(j)<0];
                end
            end
        end
        
        valueMax=[];%��ʼ������ֵ�㼯��
        valueMin=[];%��ʼ����Сֵ�㼯��
        for j=1:size(extremeRight,1)
            if extremeRight(j,2)
                valueMax=[valueMax,abs(funcRight{i}(j)-funcMid{i}(j))];%����ֵ
            else
                valueMin=[valueMin,abs(funcRight{i}(j)-funcMid{i}(j))];%��Сֵ
            end
        end  
        advRight(i)=mean(valueMax)-mean(valueMin);%��������ƽ��ֵ�Ĳ���û�м���ֵ��Сֵ����ΪNaN
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