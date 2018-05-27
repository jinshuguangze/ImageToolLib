function outputImage = autoCutting(inputImage)
%autoCutting:�����Զ��и����Ҷ����Ե�Ի����Ϣ�ܶȸ����ͼ��
%inputImage:����ͼ�񣬿�����RGBͼ����߻Ҷ�ͼ��
%outputImage:���ͼ�񣬾�������
%version:1.1.5
%author:jinshuguangze
%data:4/9/2018

    p=inputParser;%������������
    p.addRequired('inputImage',@(x)validateattributes(x,{'numeric'},...
        {'3d','integer' ,'nonnegative'},'autoCutting','inputImage',1));
    p.parse(inputImage);
    inputImage=p.Results.inputImage;
    
    %���û���任�ҳ������߶�
    if ndims(inputImage)==3%����RGBͼ����ҶȻ�
        grayImage=rgb2gray(inputImage);
    else
        grayImage=inputImage;
    end
    edgeImage=edge(grayImage,'Log');%�ɼӲ���
    [Hough,Theta,Rho]=hough(edgeImage,'RhoResolution',1,'Theta',-45:0.1:45);
    Points=houghpeaks(Hough,10,'Threshold',0.5*max(Hough(:)));%'NHoodSize':Default
    Lines=houghlines(edgeImage,Theta,Rho,Points,'FillGap',20,'MinLength',40);
    
    %��ʼ��
    maxLeft=0;
    minRight=size(inputImage,2);
    midpointX=minRight/2;      

    %�ҳ����������и��
    for temp=1:length(Lines)
        xLeft=0;%Ĭ���߶����Ҳ�
        x1=Lines(temp).point1(1);
        x2=Lines(temp).point2(1);       

        if((midpointX-x1)*(midpointX-x2)<=0)%�ж��߶����˵��Ƿ�������ͬһ��
            continue;%����ͬһ�࣬���߶�����
        else
            if(midpointX-x1>0)
                xLeft=1;%�߶������
            end
        end   
                    
        if(xLeft)%�ҳ����ӽ����ߵ��и��
            if(maxLeft<max(x1,x2))
                maxLeft=max(x1,x2);
            end
         else
            if(minRight>min(x1,x2))
                minRight=min(x1,x2);
            end
        end
    end
    
    %ͼ���и�
    outputImage=imcrop(inputImage,[maxLeft,0,minRight-maxLeft,size(inputImage,1)]);
end

