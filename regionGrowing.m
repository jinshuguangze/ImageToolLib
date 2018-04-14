function outputImages = regionGrowing(inputImage,filter,range)
%regionGrowing:使用区域生长法将灰度图像分割单例化
%inputImage:输入图像，可以为灰度图像或者二值图像
%filter:给定初始灰度阈值
%range:给定新像素允许灰度波动最大值
%outputImages:输出图像细胞数组，每个元胞都是一个单例图像
%versin:1.0.1
%author:jinshuguangze
%data:4/10/2018

    [row,col]=size(inputImage);%获得原图像参数
    inputImage=im2double(inputImage);%将输入图像转成双精度
    outputImages{1}=zeros(row,col);%默认输出
    count=0;%输出图像总数，默认为0
    for i=1:row
        for j=1:col
            if(inputImage(i,j)<filter)                
                Stack=[i,j,inputImage(i,j)];%模拟堆栈
                adv=inputImage(i,j);%设置初始平均灰度值
                inputImage(i,j)=1;%防止死循环，确认区域后，将其置1
                
                Point=0;%栈指针
                miny=i;%联通区域范围绝对坐标初始化
                maxy=i;
                minx=j;
                maxx=j;

                %区域生长法
                while Point<size(Stack,1)%当栈指针位于栈尾部时，终止循环                    
                    y=Stack(Point+1,1);%使用临时变量以节约访问成本
                    x=Stack(Point+1,2);
                    if(x>1 && inputImage(y,x-1)<=adv+range)%对于四种不同的状态，进行分类
                        state=1;%左边有新的连通域
                    elseif(x<col && inputImage(y,x+1)<=adv+range)
                        state=2;%右边有新的连通域
                    elseif(y<row && inputImage(y+1,x)<=adv+range)
                        state=3;%下边有新的连通域
                    else
                        state=0;%无连通域
                    end
                    
                    switch state
                        case 0
                            Point=Point+1;%当该像素点没有区域联通时，返回上一级
                        case 1
                            x=x-1;
                           if(minx>x)%如果左边界扩展，则更新数据minx
                               minx=x;
                           end
                        case 2
                            x=x+1;
                            if(maxx<x)%如果右边界扩展，则更新数据maxx
                                maxx=x;
                            end
                        case 3
                            y=y+1;
                            if(maxy<y)%如果左边界扩展，则更新数据maxy
                                maxy=y;
                            end
                    end
                    
                    %如果有联通域，则更新状态
                    if(state)
                        z=inputImage(y,x);%获取灰度
                        adv=(adv*size(Stack,1)+z)/(size(Stack,1)+1);%重新计算灰度平均值

                        if(Point)%由于当Point为0时有其特殊性，故分类讨论
                            Stack=[[y,x,z];Stack(Point+1:end,:)];%入栈
                        else
                            Stack=[Stack(1:Point,:);[y,x,z];Stack(Point+1:end,:)];%入栈
                        end                   
                        inputImage(y,x)=1;%防止死循环，确认区域后，将其置1
                    end
                end
                
                %设定输出阈值，以过滤杂质
                if size(Stack,1)>100
                    count=count+1;%输出图像数量增加
                    outputImages{count}=ones(maxy-miny+1,maxx-minx+1);%背景色默认为白
                    for temp=1:size(Stack,1)%将位置信息与灰度输入进去
                        outputImages{count}(Stack(temp,1)-miny+1,...
                            Stack(temp,2)-minx+1)=Stack(temp,3);
                    end
                end
            end
        end
    end
end
