function outputImages = regionFeeding(inputImage,filter,range)
%regionFeeding:使用区域收缩法将灰度图像分割单例化
%inputImage:输入图像，可以为灰度图像或者二值图像
%filter:给定初始灰度阈值
%range:给定新像素允许灰度波动最大值
%outputImages:输出图像细胞数组，每个元胞都是一个单例图像
%version:1.0.2
%author:jinshuguangze
%data:4/12/2018

    [row,col]=size(inputImage);%获得原图像参数
    inputImage=im2double(inputImage);%将输入图像转成双精度
    outputImages{1}=ones(row,col);%默认输出
    count=0;%输出图像总数，默认为0
    
    for i=1:row
        for j=1:col
            if(inputImage(i,j)<=filter)                             
                x=i;%拷贝初始点
                y=j;
                right=y;%初始化图像范围值
                bottom=x;
                left=y;
                top=x;
                adv=inputImage(x,y);%设置初始平均灰度值
                set=[x,y,adv];%建立初始数组
                inputImage(x,y)=1;%将该点从原图中去除
                
                while 1
                    if(y<col && inputImage(x,y+1)<=adv+range)%右边有新连通域
                        y=y+1;
                    elseif(x<row && inputImage(x+1,y)<=adv+range)%下边有新连通域
                        x=x+1;
                    elseif(y>1 && inputImage(x,y-1)<=adv+range)%左边有新连通域
                        y=y-1;
                    elseif(x>1 && inputImage(x-1,y)<=adv+range)%上边有新连通域
                        x=x-1;
                    else%没有连通域，退出循环
                        break;
                    end
                                       
                    right=max(right,y);%更新图像范围值
                    bottom=max(bottom,x);         
                    left=min(left,y);
                    top=min(top,x);                  
                    h=inputImage(x,y);%获得此点灰度值
                    set=[set;x,y,h];%将数据存储进数组
                    adv=(adv*size(set,1)+h)/(size(set,1)+1);%重新计算灰度平均值
                    inputImage(x,y)=1;%将该点从原图中去除
                end
                
                %设定输出阈值，以过滤杂质
                if size(set,1)>200
                    count=count+1;%输出图像数量增加
                    outputImages{count}=ones(bottom-top+1,right-left+1);%背景色默认为白
                    for temp=1:size(set,1)%将位置信息与灰度输入进去
                        outputImages{count}(set(temp,1)-top+1,set(temp,2)-left+1)=set(temp,3);
                    end
                end
            end              
        end
    end
end
