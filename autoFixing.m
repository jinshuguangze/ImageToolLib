function outputImage = autoFixing(inputImage)
%autoFixing:��ת�ǹ�ͼ���Դﵽ�̶�����ֱ�Ƕ�
%inputImage:�������뵥��ͼ���ͼ��ϸ��������
%outputImage:��ת���ͼ��ϸ������
%version:1.1.7
%author:jinshuguangze
%data:5/5/2018
    
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
        Start=[];%��ʼ����¼���
        End=[];%��ʼ����¼�յ�
        [row,col,~]=size(handleList{i});
        if row>=col%�ǹ�����״
            for j=1:ceil(row/2)
                if isempty(Start)%�����û����ʼ��
                    IndexStart=find(handleList{i}(j,:,:)<1);%Ѱ�����в�Ϊ�׵�����
                    if ~isempty(IndexStart)
                        Start=[j,floor((IndexStart(1)+IndexStart(end))/2)];%��ʼ��Ϊ�����е�
                    end
                end
                
                if isempty(End)%�����û����ĩ��
                    IndexEnd=find(handleList{i}(row-j+1,:,:)<1);%Ѱ�����в�Ϊ�׵�����
                    if ~isempty(IndexEnd)
                        End=[row-j+1,floor((IndexEnd(1)+IndexEnd(end))/2)];%��ĩ��Ϊ�����е�
                    end
                end
            end
        else%�ǹ��ʺ�״
            for j=1:ceil(col/2)
                if isempty(Start)%�����û����ʼ��
                    IndexStart=find(handleList{i}(:,j,:)<1);%Ѱ�����в�Ϊ�׵�����
                    if ~isempty(IndexStart)
                        Start=[floor((IndexStart(1)+IndexStart(end))/2),j];%��ʼ��Ϊ�����е�
                    end
                end
                
                if isempty(End)%�����û����ĩ��
                    IndexEnd=find(handleList{i}(:,row-j+1,:)<1);%Ѱ�����в�Ϊ�׵�����
                    if ~isempty(IndexEnd)
                        End=[floor((IndexEnd(1)+IndexEnd(end))/2),row-j+1];%��ĩ��Ϊ�����е�
                    end
                end
            end
        end
        
        if ~(isempty(Start) || isempty(End) || isequal(Start,End))%ͬʱ������ʼ����յ������߲���ͬһ����
            angle=atan((End(2)-Start(2))/(End(1)-Start(1)));%��ȡ��ת�Ƕ�
            tform=affine2d([cos(angle),sin(angle),0;-sin(angle),cos(angle),0;1,1,1]);%����2D�任����
            outputImage{i}=imwarp(handleList{i},tform,'nearest','FillValues',1);%��ת����������ֵ��ʹ�ð�ɫ���������
        end
    end
end

