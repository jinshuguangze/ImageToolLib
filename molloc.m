function variable = molloc(varargin)
%molloc:申请一段内存，并在当内存不够的时候自动扩充
%varargin:可变参数，可以输入一到三个参数，完整版本的参数分布是“行数，列数，数据类型”
%variable:返回一个已经分配好内存的变量，里面多余的空间会被0填充
%versin:1.0.2
%author:jinshuguangze
%data:4/15/2018
%TODO:首先读取matlab语言信息，然后根据语言读取system('systeminfo')读取信息得到内存
%最大值后，根据matlab预设项得到RAM占比，然后确定数组大小的最大值，默认为最大大小为
%intmax('uint16')，除了结构体数组以外，结构体数组最大上限为intmax('uint64')

    switch nargin
        case 0%当输入参数不足时，弹出警告
            variable=0;%默认输出
            disp('请输入至少一个参数！');    
            return;
            
        case 1%当输入参数只为一个时，只允许出现正数  
            if isscalar(varargin{1}) && isnumeric(varargin{1}) && varargin{1}>0        
                %此时变量被赋予为行向量，且最长长度为intmax('uint16')
                if varargin{1}>intmax('uint16')%输入参数过大
                    variable=zeros(1,intmax('uint16'));%默认输出
                    disp(['参数1：列数过大，最大不能超过',num2str(intmax('uint16')),'！']);             
                    return;
                else%输入参数在范围内
                    variable=zeros(1,uint16(varargin{1}));
                end
            else%如果输入的数字不为正数
                variable=zeros(1,intmax('uint16'));%默认输出
                disp('参数1：列数必须是一个正数！');
                return;
            end
            
        case 2%当输入参数为两个时，允许出现两个正数或者正数加字符串
            if isscalar(varargin{1}) && isnumeric(varargin{1}) && varargin{1}>0
                if isscalar(varargin{2}) && isnumeric(varargin{2}) && varargin{2}>0%数字加数字
                    %此时变量被赋予为数组，且申请大小不超过intmax('uint16')
                    if varargin{1}*varargin{2}>intmax('uint16')%输入参数过大
                        variable=zeros(intmax('uint8'),intmax('uint8'));%默认输出
                        disp(['参数1：行数与参数2：列数的乘积过大，最大不能超过',...
                            num2str(intmax('uint16')),'！']);
                        return;
                    else%输入参数在范围内                 
                        variable=zeros(uint16(varargin{1}),uint16(varargin{2}));
                    end
                elseif ischar(varargin{2})%数字加字符串
                    switch varargin{2}
                        case 'array'%此时变量被赋予为行向量，且最长长度为intmax('uint16')
                            if varargin{1}>intmax('uint16')%输入参数过大
                                variable=zeros(1,intmax('uint16'));%默认输出
                                disp(['参数1：列数过大，最大不能超过',num2str(intmax('uint16')),'！']);
                                return;
                            else%输入参数在范围内
                                variable=zeros(1,uint16(varargin{1}));
                            end
                            
                        case 'struct'%此时变量被赋予为结构体行向量，最长长度为intmax('uint64')
                            if varargin{1}>intmax('uint64')%输入参数过大
                                variable(1,intmax('uint64'))=struct();%默认输出
                                disp(['参数1：列数过大，最大不能超过',num2str(intmax('uint64')),'！']);
                                return;
                            else%输入参数在范围内
                                variable(1,uint64(varargin{1}))=struct();
                            end
                            
                        case 'cell'%此时变量被赋予为细胞行向量，且最长长度为intmax('uint16')
                            if varargin{1}>intmax('uint16')%输入参数过大
                                variable=cell(1,intmax('uint16'));%默认输出
                                variable(:)={0};
                                disp(['参数1：列数过大，最大不能超过',num2str(intmax('uint16')),'！']);
                                return;
                            else%输入参数在范围内
                                variable=cell(1,varargin{1});
                                variable(:)={0};
                            end
                            
                        otherwise%字符串不是以上三种
                            variable=zeros(1,intmax('uint16'));%默认输出
                            disp('目前只支持''array''，''struct''，''cell''三种类型的动态内存申请！');
                            return;
                    end
                else%第二个参数不满足条件
                    variable=zeros(1,intmax('uint16'));%默认输出
                    disp('参数2：数据类型请输入一个正数或者字符串！');
                    return;
                end
            else%第一个参数不满足条件
                variable=zeros(1,intmax('uint16'));%默认输出
                disp('参数1：列数必须为正数！');
                return;
            end
                
        case 3%当输入参数为三个时，顺序必须是数字，数字，字符串
            if isscalar(varargin{1}) && isnumeric(varargin{1}) && varargin{1}>0 ...
                    && isscalar(varargin{2}) && isnumeric(varargin{2}) && varargin{2}>0 ...
                    && ischar(varargin{3})%满足正数正数字符串组合
                switch varargin{3}
                    case 'array'%此时变量被赋予为数组，且申请大小不超过intmax('uint16')
                        if varargin{1}*varargin{2}>intmax('uint16')%输入参数过大
                            variable=zeros(intmax('uint8'),intmax('uint8'));%默认输出
                            disp(['参数1：行数与参数2：列数的乘积过大，最大不能超过',...
                                num2str(intmax('uint16')),'！']);
                            return;
                        else%输入参数在范围内                 
                            variable=zeros(uint16(varargin{1}),uint16(varargin{2}));
                        end                       
                        
                    case 'struct'%此时变量被赋予为结构体数组，行数与列数都不超过intmax('uint64')
                        if varargin{1}>intmax('uint64')%参数1过大
                            variable(intmax('uint64'),intmax('uint64'))=struct();%默认输出
                            disp(['参数1：行数过大，最大不能超过',num2str(intmax('uint64')),'！']);
                            return;
                        elseif varargin{2}>intmax('uint64')%参数2过大
                            variable(intmax('uint64'),intmax('uint64'))=struct();%默认输出
                            disp(['参数2：列数过大，最大不能超过',num2str(intmax('uint64')),'！']);
                            return;                       
                        else%输入参数在范围内
                            variable(uint64(varargin{1}),uint64(varargin{2}))=struct();
                        end
                        
                    case 'cell'%此时变量被赋予为细胞数组，且申请大小不超过intmax('uint16')
                        if varargin{1}*varargin{2}>intmax('uint16')%输入参数过大
                            variable=cell(intmax('uint8'),intmax('uint8'));%默认输出
                            variable(:)={0};
                            disp(['参数1：行数与参数2：列数的乘积过大，最大不能超过',...
                                num2str(intmax('uint16')),'！']);
                            return;
                        else%输入参数在范围内                 
                            variable=cell(uint16(varargin{1}),uint16(varargin{2}));
                            variable(:)={0};
                        end    

                    otherwise%字符串不是以上三种
                        variable=zeros(intmax('uint8'),intmax('uint8'));%默认输出
                        disp('目前只支持''array''，''struct''，''cell''三种类型的动态内存申请！');
                        return;
                end
            else%参数排列组合不满足条件
                variable=zeros(intmax('uint8'),intmax('uint8'));%默认输出
                disp(['参数1：列数必须为正数，',...
                    '参数2：行数必须为正数，',...
                    '参数3：数据类型必须为字符串！']);
                return;
            end
            
        otherwise%当输入参数过多时
            variable=0;%默认输出
            disp('输入参数过多！');
            return;
    end
end

