function outputImages = regionExpanding(inputImage,varargin)
%regionExpanding:ʹ���������ͷ����Ҷ�ͼ��ָ����
%inputImage:����ͼ�񣬿���Ϊ�Ҷ�ͼ����߶�ֵͼ�����RGB
%filter:������ʼ�Ҷ���ֵ
%degree:��������������ҶȲ������ֵ
%outputImages:���ͼ��ϸ�����飬ÿ��Ԫ������һ������ͼ��
%version:1.0.6
%author:jinshuguangze
%data:4/13/2018
%TODO:д���Զ������ڴ���(��)����ڼ��(easyGG)��֧��RGB�ȣ�ȡ��filter������Ϊ�Զ��ж�
       %%regionExpanding_Gray(inputImage,�Ҷ�����,�Ҷ�����,���ɲ���)
       
    %��ڼ��
    p=inputParse;%���������
    p.addRequired('inputImage',@(x)validateattributes(x,{'numeric'},...%����ͼ���޶�Ϊ�Ҷ�ͼ��
        {'2d','integer','positive'},'regionExpanding_Gray'),'inputImage',1);%֧�ֶ��ֻҶȵȼ��ĻҶ�ͼ��
    
    %���ͼ��ĸ���������������������0����Ĭ������ݶ����
    p.addOptional('number',@(x)validateattributes(x,{'numeric'},...
        {'sclar','integer','positive'},'regionExpanding_Gray'),'number',2);
    
    p.addOptional('estimated',@(x)validateattributes(x,{'double'},...%�Ҷȹ���ֵ
        {'real','sclar','>=',0,'<=',1},'regionExpanding_Gray'),'estimated',3);
    p.addOptional('degree',@(x)validateattributes(x,{'double'},...%�Ҷȷ�Χֵ
        {'real','sclar','>',0,'<',0.5},'regionExpanding_Gray'),'degree',4);
    p.addParameter('method','Canny',@(x)any(validatestring(x,...
        {'Sobel','Prewitt','Roberts','Log','Zerocross','Approxcanny'})));%�����Ե�ķ�ʽ��֧�ֶ��֡�Sobel��,'PR...')��������Ӻϲ������г���ʱ��Ե�������
    %�洢������֪���أ���������ټ��
    p.addParameter('low','medium','high','extra');%������ӡ�֧�֡�low��4��������miedum��8��������high��12��������extra��16������������

    %Ԥ����
    inputImage=im2double(inputImage);%������ͼ��ת��˫����
    [row,col]=size(inputImage);%���ԭͼ�����   
    stateImage=zeros(row,col);%��ʼ��״̬��
    %State0:δɨ������ص�
    %State1:��ɨ�赫��������ֵ�����ص�
    %State2:��ɨ�裬������ֵ���������������ص�
    %State3:��ɨ�裬������ֵ���Ѽ����������ص�
    count=0;%��ʼ�����ͼ�������
    
    %�ɵ��β���
    neibor=[-1 0;1 0;0 -1;0 1];%����Χ������չ�����   
    outputImages{1}=ones(row,col);%Ĭ�����Ϊȫ��ͼ��
    
    for i=1:row
        for j=1:col
            if ~stateImage(i,j)%���û�б����
                if inputImage(i,j)>filter%�����������ֵ
                    stateImage(i,j)=1;%����״̬����������ֵ
                else%�������Ҷ���ֵ
                    %��ʼ��Ԥ��ֵ    
                    handleList=[i,j,inputImage(i,j)];%��ʼ�����������б�
                    fulfilList=[];%��ʼ�������������б�
                    adv=inputImage(i,j);%��ʼ��ƽ��ֵ
                    top=i;%��ʼ��ͼ��Χֵ
                    bottom=i;
                    left=j;
                    right=j;                 
                 
                    %��ʼ��������
                    while size(handleList,1)
                        %ѭ����ջ����
                        xtag=handleList(1,1);%�ض�λ����Ŀ��
                        ytag=handleList(1,2);
                        stateImage(xtag,ytag)=3;%����״̬������ɼ��
                        handleList(1,:)=[];%��������شӴ�����б����Ƴ�
                        fulfilList=[xtag,ytag,inputImage(xtag,ytag);fulfilList];%���������������б�  
                        
                        %��������Χ�����е����ص�ɨ��һ��
                        num=0;%��ʼ��������������ֵ�����ص�ĸ���
                        for k=1:size(neibor,1)
                            x=xtag+neibor(k,1);%��������
                            y=ytag+neibor(k,2);
                            inRange=x>=1 && y>=1 && x<=row && y<=col;%����Ƿ���ͼ��Χ��
                            if inRange && ~stateImage(x,y)%����ڷ�Χ�ڶ���û�б�ɨ���
                                if inputImage(x,y)>adv+degree%�����������ֵ
                                    stateImage(x,y)=1;%����״̬����������ֵ
                                else%���������ֵ
                                    stateImage(x,y)=2;%����״̬��δ�������
                                    num=num+1;%������������ֵ�����ص�ĸ�������
                                    handleList=[x,y,inputImage(x,y);handleList];%���������б�
                                    top=min(top,x);%����ͼ��Χֵ
                                    bottom=max(bottom,x);
                                    left=min(left,y);
                                    right=max(right,y);                                   
                                end
                            end       
                        end
                                      
                        %�����󣬶��������������������أ�����ɫ����ӽ��Ƚ�
                        if num                  
                            [~,index]=min(abs(handleList(1:num,3)-adv));%�ҵ���ӽ����ص����
                            handleList([1,index],:)=handleList([index,1],:);%��������                         
                            adv=(adv*size(fulfilList,1)+handleList(1,3))/(size(fulfilList,1)+1);%���¼���ƽ��ֵ
                        end   
                    end
                    
                    %������ֵ��ȥ������
                    if size(fulfilList,1)>3000
                        count=count+1;%���ͼ����������
                        outputImages{count}=ones(bottom-top+1,right-left+1);%����ɫĬ��Ϊ��
                        for k=1:size(fulfilList,1)
                            outputImages{count}...%����ͼ��ɫ����Ϣ
                                (fulfilList(k,1)-top+1,fulfilList(k,2)-left+1)=fulfilList(k,3);
                        end
                    end                  
                end
            end
        end
    end
end

