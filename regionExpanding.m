function outputImages = regionExpanding(inputImage,varargin)
%regionExpanding:使用区域膨胀法将灰度图像分割单例化
%inputImage:输入图像，可以为灰度图像或者二值图像或者RGB
%filter:给定初始灰度阈值
%degree:给定新像素允许灰度波动最大值
%outputImages:输出图像细胞数组，每个元胞都是一个单例图像
%version:1.0.6
%author:jinshuguangze
%data:4/13/2018
%TODO:写个自动分配内存器(√)，入口检查(easyGG)，支持RGB等，取消filter参数改为自动判断
       %%regionExpanding_Gray(inputImage,灰度下限,灰度上限,容纳波动)
       
    %入口检测
    p=inputParse;%构造检测对象
    p.addRequired('inputImage',@(x)validateattributes(x,{'numeric'},...%输入图像，限定为灰度图像
        {'2d','integer','positive'},'regionExpanding_Gray'),'inputImage',1);%支持多种灰度等级的灰度图像
    
    %输出图像的个数，如果不输入或者输入0，则默认输出梯度最大
    p.addOptional('number',@(x)validateattributes(x,{'numeric'},...
        {'sclar','integer','positive'},'regionExpanding_Gray'),'number',2);
    
    p.addOptional('estimated',@(x)validateattributes(x,{'double'},...%灰度估计值
        {'real','sclar','>=',0,'<=',1},'regionExpanding_Gray'),'estimated',3);
    p.addOptional('degree',@(x)validateattributes(x,{'double'},...%灰度范围值
        {'real','sclar','>',0,'<',0.5},'regionExpanding_Gray'),'degree',4);
    p.addParameter('method','Canny',@(x)any(validatestring(x,...
        {'Sobel','Prewitt','Roberts','Log','Zerocross','Approxcanny'})));%计算边缘的方式，支持多种‘Sobel’,'PR...')如果在算子合并过程中出现时边缘的情况，
    %存储变量告知像素，这个方向不再检测
    p.addParameter('low','medium','high','extra');%检测算子。支持‘low（4）’，‘miedum（8）’，‘high（12）’，‘extra（16）’四种算子

    %预处理
    inputImage=im2double(inputImage);%将输入图像转成双精度
    [row,col]=size(inputImage);%获得原图像参数   
    stateImage=zeros(row,col);%初始化状态表
    %State0:未扫描的像素点
    %State1:已扫描但不满足阈值的像素点
    %State2:已扫描，满足阈值但待检测邻域的像素点
    %State3:已扫描，满足阈值且已检测邻域的像素点
    count=0;%初始化输出图像计数器
    
    %可调参部分
    neibor=[-1 0;1 0;0 -1;0 1];%邻域范围表，可扩展与更改   
    outputImages{1}=ones(row,col);%默认输出为全白图像
    
    for i=1:row
        for j=1:col
            if ~stateImage(i,j)%如果没有被检测
                if inputImage(i,j)>filter%如果不满足阈值
                    stateImage(i,j)=1;%更新状态，不满足阈值
                else%如果满足灰度阈值
                    %初始化预设值    
                    handleList=[i,j,inputImage(i,j)];%初始化待邻域检测列表
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
                        handleList(1,:)=[];%将这个像素从待检测列表中移除
                        fulfilList=[xtag,ytag,inputImage(xtag,ytag);fulfilList];%更新完成邻域检测的列表  
                        
                        %对于邻域范围内所有的像素点扫描一遍
                        num=0;%初始化邻域内满足阈值的像素点的个数
                        for k=1:size(neibor,1)
                            x=xtag+neibor(k,1);%更新坐标
                            y=ytag+neibor(k,2);
                            inRange=x>=1 && y>=1 && x<=row && y<=col;%检测是否在图像范围内
                            if inRange && ~stateImage(x,y)%如果在范围内而且没有被扫描过
                                if inputImage(x,y)>adv+degree%如果不满足阈值
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
                    
                    %设置阈值，去除杂质
                    if size(fulfilList,1)>3000
                        count=count+1;%输出图像数量增加
                        outputImages{count}=ones(bottom-top+1,right-left+1);%背景色默认为白
                        for k=1:size(fulfilList,1)
                            outputImages{count}...%填入图像色彩信息
                                (fulfilList(k,1)-top+1,fulfilList(k,2)-left+1)=fulfilList(k,3);
                        end
                    end                  
                end
            end
        end
    end
end

