function mutishow(varargin)
%mutishow:用于更快的弹出对比图像窗口
%varargin:可变参数，输入数量不定的图像，支持普通数组与对应一维细胞数组集合
%version:1.0.6
%author:jinshuguangze
%data:3/22/2018

    %判断输入图像数量
    if(~nargin)
        disp('无参数输入！');
        return;
    else
        figure, %打开图像窗口
        count=nargin;%初始默认元素中没有细胞数组
        
        %遍历一遍获得图像总数
        for i=1:nargin
            if(iscell(varargin{i}))
                count=count+size(varargin{i},2)-1;%总数增加相应值
            end            
        end
           
        row=floor(sqrt(count));%行数
        columns=ceil(count/row);%列数
        point=0;%图像指针
               
        %第二遍遍历排布图像
        for i=1:nargin           
            if(iscell(varargin{i}))%如果元素是细胞数组，则遍历显示
                for j=1:size(varargin{i},2)%遍历细胞数组
                    point=point+1;%指针移动
                    subplot(row,columns,point);
                    imshow(varargin{i}{j});                    
                end
            else%如果是普通数组，则直接显示
                point=point+1;%指针移动
                subplot(row,columns,point);
                imshow(varargin{i});                
            end
        end
    end
end

