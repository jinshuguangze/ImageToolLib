classdef(Sealed) DynMemory%不允许继承
%DynMemory:一个动态内存类，实例化出来的数据类型能在循环中自动检测是否已满，
%                  并自动申请新的合适的内存，也提供便利的字段与函数以供手动检测对象内存是否足够
%TODO:
%1.了解事件类型（event），使用监听器模型来替代手动外部循环，全监听器，和部分监听器两种模型
%全监听器包含一个使用率模型，每当原大小和维度中的0被填充到别的值时，增加使用率比例，在使用率增加到
%Para时，会自动addMemory，但是占用内存或许较多；部分监听器只会监听在Para之外的数值变化，一旦有变化，
%会立即addMemory，这样可能不太准确，因为有可能在外部对值是从后部开始循环的
%2.做一个枚举键值对来存储type与实际类型
    properties%公开字段
        Value%存储数值
        %对象的值域存储在此字段中，
        %公开原因是需要外部访问，赋值
    end
    
    properties(SetAccess=private)%半私密字段
        OriginalSize%原始申请容量
        %半公开原因是需要内部赋值，外部访问
    end
    
    properties(GetAccess=private,SetAccess=private)%私密字段
        Type%对象类型
        %将在使用任何公开方法时自动更新，
        %私密原因是可能由于没有调用对象的方法，
        %而直接访问字段而导致信息错误
        %-1:未知
        %0:数组
        %1:结构体数组
        %2:细胞数组
    end
    
    properties(Constant)%常量字段
        Scale=0.9%默认长度比例值
        %常量原因是需要多个对象共享单个值且不能更改
    end
    
    
    methods%构造函数
        function dynObj = DynMemory(varargin)
        %DynMemory:申请一段内存，并在当内存不够的时候自动扩充
        %varargin:可变参数，可以输入一到三个参数，完整版本的参数分布是“行数，列数，数据类型”
        %dynObj:返回一个已经分配好内存的动态内存对象，里面多余的空间会被0填充
        %versin:1.0.2
        %author:jinshuguangze
        %data:4/15/2018
        %TODO:
        %1.首先读取matlab语言信息，然后根据语言读取system('systeminfo')读取信息得到内存
        %最大值后，根据matlab预设项得到RAM占比，然后确定数组大小的最大值，默认为最大大小为
        %intmax('uint16')，除了结构体数组以外，结构体数组最大上限为intmax('uint64')
        %2.增加一个参数确定预分配的数据类型
		%3.修改函数以适应构造函数类，将字段赋值
		%4.增加tall,table等类型
		%5.增加多维度支持

            switch nargin
                case 0%当输入参数不足时，弹出警告，创建对象失败
                    disp('创建对象失败，请输入至少一个参数！');    
                    return;

                case 1%当输入参数只为一个时，会默认生成数组，且参数只允许出现正数  
                    if isscalar(varargin{1}) && isnumeric(varargin{1}) && varargin{1}>0        
                        %此时动态内存对象被赋予为行向量，且最长长度为intmax('uint16')
                        if varargin{1}>intmax('uint16')%输入参数过大
                            dynObj.Value=zeros(1,intmax('uint16'));%创建对象						
                            disp(['参数1：列数过大，超过了',num2str(intmax('uint16')),...
								'，默认生成大小为1x',num2str(intmax('uint16'),'的数组。')]);             
                        else%输入参数在范围内
                            dynObj.Value=zeros(1,uint16(varargin{1}));%创建对象
                        end
                    else%如果输入的数字不为正数
                        disp('创建对象失败，参数1：列数必须为一个正数！');
                        return;
                    end
					dynObj.Type=0;%存储类型到字段，类型：数组

                case 2%当输入参数为两个时，允许出现两个正数或者正数加字符串
                    if isscalar(varargin{1}) && isnumeric(varargin{1}) && varargin{1}>0
                        if isscalar(varargin{2}) && isnumeric(varargin{2}) && varargin{2}>0%数字加数字
                            %此时动态内存对象被赋予为数组，且申请大小不超过intmax('uint16')
                            if varargin{1}*varargin{2}>intmax('uint16')%输入参数过大
                                dynObj.Value=zeros(intmax('uint8'),intmax('uint8'));%创建对象
								disp(['参数1：行数与参数2：列数的乘积过大，超过了',...
									num2str(intmax('uint16')),'，默认生成大小为',...
									num2str(intmax('uint8')),'x',num2str(intmax('uint8')),'的数组。']);
                            else%输入参数在范围内                 
                                dynObj.Value=zeros(uint16(varargin{1}),uint16(varargin{2}));%创建对象
                            end
							dynObj.Type=0;%存储类型到字段，类型：数组
                        elseif ischar(varargin{2})%数字加字符串
                            switch varargin{2}
                                case 'array'%此时动态内存对象被赋予为行向量，且最长长度为intmax('uint16')
                                    if varargin{1}>intmax('uint16')%输入参数过大
                                        dynObj.Value=zeros(1,intmax('uint16'));%创建对象
										disp(['参数1：列数过大，超过了',num2str(intmax('uint16')),...
											'，默认生成大小为1x',num2str(intmax('uint16'),'的数组。')]);      
                                    else%输入参数在范围内
                                        dynObj.Value=zeros(1,uint16(varargin{1}));%创建对象
                                    end
									dynObj.Type=0;%存储类型到字段，类型：数组
									
                                case 'struct'%此时动态内存对象被赋予为结构体行向量，最长长度为intmax('uint64')
                                    if varargin{1}>intmax('uint64')%输入参数过大
                                        dynObj.Value(1,intmax('uint64'))=struct;%创建对象,多维度支持后尝试用repmat
										disp(['参数1：列数过大，超过了',num2str(intmax('uint64')),...
											'，默认生成大小为1x',num2str(intmax('uint64'),'的结构体数组。')]);    
                                    else%输入参数在范围内
                                        dynObj.Value(1,uint64(varargin{1}))=struct;%创建对象
                                    end
									dynObj.Type=1;%存储类型到字段，类型：结构体数组

                                case 'cell'%此时动态内存对象被赋予为细胞行向量，且最长长度为intmax('uint16')
                                    if varargin{1}>intmax('uint16')%输入参数过大
                                        dynObj.Value=cell(1,intmax('uint16'));%创建对象
										disp(['参数1：列数过大，超过了',num2str(intmax('uint16')),...
											'，默认生成大小为1x',num2str(intmax('uint16'),'的细胞数组。')]); 
                                    else%输入参数在范围内
                                        dynObj.Value=cell(1,varargin{1});%创建对象
                                    end
									dynObj.Type=2;%存储类型到字段，类型：细胞数组
									
                                otherwise%字符串不是以上三种
                                    dynObj.Value=zeros(1,intmax('uint16'));%创建对象
                                    disp(['目前只支持''array''，''struct''，''cell''三种类型的动态内存申请',...
                                        '，默认生成大小为1x',num2str(intmax('uint16'),'的数组。')]); 
									dynObj.Type=0;%存储类型到字段，类型：数组	
                            end
                        else%第二个参数不满足条件
                            disp('创建对象失败，参数2：列数（数据类型）必须为一个正数（字符串）！');
                            return;
                        end
                    else%第一个参数不满足条件
                        disp('创建对象失败，参数1：列数必须为一个正数！');
                        return;
                    end

                case 3%当输入参数为三个时，顺序必须是数字，数字，字符串
                    if isscalar(varargin{1}) && isnumeric(varargin{1}) && varargin{1}>0 ...
                            && isscalar(varargin{2}) && isnumeric(varargin{2}) && varargin{2}>0 ...
                            && ischar(varargin{3})%满足正数正数字符串组合
                        switch varargin{3}
                            case 'array'%此时动态内存对象被赋予为数组，且申请大小不超过intmax('uint16')
                                if varargin{1}*varargin{2}>intmax('uint16')%输入参数过大
                                    dynObj.Value=zeros(intmax('uint8'),intmax('uint8'));%创建对象
									disp(['参数1：行数与参数2：列数的乘积过大，超过了',...
										num2str(intmax('uint16')),'，默认生成大小为',...
										num2str(intmax('uint8')),'x',num2str(intmax('uint8')),'的数组。']);
                                else%输入参数在范围内                 
                                    dynObj.Value=zeros(uint16(varargin{1}),uint16(varargin{2}));%创建对象
                                end
								dynObj.Type=0;%存储类型到字段，类型：数组

                            case 'struct'%此时动态内存对象被赋予为结构体数组，行数与列数都不超过intmax('uint64')
                                if varargin{1}>intmax('uint64') && varargin{2}<=intmax('uint64')%参数1过大
                                    dynObj.Value(intmax('uint64'),uint64(varargin{2}))=struct;%创建对象
                                    disp(['参数1：行数过大，超过了',num2str(intmax('uint64')),...
										'，默认生成大小为',num2str(intmax('uint64')),'x',...
										num2str(uint64(varargin{2})),'的结构体数组。']);
                                elseif varargin{1}<=intmax('uint64') && varargin{2}>intmax('uint64')%参数2过大
                                    dynObj.Value(uint64(varargin{1}),intmax('uint64'))=struct;%创建对象
                                    disp(['参数2：列数过大，超过了',num2str(intmax('uint64')),...
										'，默认生成大小为',num2str(uint64(varargin{1})),'x',...
										num2str(intmax('uint64')),'的结构体数组。']);
								elseif	varargin{1}>intmax('uint64') && varargin{2}>intmax('uint64')%参数1,2都过大
                                    dynObj.Value(intmax('uint64'),intmax('uint64'))=struct;%创建对象
                                    disp(['参数1：行数和参数2：列数都过大，都超过了',num2str(intmax('uint64')),...
										'，默认生成大小为',num2str(uint64(varargin{1})),'x',...
										num2str(intmax('uint64')),'的结构体数组。']);																								
                                else%输入参数在范围内
                                    dynObj.Value(uint64(varargin{1}),uint64(varargin{2}))=struct;%创建对象
                                end
								dynObj.Type=1;%存储类型到字段，类型：结构体数组
								
                            case 'cell'%此时动态内存对象被赋予为细胞数组，且申请大小不超过intmax('uint16')
                                if varargin{1}*varargin{2}>intmax('uint16')%输入参数过大
                                    dynObj.Value=cell(intmax('uint8'),intmax('uint8'));%创建对象
									disp(['参数1：行数与参数2：列数的乘积过大，超过了',...
										num2str(intmax('uint16')),'，默认生成大小为',...
										num2str(intmax('uint8')),'x',num2str(intmax('uint8')),'的细胞数组。']);
                                else%输入参数在范围内                 
                                    dynObj.Value=cell(uint16(varargin{1}),uint16(varargin{2}));%创建对象
                                end
								dynObj.Type=2;%存储类型到字段，类型：细胞数组

                            otherwise%字符串不是以上三种
                                dynObj.Value=zeros(intmax('uint8'),intmax('uint8'));%创建对象
								disp(['目前只支持''array''，''struct''，''cell''三种类型的动态内存申请',...
									'，默认生成大小为',num2str(intmax('uint8'),'x',...
									num2str(intmax('uint8')),'的数组。')]); 
								dynObj.Type=0;%存储类型到字段，类型：数组	
                        end
                    else%参数排列组合不满足条件
                        disp(['创建对象失败，'...
							'参数1：列数必须为一个正数，',...
                            '参数2：行数必须为一个正数，',...
                            '参数3：数据类型必须为一个字符串！']);
                        return;
                    end

                otherwise%当输入参数过多时
                    disp('创建对象失败，输入参数过多！');
                    return;
            end
			dynObj.OriginalSize=size(dynObj.Value);%保存原始大小到字段
        end	
    end
    
	
    methods%公开函数
        function dynObj=refresh(dynObj,varargin)
        %refresh:访问对象内内存末端最后一系列数字是否为0，如果有数字更改过，
		%		    则申请更大的内存有可能会因为本身数组最后一系列数字为0而刷新失败，
		%		    会因此而暂时降低效率，一旦有非0数字输入，会马上提高效率
		%dynObj:被处理的动态内存对象，可能有长度的扩容
		%varargin:可选的输入，可以设置循环检测的长度比例，范围在0~1之间，越接近1，
		%		      检测的范围就越小，当不输入时，默认为0.9
        %versin:1.0.0
        %author:jinshuguangze
        %data:4/17/2018	
		%TODO:考虑并非使用长度比例，而使用固定数值
		%考虑多维情况，可以输入多个参数
        %入口检测
        
            para=dynObj.Scale;%长度比例的默认值设置为Scale
            if nargin==1%不输入时，设置默认值
            elseif nargin==2%输入一个额外参数
                if varargin{1}>0 && varargin{1}<1%检测范围是否满足
                    para=varargin{1};
                else%不满足弹出提示，并设置成默认值
                    disp('参数1：长度比例不满足在0~1范围内，已设置成默认值：',num2str(para),'。');
                end
            else%输入参数过多
                disp('刷新对象失败，原因：输入参数过多！');
                return;
            end
			
			[row,col]=size(dynObj.Value);%获取对象行数和列数		
			switch dynObj.Type%对于对象的不同类型有不同处理			
				case 0%如果对象是数组
					for i=row:-1:ceil(para*row)
						for j=col:-1:ceil(para*col)
							if dynObj.Value(i,j)%访问数组该索引下的值是否为0
								dynObj=dynObj.addMemory;
                                return;
							end
						end
					end
					
				case 1%如果对象是结构体数组，有特殊性，要访问字段
					fields=fieldnames(dynObj.Value);
					if size(fields,1)%确保结构体数组至少有一个字段
						for k=1:size(fields,1)
							for i=row:-1:ceil(para*row)
								for j=col:-1:ceil(para*col)
									if ~isempty(getfield(dynObj.Value(i,j),fields{i,1}))%访问每个字段的值是否为空
										dynObj=dynObj.addMemory;
                                        return;
									end
								end
							end
						end
					end
					
				case 2%如果对象是细胞数组
					for i=row:-1:ceil(para*row)
						for j=col:-1:ceil(para*col)
							if ~isempty(dynObj.Value{i,j})%访问该细胞数组组元下的值是否为空
								dynObj=dynObj.addMemory;
                                return;
							end
						end
					end
					
				otherwise%如果对象是未知类型，除非遭到恶意篡改，否则不会发生
                    clear dynObj;
					disp('刷新对象失败，原因：对象状态异常，已经自毁！');						
					return;
			end
        end       
        
		
        function dynObj=addMemory(dynObj,varargin)
        %addMemory:由于函数是公开的，所以可以手动去申请更大的内存，
		%                  默认为增加行数，数值为初始申请内存的行数
        %dynObj:被处理的动态内存对象，长度已经增加
		%varargin:可选的输入，可以根据输入来设置增加值的大小，
		%             或者选择增加的方向是行或者列，或者都设置
        %versin:1.0.2
        %author:jinshuguangze
        %data:4/17/2018	
		%TODO:
		%1.多维度增加支持（而不是两维度）：('D1',2,'D2',4,'D5',9,10<-这个默认为前面确定维度的后一维，即D6)	
		%2.如果对象维度和大小改变了，cat函数会灵活调整，如果是dim方向上的拼接，则必须保证除了dim，其他大小都要满足	
		%	for i=1:nargin
		%		if ischar(varargin{i}) && ...字符拼接相关	
		
			dim=1;%方向默认为行数方向
			rowadd=dynObj.OriginalSize(1);%行数默认增加orignalRow
			coladd=0;%列数默认增加0
			if nargin==1%如果无参数输入，结果为默认			
			elseif nargin==2%如果有一个参数输入，有可能是一个决定增加方向的字符串，或者是决定增加数值的正数
				if ischar(varargin{1})%满足是个字符串
					if varargin{1}=='col'
						dim=1;%方向改为增加列数
					else
						disp('参数1：方向必须为''row''和''col''其中之一，已设置成默认值：第一维度。');
					end
				elseif isscalar(varargin{1}) && isnumeric(varargin{1}) && varargin{1}>0%满足是个正数
					rowadd=uint16(varargin{1});%修改增加行数
				else%如果不满足条件
					disp('增加内存失败，原因：参数1：方向（增加行数）必须为字符串（正数）！');
					return;
				end
			elseif nargin==3%如果有两个参数输入，必须为两个正数
				if isscalar(varargin{1}) && isnumeric(varargin{1}) && varargin{1}>0 ...
                    && isscalar(varargin{2}) && isnumeric(varargin{2}) && varargin{2}>0%两个正数
					rowadd=unit16(varargin{1});%设置行数增加值
					coladd=unit16(varargin{2});%设置列数增加值
				else
					disp('增加内存失败，原因：参数1：增加行数与参数2：增加列数必须都为正数！');
					return;
				end	
			else%参数输入过多
				disp('增加内存失败，原因：输入参数过多！');
				return;
			end
			
            switch dynObj.Type%对于对象的不同类型有不同处理
				case 0%如果对象是数组
					newMemory=zeros(dynObj.OriginalSize);
					
				case 1%如果对象是结构体数组
					newMemory=repmat(struct,dynObj.OriginalSize);
					
				case 2%如果对象是细胞数组
					newMemory=cell(dynObj.OriginalSize);
					
				otherwise
					dynObj.free;	
					disp('增加内存失败，原因：对象状态异常，已经自毁！');						
					return;
            end
			dynObj.Value=cat(dim,dynObj.Value,newMemory);%拼接数组			
        end                    
    end
    
    methods%set,get方法集合
        function value=get.Value(dynObj)
            value=dynObj.Value;
        end
        
        function dynObj=set.Value(dynObj,value)
            dynObj.Value=value;
        end
        
        function originalSize=get.OriginalSize(dynObj)
            originalSize=dynObj.OriginalSize;
        end
        
        function dynObj=set.OriginalSize(dynObj,originalSize)
            dynObj.OriginalSize=originalSize;
        end
        
        function type=get.Type(dynObj)
            type=dynObj.Type;
        end
        
        function dynObj=set.Type(dynObj,type)
            dynObj.Type=type;
        end     
    end
    
end