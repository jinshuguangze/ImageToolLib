function varargout = dataAnalyzer(varargin)
%getParam:得到角果面积与体积等参数
%varargin:可变参数，输入的单例图像或单例图像细胞数组
%varargout:可变参数，输出每个对应单例图像的相应参数的结构体
%versin:1.0.0
%author:jinshuguangze
%data:4/13/2018

    if ~nargin
        disp('请输入单例图像！');
        return;
    else
        for i=1:nargin
            if iscell(varargin{i})%如果是单例图像细胞数组，建立一个对应大小的细胞数组，再分析数据
                data=cell(size(varargin{i}));
            end           
            %TODO：开始分析数据
            varargin{i}
            %未完成，待做
        end            
    end        
end

