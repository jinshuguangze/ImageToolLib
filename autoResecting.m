function outputImage = autoResecting(inputImage)
%autoResecting:ȥ���ǹ��ı���ĩ�˵���Ч����
%inputImage:�������뵥��ͼ���ͼ��ϸ��������
%outputImage:ȥ�����ʺ��ͼ��ϸ������
%version:1.2.0
%author:jinshuguangze
%data:5/6/2018
    
    outputImage={};%��ʼ�����
    if iscell(inputImage) && isrow(inputImage)%������ͼ��ת��Ϊϸ�����鴦���
        handleList=inputImage;
    elseif (islogical(inputImage) || isnumeric(inputImage))...
            && (ismatrix(inputImage) || ndims(inputImage)==3)%������RGB/�Ҷ�/��ֵͼ��
        handleList{1}=inputImage;
    else
        disp('�������ʹ���');
        return;
    end
    
    for i=1:size(handleList,2)
        validateattributes(handleList{i},{'numeric'},{'3d','nonnegative'},'autoFixing');%��ڼ��
        handleList{i}=im2double(handleList{i});%��ͼ��˫���Ȼ�
        [row,col,~]=size(handleList{i});
        if row>=col%�ǹ�����״
            count=zeros(1,row);%��ʼ��������
            for j=1:row%����ÿ�е����ظ���
                for k=1:col
                    if handleList{i}(j,k,:)~=1
                        count(j)=count(j)+1;
                    end
                end
            end
            
            count=count/max(count);%�����һ��
            level=graythresh(count);%���ô�򷽷��ҳ������ֵ
            signTop=find(count>=level,1,'first');%�ҳ�������һ��������ֵ�����
            signBottom=find(count>=level,1,'last');%�ҳ��ײ���һ��������ֵ�����
            if ~isempty(signTop)%��ͷ����1
                handleList{i}(1:signTop-1,:,:)=1;
            end
            if ~isempty(signBottom)%��β����1
                handleList{i}(signBottom+1:end,:,:)=1;
            end
            
        else%�ǹ��ʺ�״
            count=zeros(1,col);%��ʼ��������
            for j=1:col%����ÿ�е����ظ���
                for k=1:row
                    if handleList{i}(k,j,:)~=1
                        count(j)=count(j)+1;
                    end
                end
            end
            
            count=count/max(count);%�����һ��
            level=graythresh(count);%���ô�򷽷��ҳ������ֵ
            signLeft=find(count>=level,1,'first');%�ҳ�������һ��������ֵ�����
            signRight=find(count>=level,1,'last');%�ҳ��ײ���һ��������ֵ�����
            if ~isempty(signLeft)%��ͷ����1
                handleList{i}(:,1:signLeft-1,:)=1;
            end
            if ~isempty(signRight)%��β����1
                handleList{i}(:,signRight+1:end,:)=1;
            end
        end
    end
    
    outputImage=handleList;%���
end