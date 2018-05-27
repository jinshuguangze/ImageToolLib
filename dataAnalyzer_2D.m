function dataCell = dataAnalyzer_2D(inputImage,scale)
%dataAnalyzer_2D:����ͼ�񣬷����ǹ�����������
%inputImage:�������뵥��ͼ���ͼ��ϸ��������
%scale:���غ���ʵ���ȵı�������λ������/����
%outputImage:����ϸ�����飬ÿ��ϸ���ں�һ�����ݽṹ
%version:1.2.5
%author:jinsuguangze
%data:5/8/2018
    
    %��ڼ��ģ��
    dataCell={};%��ʼ�����
    if iscell(inputImage) && isrow(inputImage)%������ͼ��ת��Ϊϸ�����鴦���
        handleList=inputImage;
    elseif ismatrix(inputImage)
        handleList{1}=inputImage;
    else
        disp('�������ʹ���');
        return;
    end
    num=size(handleList,2);%�����б�ĸ���
    
    p=inputParser;%������ڼ�����
    p.addRequired('scale',@(x)validateattributes(x,{'numeric'},...
        {'real','finite','scalar','positive'},'dataAnalyzer_2D','scale',2));
    p.parse(scale);
    scale=p.Results.scale;
    
    for i=1:num
        validateattributes(handleList{i},{'numeric'},{'3d','nonnegative'},'autoFixing');%��ڼ��
        handleList{i}=im2double(handleList{i});%��ͼ��˫���Ȼ�
        [row,~,~]=size(handleList{i});%��ȡͼ��ߴ������
        outerLeft=[];%��ʼ��������
        outerRight=[];%��ʼ��������
        skeleton=[];%��ʼ���Ǽܵ�����
        lengthLeft=0;%��ʼ�����Ե����
        lengthMid=0;%��ʼ���Ǽܳ���
        lengthRight=0;%��ʼ���ұ�Ե����
        
        %��������ģ��
        for j=1:row%ÿ�е���
            rowIndex=find(handleList{i}(j,:,:)<1);%��ȡһ���ϵ����нǹ����صı������
            if ~isempty(rowIndex)%������д�������
                outerLeft=[outerLeft;j,rowIndex(1)];%�洢����ֵ
                outerRight=[outerRight;j,rowIndex(end)];%�洢����ֵ
                diameter(j,1)=rowIndex(end)-rowIndex(1)+1;%ֱ�������أ�
                skeleton=[skeleton;j,rowIndex(1)+floor(diameter(j)/2)];%�洢�Ǽܵ㣬����ȡ����ֹֻ��һ�������� 
                if j>1
                    %�������ұ�Ե��Ǽܳ��ȣ����أ�
                    lengthLeft=lengthLeft+pdist([outerLeft(end,1),outerLeft(end,2);...
                        outerLeft(end-1,1),outerLeft(end-1,2)]);
                    lengthMid=lengthMid+pdist([skeleton(end,1),skeleton(end,2);...
                        skeleton(end-1,1),skeleton(end-1,2)]);
                    lengthRight=lengthRight+pdist([outerRight(end,1),outerRight(end,2);...
                        outerRight(end-1,1),outerRight(end-1,2)]);
                end
            else
                diameter(j,1)=0;%û�����������ֱ������
            end
        end
        
        dataCell{i}.outerLeft=outerLeft;%�洢������������ֶ�
        dataCell{i}.outerRight=outerRight;%�洢������������ֶ�    
        dataCell{i}.skeleton=skeleton;%�洢�Ǽܵ������ֶ�
        dataCell{i}.diameter=diameter*scale;%�洢ֱ���ֶ�
        dataCell{i}.advDiameter=mean(diameter(floor(row/3):ceil(row*2/3)))*scale;%�洢ƽ������ֱ��
        dataCell{i}.lengthLeft=lengthLeft*scale;%�洢���Ե�����ֶ�
        dataCell{i}.lengthMid=lengthMid*scale;%�洢�Ǽܳ����ֶ�
        dataCell{i}.lengthRight=lengthRight*scale;%�洢�ұ�Ե�����ֶ�
        dataCell{i}.area=sum(diameter*scale^2);%�洢����ֶ�
        dataCell{i}.fruitCountExp=floor(lengthLeft*scale/5)+floor(lengthRight*scale/5)+2;%�洢�þ��鷨�����ѵ���Ŀ
        
        %�������ģ��
        options = fitoptions('Method','Smooth','SmoothingParam',0.001);%Ԥ��ѡ��
        [xLeft,yLeft]=prepareCurveData(skeleton(:,1),skeleton(:,2)-outerLeft(:,2));%�������������
        [xRight,yRight]=prepareCurveData(skeleton(:,1),outerRight(:,2)-skeleton(:,2));
        funcLeft = fit(xLeft,yLeft,'smooth',options);%�������
        funcRight = fit(xRight,yRight,'smooth',options);
        [derifuncLeft1,derifuncLeft2]=differentiate(funcLeft,skeleton(:,1));%�õ������Ͷ��׵���
        [derifuncRight1,derifuncRight2]=differentiate(funcRight,skeleton(:,1));
        
        extremeLeft=[];%��ʼ�������߼�ֵ������
        meanLeft=0;%��ʼ���󼫴�ֵƽ�����
        if ~(isempty(derifuncLeft1) || isempty(derifuncLeft2))%ȷ��������ֵ��Ϊ��
            for j=1:size(skeleton,1)%Ѱ�����м�ֵ��
                if ~derifuncLeft1(j) && derifuncLeft2(j)<0%һ�׵�Ϊ0�����׵�Ϊ��
                    extremeLeft=[extremeLeft;skeleton(j,1)];%�洢������ֵ�б�
                elseif j>1 && derifuncLeft1(j-1)>0 && derifuncLeft1(j)<0%һ�׵�����ɢ������㣬��Ϊ����ֵ
                    extremeLeft=[extremeLeft;abs(derifuncLeft1(j-1)/(derifuncLeft1(j)-derifuncLeft1(j-1)))*...
                        (skeleton(j,1)-skeleton(j-1,1))+skeleton(j-1,1)];%���Ա�������
                end
            end
            
            for j=2:size(extremeLeft,1)%��������ֵ�ļ������
                diffLeft(j-1)=extremeLeft(j)-extremeLeft(j-1);
            end
            meanLeft=mean(diffLeft);%������ƽ��ֵ
        end
        
        extremeRight=[];%��ʼ�������߼�ֵ������
        meanRight=0;%��ʼ���Ҽ���ֵƽ�����
        if ~(isempty(derifuncRight1) || isempty(derifuncRight2))%ȷ��������ֵ��Ϊ��
            for j=1:size(skeleton,1)%Ѱ�����м�ֵ��
                if ~derifuncRight1(j) && derifuncRight2(j)<0%һ�׵�Ϊ0�����׵�Ϊ��
                    extremeRight=[extremeRight;skeleton(j,1)];%�洢������ֵ�б�
                elseif j>1 && derifuncRight1(j-1)>0 && derifuncRight1(j)<0%һ�׵�����ɢ������㣬��Ϊ����ֵ
                    extremeRight=[extremeRight;abs(derifuncRight1(j-1)/(derifuncRight1(j)-derifuncRight1(j-1)))*...
                        (skeleton(j,1)-skeleton(j-1,1))+skeleton(j-1,1)];%���Ա�������
                end
            end

            for j=2:size(extremeRight,1)%��������ֵ�ļ������
                diffRight(j-1)=extremeRight(j)-extremeRight(j-1);
            end            
            meanRight=mean(diffRight);%������ƽ��ֵ
        end
        
        if meanLeft && meanRight%������߶����쳣
            dataCell{i}.fruitCountGap=floor(lengthLeft/meanLeft)+...%�洢�ü�ֵ����������ѵ���Ŀ
                floor(lengthRight/meanRight)+2;
        elseif ~meanLeft && meanRight%�����ֵȱʧ����ʹ����ֵ����
            dataCell{i}.fruitCountGap=floor(lengthLeft/meanRight)+...%�洢�ü�ֵ����������ѵ���Ŀ
                floor(lengthRight/meanRight)+2;     
        elseif meanLeft && ~meanRight%�����ֵȱʧ����ʹ����ֵ����
            dataCell{i}.fruitCountGap=floor(lengthLeft/meanLeft)+...%�洢�ü�ֵ����������ѵ���Ŀ
                floor(lengthRight/meanLeft)+2;                 
        else%�����û����Ч��ֵ������0
            dataCell{i}.fruitCountGap=0;%�洢�ü�ֵ����������ѵ���Ŀ
        end
    end
    
    %�������ģ��
    for i=1:num%��ȡƽ��ֱ��
        advArray(i)=dataCell{i}.advDiameter;
    end
 
    %�̷�һ����򷨣��ʺ�����ǹ��Ͳ���ǹ��������Ͻ�ʱʹ��
    advArray=(advArray-min(advArray))/(max(advArray)-min(advArray));
    thresh=graythresh(advArray);

    %�������ݶ��½������ʺϽǹ��Ƚϱ�ƽ����ʱʹ��
%     sortArray=sort(advArray);
%     tempMax=0;
%     for i=2:size(sortArray,2)
%         temp=sortArray(i)-sortArray(i-1);
%         if tempMax<temp
%             tempMax=temp;
%             thresh=(sortArray(i)+sortArray(i-1))/2;
%         end
%     end

    %���������鷨���ǹ������β�������̫��ʱʹ��
%    thresh=10*pi*scale;

    %���ģ����ʷ����ʺϹ������������ʱʹ��
%    advArray=(advArray-min(advArray))/(max(advArray)-min(advArray));
%    thresh=0.5;
    
    mod=0.75;%����ϵ��
    for i=1:num%�������
        volume=0;%��ʼ�����
        if advArray(i)<thresh%С����ֵ�ĵ������洦��
            for j=1:row
                radius=dataCell{i}.diameter(j)/2;
                volume=volume+(1+sqrt(2)/2)*mod*scale*pi*radius^2;%��Բ���
            end
        else%������ֵ�ĵ������洦��
            for j=1:row
                radius=dataCell{i}.diameter(j)/2;
                volume=volume+(2-sqrt(2))/mod*scale*pi*radius^2;%��Բ���
            end
        end
        dataCell{i}.volume=volume;%�洢����ֶ�
    end
end

