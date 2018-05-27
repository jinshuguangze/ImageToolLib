for i=1:size(pureFruitDataCell,2)
    %Ԥ��ѡ��
    options = fitoptions('Method','Smooth','SmoothingParam',0.001);
    %�������������
    [xLeft,yLeft]=prepareCurveData(pureFruitDataCell{i}.outerLeft(:,1),...
        pureFruitDataCell{i}.outerLeft(:,2));
    [xRight,yRight]=prepareCurveData(pureFruitDataCell{i}.outerRight(:,1),...
        pureFruitDataCell{i}.outerRight(:,2));
    %�������
    [funcLeft{i},gdnessLeft{i},outLeft{i}] = fit(xLeft,yLeft,'smooth',options);
    [funcRight{i},gdnessRight{i},outRight{i}] = fit(xRight,yRight,'smooth',options);
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
        if ~isempty(extremeLeft)
            estimateLeft=size(find(~extremeLeft(:,2)),1);%�ǹ������Ͳ��ѹ���ֵ
        else
            estimateLeft=0;
        end
        
        count=0;%��ʼ����Ч������
        adv{i}=0;%��ʼ����ನ��߶�ƽ��ֵ
        if size(extremeLeft,1)>1
            for j=2:(size(extremeLeft,1)-1)
                %��ֹ�ֶκ�������������ķǱ�Ҫ���
                if  extremeLeft(j-1,2)+extremeLeft(j,2)==1 && extremeLeft(j,2)+extremeLeft(j+1,2)==1
                    count=count+1;%��Ч�Բ��������
                    tempLeft=abs(funcLeft{i}(extremeLeft(j))-funcLeft{i}(extremeLeft(j-1)));%�󲨷�߶�
                    tempRight=abs(funcLeft{i}(extremeLeft(j))-funcLeft{i}(extremeLeft(j+1)));%�Ҳ���߶�
                    adv{i}=(adv{i}*(count-1)+min(tempLeft,tempRight))/count;%����ƽ��ֵ
                end
            end
        end
    end
    
    %�ұ�Ե���ߴ���
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
        if ~isempty(extremeRight)
            estimateRight=size(find(extremeRight(:,2)),1);%�ǹ������Ͳ��ѹ���ֵ
        else
            estimateRight=0;
        end
        
        if size(extremeRight,1)>1
            for j=2:(size(extremeRight,1)-1)
                %��ֹ�ֶκ�������������ķǱ�Ҫ���
                if  extremeRight(j-1,2)+extremeRight(j,2)==1 && extremeRight(j,2)+extremeRight(j+1,2)==1
                    count=count+1;%��Ч�Բ��������
                    tempLeft=abs(funcRight{i}(extremeRight(j))-funcRight{i}(extremeRight(j-1)));%�󲨷�߶�
                    tempRight=abs(funcRight{i}(extremeRight(j))-funcRight{i}(extremeRight(j+1)));%�Ҳ���߶�
                    adv{i}=(adv{i}*(count-1)+min(tempLeft,tempRight))/count;%����ƽ��ֵ
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