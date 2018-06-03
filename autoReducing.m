function outputImage = autoReducing(inputImage)
%autoReducing:�Զ�����ͼ���С�����ڸպ÷���ͼ��
%inputImage:�������뵥��ͼ���ͼ��ϸ��������
%outputImage:�Զ��������ͼ��ϸ������
%version:1.0.9
%author:jinshuguangze
%data:5/7/2018

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
        while true%ѭ��ֱ������Ҫ��
            [row,col,~]=size(handleList{i});%���¼��㳤�ȺͿ��
            if handleList{i}(1,:,:)==1
                handleList{i}(1,:,:)=[];
            elseif handleList{i}(row,:,:)==1
                handleList{i}(row,:,:)=[];
            elseif handleList{i}(:,1,:)==1
                handleList{i}(:,1,:)=[];
            elseif handleList{i}(:,col,:)==1
                handleList{i}(:,col,:)=[];
            else
                break;
            end
        end
    end
    
    outputImage=handleList;%���
end

