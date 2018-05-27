function data = dataAnalyzer(varargin)
%dataAnalyzer:得到角果面积与体积等参数
%varargin:可变参数，输入的单例图像或单例图像细胞数组
%data:输出每个对应单例图像的相应参数的结构体
%version:1.0.3
%author:jinshuguangze
%data:4/13/2018
%TODO:增加更多输出参数，将data设置成可变长度

    if ~nargin%入口检测
        disp('请输入单例图像！');
        return;
    else
        for i=1:nargin%对于每个输入，都分析一遍           
            %分析数据，循环在细胞数组中的每个元素，如果直接是单例图像则只循环一次
            for s=1:size(varargin{i},2)             
                if iscell(varargin{i})%区分当前对象是否是细胞数组
                    vstruct=varargin{i}{s};
                else
                    vstruct=varargin{i};
                end
                [row,col]=size(vstruct);%获得图像大小
                area=0;%初始化体积计数器
                total=0;%初始化总体计数器
                for j=1:row
                    count=0;%初始化行计数器
                    for k=1:col
                        if(vstruct(j,k))
                            count=count+1;%行计数器增加
                        end
                    end
                    area=area+pi*(count^2)/4;%面积计算与累加
                    total=total+count;%计入像素点总数
                end
                if iscell(varargin{i})%分别计算面积和体积
                    data{i}{s}.acreage=total;%细胞数组单例图像面积
                    data{i}{s}.volume=area;%细胞数组单例图像体积
                else
                    data{i}.acreage=total;%普通单例图像面积
                    data{i}.volume=area;%普通单例图像体积
                end
            end
        end
    end
end

