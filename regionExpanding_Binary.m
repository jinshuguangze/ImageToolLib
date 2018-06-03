function outputImages = regionExpanding_Binary(inputImage,varargin)
%regionExpanding_Gray:ʹ���������ͷ����Ҷ�ͼ��ָ����������ʹ��edge�������⸨���ж��߽�
%inputImage:����ͼ��ָ��Ϊ��ֵͼ��������Ȥ����Ϊ��ɫ���أ������Ҫ�����뺯��ǰ��ɫ
%outputNum:ϣ�����������ͼ���������������������0�����������ص�����½��ݶ�����ѡ��ͼ�����
%method:ʶ���Ե�ķ�������ʹ�á�Sobel������Prewitt������Roberts������Log������Zerocross������Canny������Approxcanny�������ַ���
%operator:��ά���;ۺ����ӣ���ʹ�á�Low������Medium������High������Extra�����ֵȼ���ʹ�ö�Ӧ���ڽ�����
%outputSort:���ͼ���˳����ʹ�á�Succession��(���ӵ���˳��)����Quantity��(������������)����Reality��(��ʵ����)�����ַ���
%outputImages:���ͼ��ϸ�����飬ÿ��Ԫ������һ������ͼ��
%version:1.0.7
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
    %���ͼ��˳��֧�����ӵ���˳����������������ʵ���������֣�Ĭ��Ϊ���ӵ���˳��
    p.addParameter('outputSort','Succession',@(x)any(validatestring(x,...
        {'Succession','Quantity','Reality'},'regionExpanding_Gray','outputSort',7)));
    
    p.parse(inputImage,varargin{:});%���  
    inputImage=p.Results.inputImage;%��ֵ
    outputNum=p.Results.outputNum;
    method=p.Results.method;
    operator=p.Results.operator;
    outputSort=p.Results.outputSort;
    
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
    
    if strcmpi(method,'None') || size(neibor,1)>8%�Ա�Ե�㷨�����жϣ�����ۺ����ӹ������ʺ�ʹ�ñ߽縨���ж�
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
        gatherTemp=gather;%��Ϊ�ۼ�����ı���
        for i=1:count
            for j=2:count
                if gatherTemp{j-1,2}<gatherTemp{j,2}
                    tempA=gatherTemp{j-1,1};%��������
                    tempB=gatherTemp{j-1,2};
                    tempC=gatherTemp{j-1,3};
                    gatherTemp{j-1,1}=gatherTemp{j,1};
                    gatherTemp{j-1,2}=gatherTemp{j,2};
                    gatherTemp{j-1,3}=gatherTemp{j,3};
                    gatherTemp{j,1}=tempA;
                    gatherTemp{j,2}=tempB;
                    gatherTemp{j,3}=tempC;
                end
            end
        end
        
        %������ʵ�������
        if outputNum%����涨�����ͼ����Ŀ      
                indexMax=min(count,outputNum);%�������Ϊ��С��
        else%���û�й涨���ͼ����Ŀ����ѡ���ݶ��½���ĵ�֮ǰ��ͼ��
            maxGrad=0;%��ʼ������ݶ�
            for i=2:count
                if maxGrad<=gatherTemp{i-1,2}-gatherTemp{i,2}
                    maxGrad=gatherTemp{i-1,2}-gatherTemp{i,2};
                    indexMax=i-1;%��¼�����
                end
            end
        end
        
        %��������˳��������˳��
        switch upper(outputSort)
            case 'SUCCESSION'%�������ӵ���˳��
                
            case 'QUANTITY'%�����ں������������
                outputImages=gatherTemp(1:indexMax,1)';
                return;
                
            case 'REALITY'%������ʵ�������
                orderSign=cell2mat(gatherTemp(1:indexMax,3));%��ȡ�������ͼƬ��˳����
                [rowCell,tform]=blindLayer(orderSign(:,1));%��ȡÿ�е�����ۼ�       
                if ~isempty(rowCell) && ~isempty(tform)%����ɹ���ʹ��������������ʧ�����Զ�ʹ�����ӵ���˳��
                    for i=1:size(rowCell,2)%ÿһ�е��������
                        for j=1:size(rowCell{i},1)%ÿһ�е�һ�е���
                            [~,index]=min(orderSign(tform{i},2));%�ҵ���С������������
                            orderSign(tform{i}(index),2)=col+1;%���������Ƴ�ͼ��
                            outputImages=[outputImages,gatherTemp{tform{i}(index),1}];%ƴ�����ͼ��ϸ������
                        end
                    end
                    return;
                end
        end
        
        outputImages=gather(find(cell2mat(gather(:,2))>=gatherTemp{indexMax,2},indexMax),1)';%�������ӵ���˳������
    end
end