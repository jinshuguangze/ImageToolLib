function outputImages = regionExpanding_Binary(inputImage,varargin)
%regionExpanding_Gray:ʹ���������ͷ����Ҷ�ͼ��ָ����������ʹ��edge�������⸨���ж��߽�
%inputImage:����ͼ��ָ��Ϊ��ֵͼ��������Ȥ����Ϊ��ɫ���أ������Ҫ�����뺯��ǰ��ɫ
%outputNum:ϣ�����������ͼ���������������������0�����������ص�����½��ݶ�����ѡ��ͼ�����
%method:ʶ���Ե�ķ�������ʹ�á�Sobel������Prewitt������Roberts������Log������Zerocross������Canny������Approxcanny�������ַ���
%operator:��ά���;ۺ����ӣ���ʹ�á�Low������Medium������High������Extra�����ֵȼ���ʹ�ö�Ӧ���ڽ�����
%outputImages:���ͼ��ϸ�����飬ÿ��Ԫ������һ������ͼ��
%version:1.0.2
%author:jinshuguangze
%data:5/23/2018
%
%stateImage��ֵ��
%State0:δɨ������ص�
%State1:��ɨ��İ׵�
%State2:��ɨ��ĺڵ㵫δ�������
%State3:��ɨ��ĺڵ����Ѽ������
%
%edgeImage��ֵ��
%State0:��Ϊ�߽�
%State1:Ϊ�߽�
%
%TODO:
%1.���ö�̬�����ڴ���(��)
       
    %��ڼ��
    p=inputParser;%������������
    %����ͼ���޶�Ϊ��ֵͼ������Ҫ�ָ��ͼ��Ϊ��ɫ
    p.addRequired('inputImage',@(x)validateattributes(x,{'logical'},...
        {'2d','binary'},'regionExpanding_Binary','inputImage',1));
    %���ͼ��ĸ���������������������0����Ĭ������������ظ����ݶ����ĵ�֮ǰ������ͼ��
    p.addOptional('outputNum',0,@(x)validateattributes(x,{'numeric'},...
        {'scalar','integer','nonnegative'},'regionExpanding_Binary','outputNum',2));    
    %ʶ���Ե�ķ�����֧�������ڿ⺯����edge���г��ֵķ�����Ĭ�ϲ�ʹ�ñ߽�����ж���'None'
    p.addParameter('method','None',@(x)any(validatestring(x,...
        {'None','Sobel','Prewitt','Roberts','Log','Zerocross','Canny','Approxcanny'},'regionExpanding_Binary','method',3)));
    %��ά�ۺ����ӣ�֧�����ִ�С����ķ�Χ����ΧԽС������Խ�죬Ĭ��Ϊ��Low�����ӵ�����ͨ����
    p.addParameter('operator','Low',@(x)any(validatestring(x,...
        {'Low','Medium','High','Extra'},'regionExpanding_Binary','operator',4)));
    p.parse(inputImage,varargin{:});%���  
    inputImage=p.Results.inputImage;%��ֵ
    outputNum=p.Results.outputNum;
    method=p.Results.method;
    operator=p.Results.operator;
    
    %Ԥ����
    inputImage=im2double(inputImage);%������ͼ��ת��˫����
    [row,col]=size(inputImage);%���ԭͼ�����   
    stateImage=zeros(row,col);%��ʼ��״̬��   
    count=0;%��ʼ�����ͼ�������
    gather={};%��ʼ���洢�������ͼ��ľۼ�����
    
    switch upper(operator)%��ά�ۺ�����ʵ����
        case 'LOW'
            neibor=[-1 0;0 1;1 0;0 -1];
            
        case 'MEDIUM'
            neibor=[-1 0;0 1;1 0;0 -1;-1 -1;-1 1;1 1;1 -1];
            
        case 'HIGH'
            neibor=[-1 0;0 1;1 0;0 -1;-1 -1;-1 1;1 1;1 -1;0 -2;-2 0;0 2;2 0];
            
        case 'EXTRA'
            neibor=[-1 0;0 1;1 0;0 -1;-1 -1;-1 1;1 1;1 -1;0 -2;-2 0;0 2;2 0;
                2 -1;2 -2;1 -2;-1 -2;-2 -2;-2 -1;-2 1;-2 2;-1 2;1 2;2 2;2 1];
            
        otherwise%����validatestring�����ԣ������һЩ��ֵĽ����ַ���������ʱֻ���趨ΪĬ��ֵ
            neibor=[-1 0;0 1;1 0;0 -1];
    end
    
    if strcmp(method,'None') || size(neibor,1)>8%�Ա�Ե�㷨�����жϣ�����ۺ����ӹ������ʺ�ʹ�ñ߽縨���ж�
        edgeImage=zeros(row,col);%��ʹ�ñ߽�����ж���edgeImgae��һ��0ֵͼ
    else
        edgeImage=edge(inputImage,method);%ʹ�ñ߽�����ж�����ʼ����Ե����һ���߼�ͼ�������ԵΪ1
    end
    
    %�ҳ�����������������ʼ��
    for i=1:row
        for j=1:col
            if ~stateImage(i,j) 
                if inputImage(i,j)%���Ϊ��ɫ������
                    stateImage(i,j)=1;
                else
                    %��ʼ��Ԥ��ֵ    
                    handleList=[i,j,inputImage(i,j),3];%��ʼ�����������б������Ǵ����Ҽ������ʳ�ʼtraceֵΪ3
                    fulfilList=[];%��ʼ�������������б�
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
                        trace=handleList(1,4);%��ȡ�����ص�Ĺ켣
                        handleList(1,:)=[];%��������شӴ�����б����Ƴ�
                        fulfilList=[xtag,ytag,inputImage(xtag,ytag);fulfilList];%���������������б�  
                        
                        %��������Χ�����е����ص�ɨ��һ��
                        num=0;%��ʼ��������������ֵ�����ص�ĸ���
                        for k=1:size(neibor,1)
                            x=xtag+neibor(k,1);%��������
                            y=ytag+neibor(k,2);
                            inRange=x>=1 && y>=1 && x<=row && y<=col;%����Ƿ���ͼ��Χ��
                            if inRange && ~stateImage(x,y)%����ڷ�Χ�ڶ���û�б�ɨ���
                                if edgeImage(x,y) && k==trace%����Ǳ�Ե�����k�����Ź켣����������
                                    continue;
                                end
                                    
                                if inputImage(x,y)%�����������ֵ
                                    stateImage(x,y)=1;%����״̬�����Ǻڵ�
                                else%���������ֵ
                                    stateImage(x,y)=2;%����״̬��δ�������
                                    num=num+1;%������������ֵ�����ص�ĸ�������
                                    handleList=[x,y,inputImage(x,y),k;handleList];%���������б����洢ԭʼ����
                                    top=min(top,x);%����ͼ��Χֵ
                                    bottom=max(bottom,x);
                                    left=min(left,y);
                                    right=max(right,y);                                   
                                end
                            end       
                        end
                    end
                    
                    %����ۼ����鲢������Ϣ
                    count=count+1;%���ͼ����������
                    gather{count,1}=ones(bottom-top+1,right-left+1);%����ɫΪ��
                    gather{count,2}=size(fulfilList,1);%�ڶ��д������ص������Ϣ
                    gather{count,3}=[fulfilList(end,1),fulfilList(end,2)];%�����д����ͼ���ʼ�ۼ�����λ��
                    for k=1:size(fulfilList,1)%����ͼ��ɫ����Ϣ
                        gather{count,1}(fulfilList(k,1)-top+1,fulfilList(k,2)-left+1)=fulfilList(k,3);
                    end
                end
            end
        end
    end
    
    %�������ͼ��
    if ~count%��ͼ��Ĭ�����Ϊԭͼ��
        outputImages{1}=inputImage;
    elseif count==1%ֻ��һ��ͼ��ֱ�����
        outputImages{1}=gather{1,1};
    else%�ж��ͼ����ð������������
        outputImages={};%��ʼ�����ͼ��ϸ������
        for i=1:count
            for j=2:count
                if gather{j-1,2}<gather{j,2}
                    tempA=gather{j-1,1};%��������
                    tempB=gather{j-1,2};
                    tempC=gather{j-1,3};
                    gather{j-1,1}=gather{j,1};
                    gather{j-1,2}=gather{j,2};
                    gather{j-1,3}=gather{j,3};
                    gather{j,1}=tempA;
                    gather{j,2}=tempB;
                    gather{j,3}=tempC;
                end
            end
        end
        
        %������ʵ�������
        if outputNum%����涨�����ͼ����Ŀ      
                indexMax=min(count,outputNum);%�������Ϊ��С��
        else%���û�й涨���ͼ����Ŀ����ѡ���ݶ��½���ĵ�֮ǰ��ͼ��
            maxGrad=0;%��ʼ������ݶ�
            for i=2:count
                if maxGrad<gather{i-1,2}-gather{i,2}
                    maxGrad=gather{i-1,2}-gather{i,2};
                    indexMax=i-1;%��¼�����
                end
            end
        end
        
        %��������˳��������˳��
        orderSign=[];%��ʼ��˳��������
        for i=1:indexMax%��ȡ�������ͼƬ��˳����
            orderSign=[orderSign;gather{i,3}];
        end
        [rowCell,tform]=blindLayer(orderSign(:,1));%��ȡÿ�е�����ۼ�
        if isempty(rowCell) || isempty(tform)%�������ʧ�ܣ�ʹ�ð������ض��ٽ�������
            outputImages=gather(1:indexMax,1);
        else%����ɹ���ʹ����������
            for i=1:size(rowCell,2)%ÿһ�е��������
                for j=1:size(rowCell{i},1)%ÿһ�е�һ�е���
                    [~,index]=min(orderSign(tform{i},2));%�ҵ���С������������
                    orderSign(tform{i}(index),2)=col+1;%���������Ƴ�ͼ��
                    outputImages=[outputImages,gather{tform{i}(index),1}];%ƴ�����ͼ��ϸ������
                end
            end
        end
    end
end