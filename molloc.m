function variable = molloc(varargin)
%molloc:申请一段内存，并在当内存不够的时候自动扩充
%size:要申请的内存估计值，当超过这个上限后，申请的内存会再次增加这个值
%variable:返回一个已经分配好内存的变量，里面多余的空间会被0填充
%versin:1.0.0
%author:jinshuguangze
%data:4/15/2018

    variable=0;%默认输出  
    switch nargin
        case 1%当输入参数只为一个时，只允许出现数字
            if isinteger(varargin{1})
                variable=zeros(1,varargin{1});%此时变量被赋予为一个行向量
            else
                %jiaoyu
            end
            
        case 2%当输入参数为两个时，允许出现两个数字或者数字加字符串
            if isinteger(varargin{1})
                if isinteger(varargin{2})
                    variable=zeros(varargin{1},varargin{2});%此时变量被赋予为一个数组
                elseif ischar(varargin{2})
                    switch varargin{2}
                        case 'array'
                        case 'struct'
                        case 'cell'
                        otherwise
                            %jiaoyu
                    end
                else
                    %jiaoyu
                end
            else
                %jiaoyu
            end
                
        case 3%当输入参数为三个时，顺序必须是数字，数字，字符串
            if isinteger(varargin{1}) && isinteger(varargin{2}) && ischar(varargin{3})
                switch varargin{3}
                    case 'array'
                    case 'struct'
                    case 'cell'
                    otherwise
                        %jiaoyu
                end
            else
                %jiaoyu
            end
            
        otherwise%当输入参数为其他时，弹出该函数使用信息
            %jiaoyu
    end
end

