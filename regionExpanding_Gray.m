function outputImages = regionExpanding_Gray(inputImage,degree,varargin)
%regionExpanding:使用区域膨胀法将灰度图像分割单例化
%inputImage:输入图像，可以为灰度图像或者二值图像或者RGB
%filter:给定初始灰度阈值
%degree:给定新像素允许灰度波动最大值
%outputImages:输出图像细胞数组，每个元胞都是一个单例图像
%versin:1.0.5
%author:jinshuguangze
%data:4/13/2018
%State0:未扫描的像素点
%State1:已扫描但不满足阈值的像素点
%State2:已扫描，满足阈值但待检测邻域的像素点
%State3:已扫描，满足阈值且已检测邻域的像素点
%TODO:写个自动分配内存器(√)，支持RGB等，取消filter参数改为自动判断
       
    %入口检测
    p=inputParse;%构造检测器对象
    %输入图像，限定为灰度图像，且需要分割的图像为深色，支持多种灰度等级的灰度图像
    p.addRequired('inputImage',@(x)validateattributes(x,{'numeric'},...
        {'2d','integer','positive'},'regionExpanding_Gray'),'inputImage',1);
    %灰度允许范围值，限定为0到0.5之间的数，数字越小，运算越快
    p.addRequired('degree',@(x)validateattributes(x,{'double'},...
        {'sclar','>',0,'<',0.5},'regionExpanding_Gray'),'degree',2);
    %输出图像的个数，如果不输入或者输入0，则默认输出包含像素个数梯度最大的点之前的所有图像
    p.addOptional('number',0,@(x)validateattributes(x,{'numeric'},...
        {'sclar','integer','positive'},'regionExpanding_Gray'),'number',3);   
    %灰度估计值，如果不输入，则使用Otsu算法获得得灰度减去输入的灰度允许范围值
    p.addOptional('estimated','None',@(x)validateattributes(x,{'double'},...
        {'sclar','>=',0,'<=',1},'regionExpanding_Gray'),'estimated',4);   
    %识别边缘的方法，支持所有在库函数’edge‘中出现的方法，默认为‘Canny’方法
    p.addParameter('method','Robert',@(x)any(validatestring(x,...
        {'Sobel','Prewitt','Roberts','Log','Zerocross','Canny','Approxcanny'})));
    %二维聚合算子，支持四种从小到大的范围，范围越小，运算越快，默认为’Low‘算子的四联通区域
    p.addParameter('operator','Low',@(x)any(validatestring(x,...
        {'Low','Medium','High','Extra'})));
    p.parse(inputImage,degree,varargin{:});%检测  
    inputImage=p.Results.inputImgae;%赋值
    degree=p.Results.degree;
    number=p.Results.number;
    estimated=p.Results.estimated;
    method=p.Results.method;
    operator=p.Results.operator;
    
    %预处理
    inputImage=im2double(inputImage);%将输入图像转成双精度
    [row,col]=size(inputImage);%获得原图像参数   
    stateImage=zeros(row,col);%初始化状态表
    edgeImage=edge(inputImage,method);%初始化边缘表
    count=0;%初始化输出图像计数器
    
    if estimated=='None'%如果估计值没有输入
        thresh=graythresh(inputImage);%获取统计意义上的最优阈值
        if thresh>degree
            estimated=thresh-degree;
        else
            estimated=0;
        end
    end
    
    switch operator%二维聚合算子实例化
        case 'Low'
            neibor=[-1 0;0 1;1 0;0 -1];
            
        case 'Medium'
            neibor=[-1 0;0 1;1 0;0 -1;-1 -1;-1 1;1 1;1 -1];
            
        case 'High'
            neibor=[-1 0;0 1;1 0;0 -1;-1 -1;-1 1;1 1;1 -1;0 -2;-2 0;0 2;2 0];
            
        case 'Extra'
            neibor=[-1 0;0 1;1 0;0 -1;-1 -1;-1 1;1 1;1 -1;0 -2;-2 0;0 2;2 0;
                2 -1;2 -2;1 -2;-1 -2;-2 -2;-2 -1;-2 1;-2 2;-1 2;1 2;2 2;2 1];
    end
    
    %找出满足条件的生长开始点
    for i=1:row
        for j=1:col
            if ~stateImage(i,j)%如果没有被检测
                if inputImage(i,j)>estimated+degree || inputImage(i,j)<estimated-degree%如果不满足阈值
                    stateImage(i,j)=1;%更新状态，不满足阈值
                else%如果满足灰度阈值
                    %初始化预设值    
                    handleList=[i,j,inputImage(i,j)];%初始化待邻域检测列表
                    fulfilList=[];%初始化完成邻域检测的列表
                    gather=cell;%初始化存储所有输出图像的聚集数组
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
                        handleList(1,:)=[];%将这个像素从待检测列表中移除
                        fulfilList=[xtag,ytag,inputImage(xtag,ytag);fulfilList];%更新完成邻域检测的列表  
                        
                        %对于邻域范围内所有的像素点扫描一遍
                        num=0;%初始化邻域内满足阈值的像素点的个数
                        for k=1:size(neibor,1)
                            x=xtag+neibor(k,1);%更新坐标
                            y=ytag+neibor(k,2);
                            inRange=x>=1 && y>=1 && x<=row && y<=col;%检测是否在图像范围内
                            if inRange && ~stateImage(x,y)%如果在范围内而且没有被扫描过
                                if inputImage(x,y)>adv+degree || inputImage(x,y)<adv-degree%如果不满足阈值
                                    stateImage(x,y)=1;%更新状态，不满足阈值
                                else%如果满足阈值
                                    stateImage(x,y)=2;%更新状态，未检测邻域
                                    num=num+1;%邻域内满足阈值的像素点的个数增加
                                    handleList=[x,y,inputImage(x,y);handleList];%加入待检测列表
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
                    gather{count,1}=ones(bottom-top+1,right-left+1);%背景色默认为白
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
        outputImages{1}=ones(row,col);
    elseif count==1%只有一副图像，直接输出
        outputImages=gather{1,1};
    else%有多幅图像，用冒泡排序由大到小排下来
        for m=1:count
            for n=2:count
                if gather{n-1,2}<gather{n,2}
                    gather{[n-1,n],:}=gather{[n,n-1],:};%交换两行
                end
            end
        end
        
        if number%如果规定了输出图像数目
            if count>number%输出指定数量图像
                outputImages=gather{1:number,1};
            else%输出所有图像
                outputImages=gather{:,1};
            end
        else%如果没有规定输出图像数目，则选择梯度下降最陡的点之前的图像
            maxGrad=0;%初始化最大梯度
            for v=2:count
                if maxGrad<gather{v-1,2}-gather{v,2}
                    maxGrad=gather{v-1,2}-gather{v,2};
                    indexMax=v-1;%记录此序号
                end
            end
            outputImages=gather{1:indexMax,1};              
        end
    end
end

