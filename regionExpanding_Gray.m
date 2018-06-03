function outputImages = regionExpanding_Gray(inputImage,degree,varargin)
%regionExpanding_Gray:ʹ���������ͷ����Ҷ�ͼ��ָ����������ʹ��edge�������⸨���ж��߽�
%inputImage:����ͼ��ָ��Ϊ�Ҷ�ͼ��������Ȥ����Ϊǳɫͼ����ᷴɫ�����ж�
%degree:����������ҶȲ����ķ�Χ������Χ��0~1����Ϊ1����ֱ�����ԭͼ
%outputNum:ϣ�����������ͼ���������������������0�����������ص�����½��ݶ�����ѡ��ͼ�����
%estimated:����Ȥ����ĻҶȹ���ֵ����������룬��Ĭ����ɫΪ����Ȥ���򣬲������Otsu�㷨�Զ��õ�ͳ�������ϵĹ���ֵ
%method:ʶ���Ե�ķ�������ʹ�á�Sobel������Prewitt������Roberts������Log������Zerocross������Canny������Approxcanny�������ַ���
%edgeKeep:����������ʱ���ۼ������Ƿ�������Ե��ʹ�á�include������exclude���������Ƿ������Ե����
%operator:��ά���;ۺ����ӣ���ʹ�á�Low������Medium������High������Extra�����ֵȼ���ʹ�ö�Ӧ���ڽ�����
%outputSort:���ͼ���˳����ʹ�á�Succession��(���ӵ���˳��)����Quantity��(������������)����Reality��(��ʵ����)�����ַ���
%outputImages:���ͼ��ϸ�����飬ÿ��Ԫ������һ������ͼ��
%version:1.4.2
%author:jinshuguangze
%data:4/13/2018
%
%stateImage��ֵ��
%State0:δɨ������ص�
%State1:��ɨ�赫��������ֵ�����ص�
%State2:��ɨ�裬������ֵ���������������ص�
%State3:��ɨ�裬������ֵ���Ѽ����������ص�
%
%trace��ֵ��:
%Operator:'Low':       	Operator:'Medium':
%��:0                         ��:0	����:1
%��:1                          ��:2	����:3
%��:2                         ��:4    ����:5
%��:3                         ��:6	����:7
%
%
%edgeImage��ֵ��
%State0:��Ϊ�߽�
%State1:Ϊ�߽�
%
%TODO:
%1.���ö�̬�����ڴ���(��)
       
    %��ڼ��
    p=inputParser;%������������
    %����ͼ���޶�Ϊ�Ҷ�ͼ������Ҫ�ָ��ͼ��Ϊ��ɫ��֧�ֶ��ֻҶȵȼ��ĻҶ�ͼ��
    p.addRequired('inputImage',@(x)validateattributes(x,{'numeric'},...
        {'2d','integer','nonnegative'},'regionExpanding_Gray','inputImage',1));
    %�Ҷ�����Χֵ���޶�Ϊ0��0.5֮�����������ԽС������Խ��
    p.addRequired('degree',@(x)validateattributes(x,{'double'},...
        {'real','scalar','>',0,'<=',1},'regionExpanding_Gray','degree',2));
    %���ͼ��ĸ���������������������0����Ĭ������������ظ����ݶ����ĵ�֮ǰ������ͼ��
    p.addOptional('outputNum',0,@(x)validateattributes(x,{'numeric'},...
        {'scalar','integer','nonnegative'},'regionExpanding_Gray','outputNum',3));   
    %�Ҷȹ���ֵ����������룬��ʹ��Otsu�㷨��õĻҶȼ�ȥ����ĻҶ�����Χֵ
    p.addOptional('estimated','None',@(x)validateattributes(x,{'double'},...
        {'real','scalar','>=',0,'<=',1},'regionExpanding_Gray','estimated',4));   
    %ʶ���Ե�ķ�����֧�������ڿ⺯����edge���г��ֵķ�����Ĭ�ϲ�ʹ�ñ߽�����ж���'None'
    p.addParameter('method','None',@(x)any(validatestring(x,...
        {'None','Sobel','Prewitt','Roberts','Log','Zerocross','Canny','Approxcanny'},'regionExpanding_Gray','method',5)));
    %�Ƿ������Ե���ߣ����ҽ���ӵ��ʶ���Ե�ķ���ʱ����Ч��Ĭ��Ϊ��exclude��
    p.addParameter('edgeKeep','exclude',@(x)any(validatestring(x,...
        {'include','exclude'},'regionExpanding_Gray','edgeKeep',6)));
    %��ά�ۺ����ӣ�֧�����ִ�С����ķ�Χ����ΧԽС������Խ�죬Ĭ��Ϊ��Low�����ӵ�����ͨ����
    p.addParameter('operator','Low',@(x)any(validatestring(x,...
        {'Low','Medium','High','Extra'},'regionExpanding_Gray','operator',7)));
    %���ͼ��˳��֧�����ӵ���˳����������������ʵ���������֣�Ĭ��Ϊ���ӵ���˳��
    p.addParameter('outputSort','Succession',@(x)any(validatestring(x,...
        {'Succession','Quantity','Reality'},'regionExpanding_Gray','outputSort',8)));
    
    p.parse(inputImage,degree,varargin{:});%���  
    inputImage=p.Results.inputImage;%��ֵ
    degree=p.Results.degree;
    outputNum=p.Results.outputNum;
    estimated=p.Results.estimated;
    method=p.Results.method;
 	edgeKeep=p.Results.edgeKeep;
    operator=p.Results.operator;
    outputSort=p.Results.outputSort;
    
    %Ԥ����
    inputImage=im2double(inputImage);%������ͼ��ת��˫����
    [row,col]=size(inputImage);%���ԭͼ�����   
    stateImage=zeros(row,col);%��ʼ��״̬��   
    count=0;%��ʼ�����ͼ�������
    gather={};%��ʼ���洢�������ͼ��ľۼ�����
    thresh=graythresh(inputImage);%��ȡͳ�������ϵ�������ֵ
    
    if degree==1%����ҶȲ�����ȫ��Χ����ôֱ�ӷ���ԭͼ
        outputImages{1}=inputImage;
        return;
    end
    
    if strcmp(estimated,'None')%�������ֵû������
        if thresh>degree
            estimated=thresh-degree;%Ĭ�ϸ���Ȥ����Ϊ��ɫ
        else
            estimated=0;%Ĭ�ϸ���Ȥ����Ϊ��ɫ
        end
    end
    
    switch upper(operator)%��ά�ۺ�����ʵ����
        case 'LOW'%˳ʱ�뷽��
            neibor=[-1 0;0 1;1 0;0 -1];
            
        case 'MEDIUM'%˳ʱ�뷽��
            neibor=[-1 0;-1 1;0 1;1 1;1 0;1 -1;0 -1;-1 -1];
            
        case 'HIGH'%�������ⵥ��˳ʱ�뷽��
            neibor=[-1 0;0 1;1 0;0 -1;-1 -1;-1 1;1 1;1 -1;0 -2;-2 0;0 2;2 0];
            
        case 'EXTRA'%�������ⵥ��˳ʱ�뷽��
            neibor=[-1 0;0 1;1 0;0 -1;-1 -1;-1 1;1 1;1 -1;0 -2;-2 0;0 2;2 0;
                2 -1;2 -2;1 -2;-1 -2;-2 -2;-2 -1;-2 1;-2 2;-1 2;1 2;2 2;2 1];
            
        otherwise%����validatestring�����ԣ������һЩ��ֵĽ����ַ���������ʱֻ���趨ΪĬ��ֵ
            neibor=[-1 0;0 1;1 0;0 -1];%˳ʱ�뷽��
    end
    
    neibLength=size(neibor,1);%��ʼ���ۺ����ӳ���
    if strcmpi(method,'None') || neibLength>8%�Ա�Ե�㷨�����жϣ�����ۺ����ӹ������ʺ�ʹ�ñ߽縨���ж�
        edgeImage=zeros(row,col);%��ʹ�ñ߽�����ж���edgeImgae��һ��0ֵͼ
    else
        edgeImage=edge(inputImage,method,thresh);%ʹ�ñ߽�����ж�����ʼ����Ե����һ���߼�ͼ�������ԵΪ1
    end
    
    %�ҳ�����������������ʼ��
    for i=1:row
        for j=1:col
            if ~stateImage(i,j)%���û�б����
                if inputImage(i,j)>estimated+degree || inputImage(i,j)<estimated-degree%�����������ֵ
                    stateImage(i,j)=1;%����״̬����������ֵ
                else%�������Ҷ���ֵ
                    %��ʼ��Ԥ��ֵ
                    if neibLength==8%��ʼ�����������б���ʼ�켣�Ǵ����Ҽ���
                        handleList=[i,j,inputImage(i,j),2];%Ϊ�����򣬳�ʼ�켣Ϊ2
                    else
                        handleList=[i,j,inputImage(i,j),1];%Ϊ�������򣬳�ʼ�켣Ϊ1
                    end
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
                        trace=handleList(1,4);%��ȡ�����ص�Ĺ켣
                        handleList(1,:)=[];%��������شӴ�����б����Ƴ�
                        fulfilList=[xtag,ytag,inputImage(xtag,ytag);fulfilList];%���������������б�  
                        if neibLength==8%ȡ���������飬Ӱ���Ե����
                            traceMat=[mod(trace+7,8),trace,mod(trace+1,8)];%ȡ������ΧΪ45������
                        else
                            traceMat=trace;%ȡ�������Ϊ�˷���
                        end
                        
                        %��������Χ�����е����ص�ɨ��һ��
                        num=0;%��ʼ��������������ֵ�����ص�ĸ���
                        for k=1:neibLength
                            x=xtag+neibor(k,1);%��������
                            y=ytag+neibor(k,2);
                            inRange=x>=1 && y>=1 && x<=row && y<=col;%����Ƿ���ͼ��Χ��
                            if inRange && ~stateImage(x,y)%����ڷ�Χ�ڶ���û�б�ɨ���
                                if strcmpi(edgeKeep,'include')
                                    %������Ե�㣬����ӱ�Ե�������Ǳ�Ե�����k������ȡ�����������У���������������״̬����������ֵ
                                    if edgeImage(xtag,ytag) && ~edgeImage(x,y) && any(k==traceMat)
                                        stateImage(x,y)=1;
                                        continue;
                                    end
                                else
                                    %��������Ե�㣬�����߽������
                                    if edgeImage(x,y)
                                        stateImage(x,y)=1;
                                        continue;
                                    end
                                end
                                    
                                if inputImage(x,y)>adv+degree || inputImage(x,y)<adv-degree%�����������ֵ
                                    stateImage(x,y)=1;%����״̬����������ֵ
                                else%���������ֵ
                                    stateImage(x,y)=2;%����״̬��δ�������
                                    num=num+1;%������������ֵ�����ص�ĸ�������
                                    handleList=[x,y,inputImage(x,y),k-1;handleList];%���������б����洢ԭʼ����
                                    top=min(top,x);%����ͼ��Χֵ
                                    bottom=max(bottom,x);
                                    left=min(left,y);
                                    right=max(right,y);                                   
                                end
                            end       
                        end
                                      
                        %�����󣬶��������������������أ�����ɫ����ӽ��Ƚ�
                        if num                  
                            [~,rowCell]=min(abs(handleList(1:num,3)-adv));%�ҵ���ӽ����ص����
                            handleList([1,rowCell],:)=handleList([rowCell,1],:);%��������                         
                            adv=(adv*size(fulfilList,1)+handleList(1,3))/(size(fulfilList,1)+1);%���¼���ƽ��ֵ
                        end   
                    end
                    
                    %����ۼ����鲢������Ϣ
                    count=count+1;%���ͼ����������
                    if estimated>0.5%����Ԥ������Ҷ���ȷ��������ɫ
                        gather{count,1}=zeros(bottom-top+1,right-left+1);%����ɫΪ��
                    else
                        gather{count,1}=ones(bottom-top+1,right-left+1);%����ɫΪ��
                    end
                    gather{count,2}=size(fulfilList,1);%�ڶ��д������ص������Ϣ
                    gather{count,3}=[fulfilList(end,1),fulfilList(end,2)];%�����д����ͼ�����ӵ�λ��
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