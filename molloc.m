function variable = molloc(varargin)
%molloc:申请一段内存，并在当内存不够的时候自动扩充
%varargin:可变参数，可以输入一到三个参数，完整版本的参数分布是“行数，列数，数据类型”
%variable:返回一个已经分配好内存的变量，里面多余的空间会被0填充
%versin:1.0.1
%author:jinshuguangze
%data:4/15/2018

    variable=0;%默认输出  
    switch nargin
        case 0%当输入参数不足时，弹出警告
            disp('请输入至少一个参数！');
            return;
            
        case 1%当输入参数只为一个时，只允许出现数字
            if isinteger(varargin{1}) && varargin{1}
                variable=zeros(1,varargin{1});%此时变量被赋予为一个行向量
            else%如果输入的数字不为正整数
                disp('参数1：列数必须是一个正整数！');
                return;
            end
            
        case 2%当输入参数为两个时，允许出现两个数字或者数字加字符串
            if isinteger(varargin{1}) && varargin{1}%第一个参数必须为正整数
                if isinteger(varargin{2}) && varargin{2}%数字加数字
                    variable=zeros(varargin{1},varargin{2});%此时变量被赋予为一个数组
                elseif ischar(varargin{2})%数字加字符串
                    switch varargin{2}
                        case 'array'%此时变量被赋予为一个行向量
                            variable=zeros(1,varargin{1});
                            
                        case 'struct'%此时变量被赋予为一个结构体行向量
                            variable(1,varargin{1})=struct();
                            
                        case 'cell'%此时变量被赋予为一个细胞行向量
                            variable=cell(1,varargin{1});
                            variable(:)={0};
                            
                        otherwise%字符串不是以上三种
                            disp('目前只支持''array''，''struct''，''cell''三种类型的动态内存申请！');
                            return;
                    end
                else%第二个参数不满足条件
                    disp('参数2：数据类型请输入一个正整数或者字符串！');
                    return;
                end
            else%第一个参数不满足条件
                disp('参数1：列数必须为正整数！');
                return;
            end
                
        case 3%当输入参数为三个时，顺序必须是数字，数字，字符串
            if isinteger(varargin{1}) && varargin{1} && isinteger(varargin{2})...
                     && varargin{2} && ischar(varargin{3})%满足数字数字字符串组合
                switch varargin{3}
                    case 'array'%此时变量被赋予为一个数组
                        variable=zeros(varargin{1},varargin{2});
                        
                    case 'struct'%此时变量被赋予为一个结构体数组
                        variable(varargin{1},varargin{2})=struct();
                        
                    case 'cell'%此时变量被赋予为一个细胞数组
                        variable=cell(varargin{1},varargin{2});
                        variable(:)={0};
                        
                    otherwise%字符串不是以上三种
                        disp('目前只支持''array''，''struct''，''cell''三种类型的动态内存申请！');
                        return;
                end
            else%参数排列组合不满足条件
                disp(['参数1：列数必须为正整数，',...
                    '参数2：行数必须为正整数，',...
                    '参数3：数据类型必须为字符串！']);
                return;
            end
            
        otherwise%当输入参数过多时
            disp('输入参数过多！');
            return;
    end
end

