function outputImages = regionExpanding_Gray(inputImage,degree,varargin)
%regionExpanding_Gray:使用区域膨胀法将灰度图像分割单例化，并可使用edge函数额外辅助判定边界
%inputImage:输入图像，指定为灰度图像，若感兴趣区域为浅色图像，则会反色后再判定
%degree:新像素允许灰度波动的范围，允许范围是0~1，若为1，则直接输出原图
%outputNum:希望输出的至多图像个数，如果不输出或输入0，则会基于像素点个数下降梯度智能选择图像个数
%estimated:感兴趣区域的灰度估计值，如果不输入，则默认深色为感兴趣区域，并会基于Otsu算法自动得到统计意义上的估计值
%method:识别边缘的方法，能使用‘Sobel’，‘Prewitt’，‘Roberts’，‘Log’，‘Zerocross’，’Canny‘，’Approxcanny‘这七种方法
%edgeKeep:在区域膨胀时，聚集数组是否包含其边缘，使用‘include’，‘exclude’来控制是否包含边缘曲线
%operator:二维膨胀聚合算子，能使用’Low‘，’Medium‘，’High‘，’Extra‘四种等级来使用对应的内建算子
%outputSort:输出图像的顺序，能使用’Succession‘(种子点检测顺序)，‘Quantity’(像素数量降序)，‘Reality’(真实排序)这三种方法
%outputImages:输出图像细胞数组，每个元胞都是一个单例图像
%version:1.4.2
%author:jinshuguangze
%data:4/13/2018
%
%stateImage真值表：
%State0:未扫描的像素点
%State1:已扫描但不满足阈值的像素点
%State2:已扫描，满足阈值但待检测邻域的像素点
%State3:已扫描，满足阈值且已检测邻域的像素点
%
%trace真值表:
%Operator:'Low':       	Operator:'Medium':
%上:0                         上:0	右上:1
%右:1                          右:2	右下:3
%下:2                         下:4    左下:5
%左:3                         左:6	左上:7
%
%
%edgeImage真值表：
%State0:不为边界
%State1:为边界
%
%TODO:
%1.运用动态分配内存器(√)
       
    %入口检测
    p=inputParser;%构造检测器对象
    %输入图像，限定为灰度图像，且需要分割的图像为深色，支持多种灰度等级的灰度图像
    p.addRequired('inputImage',@(x)validateattributes(x,{'numeric'},...
        {'2d','integer','nonnegative'},'regionExpanding_Gray','inputImage',1));
    %灰度允许范围值，限定为0到0.5之间的数，数字越小，运算越快
    p.addRequired('degree',@(x)validateattributes(x,{'double'},...
        {'real','scalar','>',0,'<=',1},'regionExpanding_Gray','degree',2));
    %输出图像的个数，如果不输入或者输入0，则默认输出包含像素个数梯度最大的点之前的所有图像
    p.addOptional('outputNum',0,@(x)validateattributes(x,{'numeric'},...
        {'scalar','integer','nonnegative'},'regionExpanding_Gray','outputNum',3));   
    %灰度估计值，如果不输入，则使用Otsu算法获得的灰度减去输入的灰度允许范围值
    p.addOptional('estimated','None',@(x)validateattributes(x,{'double'},...
        {'real','scalar','>=',0,'<=',1},'regionExpanding_Gray','estimated',4));   
    %识别边缘的方法，支持所有在库函数’edge‘中出现的方法，默认不使用边界额外判定即'None'
    p.addParameter('method','None',@(x)any(validatestring(x,...
        {'None','Sobel','Prewitt','Roberts','Log','Zerocross','Canny','Approxcanny'},'regionExpanding_Gray','method',5)));
    %是否包含边缘曲线，当且仅当拥有识别边缘的方法时才有效，默认为‘exclude’
    p.addParameter('edgeKeep','exclude',@(x)any(validatestring(x,...
        {'include','exclude'},'regionExpanding_Gray','edgeKeep',6)));
    %二维聚合算子，支持四种从小到大的范围，范围越小，运算越快，默认为’Low‘算子的四联通区域
    p.addParameter('operator','Low',@(x)any(validatestring(x,...
        {'Low','Medium','High','Extra'},'regionExpanding_Gray','operator',7)));
    %输出图像顺序，支持种子点检测顺序，像素数量降序，真实排序这三种，默认为种子点检测顺序
    p.addParameter('outputSort','Succession',@(x)any(validatestring(x,...
        {'Succession','Quantity','Reality'},'regionExpanding_Gray','outputSort',8)));
    
    p.parse(inputImage,degree,varargin{:});%检测  
    inputImage=p.Results.inputImage;%赋值
    degree=p.Results.degree;
    outputNum=p.Results.outputNum;
    estimated=p.Results.estimated;
    method=p.Results.method;
 	edgeKeep=p.Results.edgeKeep;
    operator=p.Results.operator;
    outputSort=p.Results.outputSort;
    
    %预处理
    inputImage=im2double(inputImage);%将输入图像转成双精度
    [row,col]=size(inputImage);%获得原图像参数   
    stateImage=zeros(row,col);%初始化状态表   
    count=0;%初始化输出图像计数器
    gather={};%初始化存储所有输出图像的聚集数组
    thresh=graythresh(inputImage);%获取统计意义上的最优阈值
    
    if degree==1%如果灰度波动是全范围，那么直接返回原图
        outputImages{1}=inputImage;
        return;
    end
    
    if strcmp(estimated,'None')%如果估计值没有输入
        if thresh>degree
            estimated=thresh-degree;%默认感兴趣区域为深色
        else
            estimated=0;%默认感兴趣区域为深色
        end
    end
    
    switch upper(operator)%二维聚合算子实例化
        case 'LOW'%顺时针方向
            neibor=[-1 0;0 1;1 0;0 -1];
            
        case 'MEDIUM'%顺时针方向
            neibor=[-1 0;-1 1;0 1;1 1;1 0;1 -1;0 -1;-1 -1];
            
        case 'HIGH'%从里向外单层顺时针方向
            neibor=[-1 0;0 1;1 0;0 -1;-1 -1;-1 1;1 1;1 -1;0 -2;-2 0;0 2;2 0];
            
        case 'EXTRA'%从里向外单层顺时针方向
            neibor=[-1 0;0 1;1 0;0 -1;-1 -1;-1 1;1 1;1 -1;0 -2;-2 0;0 2;2 0;
                2 -1;2 -2;1 -2;-1 -2;-2 -2;-2 -1;-2 1;-2 2;-1 2;1 2;2 2;2 1];
            
        otherwise%由于validatestring的特性，会接受一些奇怪的近似字符进来，此时只能设定为默认值
            neibor=[-1 0;0 1;1 0;0 -1];%顺时针方向
    end
    
    neibLength=size(neibor,1);%初始化聚合算子长度
    if strcmpi(method,'None') || neibLength>8%对边缘算法进行判断，如果聚合算子过大，则不适合使用边界辅助判断
        edgeImage=zeros(row,col);%不使用边界额外判定，edgeImgae是一幅0值图
    else
        edgeImage=edge(inputImage,method,thresh);%使用边界额外判定，初始化边缘表，是一幅逻辑图，其检测边缘为1
    end
    
    %找出满足条件的生长开始点
    for i=1:row
        for j=1:col
            if ~stateImage(i,j)%如果没有被检测
                if inputImage(i,j)>estimated+degree || inputImage(i,j)<estimated-degree%如果不满足阈值
                    stateImage(i,j)=1;%更新状态，不满足阈值
                else%如果满足灰度阈值
                    %初始化预设值
                    if neibLength==8%初始化待邻域检测列表，初始轨迹是从左到右检索
                        handleList=[i,j,inputImage(i,j),2];%为八邻域，初始轨迹为2
                    else
                        handleList=[i,j,inputImage(i,j),1];%为其他邻域，初始轨迹为1
                    end
                    fulfilList=[];%初始化完成邻域检测的列表
                    adv=inputImage(i,j);%初始化平均值
                    top=i;%初始化图像范围值
                    bottom=i;
                    left=j;
                    right=j;                 
                 
                    %开始区域增长
                    while size(handleList,1)
                        %循环堆栈处理
                        xtag=handleList(1,1);%重定位到此目标
                        ytag=handleList(1,2);
                        stateImage(xtag,ytag)=3;%更新状态，已完成检测
                        trace=handleList(1,4);%提取该像素点的轨迹
                        handleList(1,:)=[];%将这个像素从待检测列表中移除
                        fulfilList=[xtag,ytag,inputImage(xtag,ytag);fulfilList];%更新完成邻域检测的列表  
                        if neibLength==8%取消方向数组，影响边缘特性
                            traceMat=[mod(trace+7,8),trace,mod(trace+1,8)];%取消方向范围为45度区域
                        else
                            traceMat=trace;%取消方向仅为此方向
                        end
                        
                        %对于邻域范围内所有的像素点扫描一遍
                        num=0;%初始化邻域内满足阈值的像素点的个数
                        for k=1:neibLength
                            x=xtag+neibor(k,1);%更新坐标
                            y=ytag+neibor(k,2);
                            inRange=x>=1 && y>=1 && x<=row && y<=col;%检测是否在图像范围内
                            if inRange && ~stateImage(x,y)%如果在范围内而且没有被扫描过
                                if strcmpi(edgeKeep,'include')
                                    %包括边缘点，如果从边缘点跳到非边缘点而且k存在于取消方向数组中，则跳过，并更新状态，不满足阈值
                                    if edgeImage(xtag,ytag) && ~edgeImage(x,y) && any(k==traceMat)
                                        stateImage(x,y)=1;
                                        continue;
                                    end
                                else
                                    %不包括边缘点，碰到边界就跳过
                                    if edgeImage(x,y)
                                        stateImage(x,y)=1;
                                        continue;
                                    end
                                end
                                    
                                if inputImage(x,y)>adv+degree || inputImage(x,y)<adv-degree%如果不满足阈值
                                    stateImage(x,y)=1;%更新状态，不满足阈值
                                else%如果满足阈值
                                    stateImage(x,y)=2;%更新状态，未检测邻域
                                    num=num+1;%邻域内满足阈值的像素点的个数增加
                                    handleList=[x,y,inputImage(x,y),k-1;handleList];%加入待检测列表，并存储原始方向
                                    top=min(top,x);%更新图像范围值
                                    bottom=max(bottom,x);
                                    left=min(left,y);
                                    right=max(right,y);                                   
                                end
                            end       
                        end
                                      
                        %检测完后，对于所有满足条件的像素，进行色彩最接近比较
                        if num                  
                            [~,rowCell]=min(abs(handleList(1:num,3)-adv));%找到最接近像素的序号
                            handleList([1,rowCell],:)=handleList([rowCell,1],:);%交换两行                         
                            adv=(adv*size(fulfilList,1)+handleList(1,3))/(size(fulfilList,1)+1);%重新计算平均值
                        end   
                    end
                    
                    %存入聚集数组并填入信息
                    count=count+1;%输出图像数量增加
                    if estimated>0.5%根据预期区域灰度来确定背景颜色
                        gather{count,1}=zeros(bottom-top+1,right-left+1);%背景色为黑
                    else
                        gather{count,1}=ones(bottom-top+1,right-left+1);%背景色为白
                    end
                    gather{count,2}=size(fulfilList,1);%第二列存入像素点个数信息
                    gather{count,3}=[fulfilList(end,1),fulfilList(end,2)];%第三列存入该图像种子点位置
                    for k=1:size(fulfilList,1)%填入图像色彩信息
                        gather{count,1}(fulfilList(k,1)-top+1,fulfilList(k,2)-left+1)=fulfilList(k,3);
                    end
                end
            end
        end
    end
    
    %处理输出图像
    if ~count%无图像，默认输出为原图像
        outputImages{1}=inputImage;
    elseif count==1%只有一副图像，直接输出
        outputImages{1}=gather{1,1};
    else%有多幅图像，用冒泡排序降序排列
        outputImages={};%初始化输出图像细胞数组
        gatherTemp=gather;%作为聚集数组的备份
        for i=1:count
            for j=2:count
                if gatherTemp{j-1,2}<gatherTemp{j,2}
                    tempA=gatherTemp{j-1,1};%交换两行
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
        
        %决定真实输出数量
        if outputNum%如果规定了输出图像数目      
                indexMax=min(count,outputNum);%输出数量为较小者
        else%如果没有规定输出图像数目，则选择梯度下降最陡的点之前的图像
            maxGrad=0;%初始化最大梯度
            for i=2:count
                if maxGrad<=gatherTemp{i-1,2}-gatherTemp{i,2}
                    maxGrad=gatherTemp{i-1,2}-gatherTemp{i,2};
                    indexMax=i-1;%记录此序号
                end
            end
        end
        
        %根据排列顺序决定输出顺序
        switch upper(outputSort)
            case 'SUCCESSION'%按照种子点检测顺序
                
            case 'QUANTITY'%按照内含像素数量输出
                outputImages=gatherTemp(1:indexMax,1)';
                return;
                
            case 'REALITY'%按照真实排序输出
                orderSign=cell2mat(gatherTemp(1:indexMax,3));%提取所有输出图片的顺序标号
                [rowCell,tform]=blindLayer(orderSign(:,1));%获取每行的坐标聚集       
                if ~isempty(rowCell) && ~isempty(tform)%排序成功，使用行列排序，若是失败则自动使用种子点检测顺序
                    for i=1:size(rowCell,2)%每一行的坐标迭代
                        for j=1:size(rowCell{i},1)%每一行的一列迭代
                            [~,index]=min(orderSign(tform{i},2));%找到最小的列坐标的序号
                            orderSign(tform{i}(index),2)=col+1;%将此坐标移出图外
                            outputImages=[outputImages,gatherTemp{tform{i}(index),1}];%拼接输出图像细胞数组
                        end
                    end
                    return;
                end
        end
        
        outputImages=gather(find(cell2mat(gather(:,2))>=gatherTemp{indexMax,2},indexMax),1)';%按照种子点检测顺序排序
    end
end