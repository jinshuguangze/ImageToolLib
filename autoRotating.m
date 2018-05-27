function outputImage = autoRotating(inputImage)
%autoRotating:�����Զ���ͼ����ת�����ȴ��ڸ߶�
%inputImage:����ͼ�񣬿���Ϊ��������ͼ��
%outputImage:���ͼ��������ͼ������һ��
%version:1.0.4
%author:jinshuguangze
%data:4/9/2018

    %Ĭ�ϲ���ת
    outputImage=inputImage;
    
    %����жϣ��ж��Ƿ�Ϊ����������
    if ~(isnumeric(inputImage) || islogical(inputImage))
        disp('������ͼ��');
        return;
    end
    
    %��ת�����ж�
    if(size(inputImage,1)>size(inputImage,2))
        outputImage=imrotate(inputImage,90,'nearest','loose');
    end
end

