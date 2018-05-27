function outputImage = autoResecting(inputImage)
%autoResecting:ȥ���ǹ��ı���ĩ�˵���Ч����
%inputImage:�������뵥��ͼ���ͼ��ϸ��������
%outputImage:ȥ�����ʺ��ͼ��ϸ������
%version:1.1.0
%author:jinshuguangze
%data:5/6/2018
    
    outputImage={};%��ʼ�����
    if iscell(inputImage) && isrow(inputImage)%������ͼ��ת��Ϊϸ�����鴦���
        handleList=inputImage;
    elseif islogical(inputImage) && isnumeric(inputImage)...
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
            sign=find(count<level);%�ҳ���������ֵ������
            
            for j=1:size(sign,2)%����������ֵ��ȫ����1
                handleList{i}(sign(j),:,:)=1;
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
            sign=find(count<level);%�ҳ���������ֵ������
            
            for j=1:size(sign,2)%����������ֵ��ȫ����1
                handleList{i}(:,sign(j),:)=1;
            end
        end
    end
    
    outputImage=handleList;%���
end