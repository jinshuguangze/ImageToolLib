 function outputImages = regionExpanding_RGB(inputImage,degree,varargin)
%regionExpanding_RGB:ʹ���������ͷ���RGBͼ��ָ����������ʹ��edge�������⸨���ж��߽�
%inputImage:����ͼ��ָ��ΪRGBͼ���Ҹ���Ȥ����Ϊ������ɫ�ֲ���Ϊ��һ
%degree:����������ԭɫ�����ķ�Χ���飬����Χ��0~1
%outputNum:ϣ�����������ͼ���������������������0�����������ص�����½��ݶ�����ѡ��ͼ�����
%estimated:����Ȥ�����RGB����ֵ���飬��������룬������Otsu�㷨�Զ��õ�ͳ�������ϵĹ���ֵ
%method:ʶ���Ե�ķ�������ʹ�á�Sobel������Prewitt������Roberts������Log������Zerocross������Canny������Approxcanny�������ַ���
%operator:��ά���;ۺ����ӣ���ʹ�á�Low������Medium������High������Extra�����ֵȼ���ʹ�ö�Ӧ���ڽ�����
%outputImages:���ͼ��ϸ�����飬ÿ��Ԫ������һ������ͼ��
%version:1.0.7
%author:jinshuguangze
%data:4/29/2018
    
    %��ڼ��
    p=inputParser;%������������
    %����ͼ���޶�ΪRGB���Ҹ���Ȥ�������Ϊ��ɫ����Ϊ��ɫ�����Զ�������ȡ����
    p.addRequired('inputImage',@(x)validateattributes(x,{'numeric'},...
        {'size',[NaN,NaN,3],'integer' ,'nonnegative'},'regionExpanding_RGB','inputImage',1));
    %��ԭɫ����Χֵ��������ͨ���޶�Ϊ0��1֮�����������ԽС������Խ��
    p.addRequired('degree',@(x)validateattributes(x,{'double'},...
        {'real','size',[1,3],'>',0,'<=',1},'regionExpanding_Gray','degree',2));
    %���ͼ��ĸ���������������������0����Ĭ������������ظ����ݶ����ĵ�֮ǰ������ͼ��
    p.addOptional('outputNum',0,@(x)validateattributes(x,{'numeric'},...
        {'scalar','integer','nonnegative'},'regionExpanding_Gray','outputNum',3));   
    %����ֵ���飬������Ȥ�����RGB����ֵ����ȱʧ��ʹ��Otsu�㷨��õķֽ���ȥ����ĸ�����ԭɫ����Χֵ
    p.addOptional('estimated','None',@(x)validateattributes(x,{'double'},...
        {'real','size',[1,3],'>=',0,'<=',1},'regionExpanding_Gray','estimated',4));   
    %ʶ���Ե�ķ�����֧�������ڿ⺯����edge���г��ֵķ�����Ĭ�ϲ�ʹ�ñ߽�����ж���'None'
    p.addParameter('method','None',@(x)any(validatestring(x,...
        {'None','Sobel','Prewitt','Roberts','Log','Zerocross','Canny','Approxcanny'},'regionExpanding_Gray','method',5)));
    %��ά�ۺ����ӣ�֧�����ִ�С����ķ�Χ����ΧԽС������Խ�죬Ĭ��Ϊ��Low�����ӵ�����ͨ����
    p.addParameter('operator','Low',@(x)any(validatestring(x,...
        {'Low','Medium','High','Extra'},'regionExpanding_Gray','operator',6)));
    p.parse(inputImage,degree,varargin{:});%���  
    inputImage=p.Results.inputImage;%��ֵ
    degree=p.Results.degree;
    outputNum=p.Results.outputNum;
    estimated=p.Results.estimated;
    method=p.Results.method;
    operator=p.Results.operator;
    
    %Ԥ����
    inputImage=im2double(inputImage);%������ͼ��ת��˫����
    [row,col,~]=size(inputImage);%���ԭͼ�����   
    stateImage=zeros(row,col);%��ʼ��״̬��
    count=0;%��ʼ�����ͼ�������
    gather={};%��ʼ���洢�������ͼ��ľۼ�����

    if strcmp(estimated,'None')%�������ֵû������
        for i=1:3
            thresh(i)=graythresh(inputImage(:,:,i));%��ȡͳ�������ϵ�������ֵ
            if thresh(i)+degree(i)<1
                estimated(i)=thresh(i)+degree(i);%Ĭ�ϸ���Ȥ����Ϊ����ĳ��ԭɫ���������Ӿ�Ϊ��ɫ
            else
                estimated(i)=1;%Ĭ�ϸ���Ȥ����Ϊ����ĳ��ԭɫ���������Ӿ�Ϊ��ɫ
            end            
        end
    end
    
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
        edgeImage=edge(inputImage(:,:,1),method)...
            & edge(inputImage(:,:,2),method)...
            & edge(inputImage(:,:,3),method);%ʹ����ͨ�������߽�����ж�����ʼ����Ե����һ���߼�ͼ�������ԵΪ1
    end
    
    %�ҳ�����������������ʼ��
    for i=1:row
        for j=1:col
            if ~stateImage(i,j)%���û�б����
                inDegree=1;%��ʼ����Χ���ָʾ
                for m=1:3
                    if degree(m)==1%���������ΧΪȫ��Χ����������Χ���
                        continue;
                    end
                    inDegree=inDegree && inputImage(i,j,m)>=estimated(m)-degree(m)...
                        && inputImage(i,j,m)<=estimated(m)+degree(m);%��Χ���ָʾ����
                end
                
                if ~inDegree%��������㷶Χ���
                    stateImage(i,j)=1;%����״̬����������ֵ
                else%�������Ҷ���ֵ
                    %��ʼ��Ԥ��ֵ
                    %��ʼ�����������б������Ǵ����Ҽ������ʳ�ʼtraceֵΪ3
                    handleList=[i,j,inputImage(i,j,1),inputImage(i,j,2),inputImage(i,j,3),3];
                    fulfilList=[];%��ʼ�������������б�
                    adv=inputImage(i,j,:);%��ʼ��ƽ��ֵ
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
                        trace=handleList(1,6);%��ȡ�����ص�Ĺ켣
                        handleList(1,:)=[];%��������شӴ�����б����Ƴ�
                        %���������������б�  
                        fulfilList=[xtag,ytag,inputImage(xtag,ytag,1),inputImage(xtag,ytag,2),inputImage(xtag,ytag,3);fulfilList];
                        
                        %��������Χ�����е����ص�ɨ��һ��
                        num=0;%��ʼ��������������ֵ�����ص�ĸ���
                        inAdv=1;%��ʼ��
                        for k=1:size(neibor,1)
                            x=xtag+neibor(k,1);%��������
                            y=ytag+neibor(k,2);
                            inRange=x>=1 && y>=1 && x<=row && y<=col;%����Ƿ���ͼ��Χ��
                            if inRange && ~stateImage(x,y)%����ڷ�Χ�ڶ���û�б�ɨ���
                                if edgeImage(x,y) && k==trace%����Ǳ�Ե�����k�����Ź켣����������
                                    continue;
                                end
                                
                                for m=1:3   
                                    inAdv=inAdv && inputImage(x,y,m)>=adv(m)-degree(m)...
                                        && inputImage(x,y,m)<=adv(m)+degree(m);%��Χ���ָʾ����
                                end
                                
                                if ~inAdv%�����������ֵ
                                    stateImage(x,y)=1;%����״̬����������ֵ
                                else%���������ֵ
                                    stateImage(x,y)=2;%����״̬��δ�������
                                    num=num+1;%������������ֵ�����ص�ĸ�������
                                    %���������б����洢ԭʼ����
                                    handleList=[x,y,inputImage(x,y,1),inputImage(x,y,2),inputImage(x,y,3),k;handleList];
                                    top=min(top,x);%����ͼ��Χֵ
                                    bottom=max(bottom,x);
                                    left=min(left,y);
                                    right=max(right,y);                                   
                                end
                            end       
                        end
                                      
                        %�����󣬶��������������������أ�����ɫ����ӽ��Ƚ�
                        if num%�����������Ҫ�������                  
                            [~,index]=min(abs(handleList(1:num,3)-adv(1))+...
                                abs(handleList(1:num,4)-adv(2))+...
                                abs(handleList(1:num,5)-adv(3)));%�ҵ��ۺ�ˮƽ��ӽ����������
                            handleList([1,index],:)=handleList([index,1],:);%��������
                            
                            for m=1:3%���¼����ɫͨ��ƽ��ֵ
                                adv(m)=(adv(m)*size(fulfilList,1)+handleList(1,m+2))/(size(fulfilList,1)+1);
                            end
                        end   
                    end
                    
                    %����ۼ����鲢������Ϣ
                    count=count+1;%���ͼ����������
                    gather{count,1}=zeros(bottom-top+1,right-left+1);%����ɫĬ��Ϊ��
                    gather{count,2}=size(fulfilList,1);%�ڶ��д������ص������Ϣ
                    gather{count,3}=[fulfilList(end,1),fulfilList(end,2)];%�����д����ͼ���ʼ�ۼ�����λ��
                    for k=1:size(fulfilList,1)%����ͼ�����ͨ��ɫ����Ϣ
                        gather{count,1}(fulfilList(k,1)-top+1,fulfilList(k,2)-left+1,1)=fulfilList(k,3);
                        gather{count,1}(fulfilList(k,1)-top+1,fulfilList(k,2)-left+1,2)=fulfilList(k,4);
                        gather{count,1}(fulfilList(k,1)-top+1,fulfilList(k,2)-left+1,3)=fulfilList(k,5);
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