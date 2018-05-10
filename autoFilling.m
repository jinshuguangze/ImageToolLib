function outputImage = autoFilling(inputImage,varargin)
%autoReducing:自动填充图像中的空隙点
%inputImage:可以输入单例图像或图像细胞行向量
%operator:邻域算子等级，可以选择‘Low‘，’Medium‘，’High‘，’Extra‘四个等级
%outputImage:自动填充后的图像细胞数组
%version:1.0.4
%author:jinshuguangze
%data:5/7/2018

    outputImage={};%初始化输出
    if iscell(inputImage) && isrow(inputImage)%将单例图和转换为细胞数组处理表
        handleList=inputImage;
    elseif ismatrix(inputImage)
        handleList{1}=inputImage;
    else
        disp('输入类型错误！');
        return;
    end

    p=inputParser;%构造入口检测对象
    p.addOptional('operator','Low',@(x)any(validatestring(x,...
        {'Low','Medium','High','Extra'},'autoFilling','operator',2)));
    p.parse(varargin{:});
    operator=p.Results.operator;
    
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
    
    for i=1:size(handleList,2)
        validateattributes(handleList{i},{'numeric'},{'3d','nonnegative'},'autoFixing');%图像入口检测
        handleList{i}=im2double(handleList{i});%将图像双精度化
        [row,col,~]=size(handleList{i});%获取图像长宽
        while true
            done=false;
            for j=1:row
                for k=1:col
                    if handleList{i}(j,k,:)==1%搜索白点
                        count=0;%初始化数量
                        adv=0;%初始化平均值
                        for l=1:size(neibor,1)
                            if (j==1 && neibor(l,1)<0) ||...%在边缘时，某个方向会被忽略
                                    (j==row && neibor(l,1)>0)||...
                                    (k==1 && neibor(l,2)<0)||...
                                    (k==col && neibor(l,2)>0)
                                continue;
                            end
                            
                            x=j+neibor(l,1);%重定位坐标值
                            y=k+neibor(l,2);
                            if handleList{i}(x,y,:)~=1%如果邻域不为白   
                                adv=(adv*count+handleList{i}(x,y,:))/(count+1);%重新计算平均值，adv是1*1*1或者1*1*3的数组
                                count=count+1;
                            end
                        end
                        
                        if count>size(neibor,1)/2%超过算子数量的一般
                            done=true;
                            handleList{i}(j,k,:)=adv(:);%将平均值赋予像素点
                        end
                    end
                end
            end
            
            if ~done%如果没有点填充，则跳出循环
                break;
            end                      
        end
    end
    
    outputImage=handleList;%输出
end