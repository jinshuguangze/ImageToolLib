function outputImages = regionExpanding_RGB(inputImage,degree,varargin)
%regionExpanding_Gray:使用区域膨胀法将灰度图像分割单例化，并可使用edge函数额外辅助判定边界
%inputImage:输入图像，指定为RGB图像，且感兴趣区域为满足颜色较为单一
%degree:新像素允许灰度波动的范围，允许范围是0~0.5
%outputNum:希望输出的至多图像个数，如果不输出或输入0，则会基于像素点个数下降梯度智能选择图像个数
%estimated:感兴趣区域的灰度估计值，如果不输入，则会基于Otsu算法自动得到统计意义上的估计值
%method:识别边缘的方法，能使用‘Sobel’，‘Prewitt’，‘Roberts’，‘Log’，‘Zerocross’，’Canny‘，’Approxcanny‘这七种方法
%operator:二维膨胀聚合算子，能使用’Low‘，’Medium‘，’High‘，’Extra‘四种等级来使用对应的内建算子
%outputImages:输出图像细胞数组，每个元胞都是一个单例图像
%version:1.0.0
%author:jinshuguangze
%data:4/29/2018
    
    %入口检测
    p=inputParser;%构造检测器对象
    %输入图像，限定为RGB，且感兴趣区域最好为单色，若为多色，可以多次输入后取并集
    p.addRequired('inputImage',@(x)validateattributes(x,{'numeric'},...
        {'size',[NaN,NaN,3],'integer' ,'nonnegative'},'regionExpanding_RGB','inputImage',1));
    %单原色允许范围值，分三个通道限定为0到0.5之间的数，数字越小，运算越快
    p.addRequired('degree',@(x)validateattributes(x,{'double'},...
        {'size',[1,3],'>',0,'<=',1},'regionExpanding_Gray','degree',2));
    %输出图像的个数，如果不输入或者输入0，则默认输出包含像素个数梯度最大的点之前的所有图像
    p.addOptional('outputNum',0,@(x)validateattributes(x,{'numeric'},...
        {'scalar','integer','nonnegative'},'regionExpanding_Gray','outputNum',3));   
    %估计值数组，即感兴趣区域的RGB估计值，若缺失则使用Otsu算法获得的分界点减去输入的各个单原色允许范围值
    p.addOptional('estimated','None',@(x)validateattributes(x,{'double'},...
        {'size',[1,3],'>=',0,'<=',1},'regionExpanding_Gray','estimated',4));   
    %识别边缘的方法，支持所有在库函数’edge‘中出现的方法，默认不使用边界额外判定即'None'
    p.addParameter('method','None',@(x)any(validatestring(x,...
        {'None','Sobel','Prewitt','Roberts','Log','Zerocross','Canny','Approxcanny'},'regionExpanding_Gray','method',5)));
    %二维聚合算子，支持四种从小到大的范围，范围越小，运算越快，默认为’Low‘算子的四联通区域
    p.addParameter('operator','Low',@(x)any(validatestring(x,...
        {'Low','Medium','High','Extra'},'regionExpanding_Gray','operator',6)));
    p.parse(inputImage,degree,varargin{:});%检测  
    inputImage=p.Results.inputImage;%赋值
    degree=p.Results.degree;
    outputNum=p.Results.outputNum;
    estimated=p.Results.estimated;
    method=p.Results.method;
    operator=p.Results.operator;
    
    %预处理
    inputImage=im2double(inputImage);%将输入图像转成双精度
    [row,col,~]=size(inputImage);%获得原图像参数   
    stateImage=zeros(row,col);%初始化状态表
    looper=[1,2,3];%初始化循环器
    count=0;%初始化输出图像计数器
    gather={};%初始化存储所有输出图像的聚集数组
    %-->慢慢改把
    for i=1:size(degree,2)
        if degree(i)==1%如果某个单原色波动是全范围，那么忽略它<-改进循环里面去吧
        looper(i)=[];
        end
    end
    
    if strcmp(estimated,'None')%如果估计值没有输入
        thresh=graythresh(inputImage);%获取统计意义上的最优阈值
        if thresh>degree
            estimated=thresh-degree;%默认感兴趣区域为深色
        else
            estimated=0;%默认感兴趣区域为深色
        end
    end
    
    switch upper(operator)%二维聚合算子实例化
        case 'LOW'
            neibor=[-1 0;0 1;1 0;0 -1];
            
        case 'MEDIUM'
            neibor=[-1 0;0 1;1 0;0 -1;-1 -1;-1 1;1 1;1 -1];
            
        case 'HIGH'
            neibor=[-1 0;0 1;1 0;0 -1;-1 -1;-1 1;1 1;1 -1;0 -2;-2 0;0 2;2 0];
            
        case 'EXTRA'
            neibor=[-1 0;0 1;1 0;0 -1;-1 -1;-1 1;1 1;1 -1;0 -2;-2 0;0 2;2 0;
                2 -1;2 -2;1 -2;-1 -2;-2 -2;-2 -1;-2 1;-2 2;-1 2;1 2;2 2;2 1];
            
        otherwise%由于validatestring的特性，会接受一些奇怪的近似字符进来，此时只能设定为默认值
            neibor=[-1 0;0 1;1 0;0 -1];
    end
    
    if strcmp(method,'None') || size(neibor,1)>8%对边缘算法进行判断，如果聚合算子过大，则不适合使用边界辅助判断
        edgeImage=zeros(row,col);%不使用边界额外判定，edgeImgae是一幅0值图
    else
        edgeImage=edge(inputImage,method);%使用边界额外判定，初始化边缘表，是一幅逻辑图，其检测边缘为1
    end
    
    %找出满足条件的生长开始点
    for i=1:row
        for j=1:col
            if ~stateImage(i,j)%如果没有被检测
                if inputImage(i,j)>estimated+degree || inputImage(i,j)<estimated-degree%如果不满足阈值
                    stateImage(i,j)=1;%更新状态，不满足阈值
                else%如果满足灰度阈值
                    %初始化预设值    
                    handleList=[i,j,inputImage(i,j),3];%初始化待邻域检测列表，由于是从左到右检索，故初始trace值为3
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
                        
                        %对于邻域范围内所有的像素点扫描一遍
                        num=0;%初始化邻域内满足阈值的像素点的个数
                        for k=1:size(neibor,1)
                            x=xtag+neibor(k,1);%更新坐标
                            y=ytag+neibor(k,2);
                            inRange=x>=1 && y>=1 && x<=row && y<=col;%检测是否在图像范围内
                            if inRange && ~stateImage(x,y)%如果在范围内而且没有被扫描过
                                if edgeImage(x,y) && k==trace%如果是边缘点而且k是沿着轨迹方向，则跳过
                                    continue;
                                end
                                    
                                if inputImage(x,y)>adv+degree || inputImage(x,y)<adv-degree%如果不满足阈值
                                    stateImage(x,y)=1;%更新状态，不满足阈值
                                else%如果满足阈值
                                    stateImage(x,y)=2;%更新状态，未检测邻域
                                    num=num+1;%邻域内满足阈值的像素点的个数增加
                                    handleList=[x,y,inputImage(x,y),k;handleList];%加入待检测列表，并存储原始方向
                                    top=min(top,x);%更新图像范围值
                                    bottom=max(bottom,x);
                                    left=min(left,y);
                                    right=max(right,y);                                   
                                end
                            end       
                        end
                                      
                        %检测完后，对于所有满足条件的像素，进行色彩最接近比较
                        if num                  
                            [~,index]=min(abs(handleList(1:num,3)-adv));%找到最接近像素的序号
                            handleList([1,index],:)=handleList([index,1],:);%交换两行                         
                            adv=(adv*size(fulfilList,1)+handleList(1,3))/(size(fulfilList,1)+1);%重新计算平均值
                        end   
                    end
                    
                    %存入聚集数组并填入信息
                    count=count+1;%输出图像数量增加
                    if estimated>0.5%根据预期区域灰度来确定背景颜色
                        gather{count,1}=zeros(bottom-top+1,right-left+1);%背景色为黑
                    else
                        gather{count,1}=zeros(bottom-top+1,right-left+1);%背景色为白
                    end
                    gather{count,2}=size(fulfilList,1);%第二维存入像素点个数信息
                    for k=1:size(fulfilList,1)%填入图像色彩信息
                        gather{count,1}(fulfilList(k,1)-top+1,fulfilList(k,2)-left+1)=fulfilList(k,3);
                    end
                end
            end
        end
    end
    
    %处理输出图像
    if ~count%无图像，默认输出为空白图
        if estimated>0.5%根据预期区域灰度来确定空白色
            outputImages{1}=zeros(row,col);%空白色为黑
        else
            outputImages{1}=ones(row,col);%空白色为白
        end
    elseif count==1%只有一副图像，直接输出
        outputImages{1}=gather{1,1};
    else%有多幅图像，用冒泡排序降序排列
        for i=1:count
            for j=2:count
                if gather{j-1,2}<gather{j,2}
                    tempA=gather{j-1,1};%交换两行
                    tempB=gather{j-1,2};
                    gather{j-1,1}=gather{j,1};
                    gather{j-1,2}=gather{j,2};
                    gather{j,1}=tempA;
                    gather{j,2}=tempB;
                end
            end
        end
        
        if outputNum%如果规定了输出图像数目
            if count>outputNum%输出指定数量图像
                for i=1:outputNum
                    outputImages{i}=gather{i,1};
                end
            else%输出所有图像
                for i=1:count
                    outputImages{i}=gather{i,1};
                end
            end
        else%如果没有规定输出图像数目，则选择梯度下降最陡的点之前的图像
            maxGrad=0;%初始化最大梯度
            for i=2:count
                if maxGrad<gather{i-1,2}-gather{i,2}
                    maxGrad=gather{i-1,2}-gather{i,2};
                    indexMax=i-1;%记录此序号
                end
            end
            for i=1:indexMax
                outputImages{i}=gather{i,1};
            end
        end
    end
end