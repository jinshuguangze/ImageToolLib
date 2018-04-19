<<<<<<< HEAD
classdef(Sealed) DynMemory%不允许继承
%DynMemory:一个动态内存类，实例化出来的数据类型能在循环中自动检测是否已满，
%                  并自动申请新的合适的内存，也提供便利的字段与函数以供手动检测对象内存是否足够
%TODO:
%1.了解事件类型（event），使用监听器模型来替代手动外部循环，全监听器，和部分监听器两种模型
%全监听器包含一个使用率模型，每当原大小和维度中的0被填充到别的值时，增加使用率比例，在使用率增加到
%Para时，会自动addMemory，但是占用内存或许较多；部分监听器只会监听在Para之外的数值变化，一旦有变化，
%会立即addMemory，这样可能不太准确，因为有可能在外部对值是从后部开始循环的
%2.做一个枚举键值对来存储type与实际类型
%3.大整改，全部适用validateattribute & inputParser实现
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
		%2.增加tall,table等类型

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
		%varargin:可选的输入，可以设置循环检测的长度比例或者检测固定长度，
		%			  如果绝对值小于1，则是按照长度比例，否则是按照固定长度
		%			  如果是负数，则从头开始检测而不是从尾部开始检测，
		%		      如果不输入，则会使用默认值，如果只输入一个值，那么会优先设置
		%			  行数，并尝试将列数和行数参数变成一致，如果失败，则列数会设置成默认值
        %versin:1.0.2
        %author:jinshuguangze
        %data:4/17/2018	
			
			dynObj.checkType;%对对象的值域进行类型检查
			[row,col]=size(dynObj.Value);%获取对象行数和列数
			
			p=inputParser;%构造入口检验对象
			p.addOptional('rowScale',dynObj.Scale,@(x)validateattributes(x,{'numeric'},...
				{'scalar','nonzero','>',-row,'<',row},'refresh','rowScale',1));			
			p.addOptional('colScale',dynObj.Scale,@(x)validateattributes(x,{'numeric'},...
				{'scalar','nonzero','>',-col,'<',col},'refresh','colScale',2));

			p.parse(varargin{:});	
			rScale=p.Results.rowScale;%得到入口检验后的值
			cScale=p.Results.colScale;
			
			if nargin==2%如果只输入一个数值，则列数参数尝试等于行数参数
				if rScale<col%尝试成功
					cScale=rScale;
				else%尝试失败，设置成默认值
					cScale=dynObj.Scale;
				end
			end							
			
			if rScale>=1%构造基于行数参数的对象值域循环器
				rloop=row:-1:row-ceil(rScale);
			elseif rScale>0 && rScale<1
				rloop=row:-1:ceil(row*rScale);
			elseif rScale>-1 && rScale<0
				rloop=1:floor(-row*rScale);
			else
				rloop=1:floor(-rScale);
			end
			
			if cScale>=1%构造基于列数参数的对象值域循环器
				cloop=col:-1:col-ceil(cScale);
			elseif cScale>0 && cScale<1
				cloop=col:-1:ceil(col*cScale);
			elseif cScale>-1 && cScale<0
				cloop=1:floor(-col*cScale);
			else
				cloop=1:floor(-cScale);
			end
			
			switch dynObj.Type%对于对象的不同类型有不同处理
				case 0%数组
					if dynObj.Value(rloop,cloop)
						dynObj=dynObj.addMemory;
						return;
					end
				
				case 1%结构体数组
					fields=fieldnames(dynObj.Value);
					kloop=1:size(fields,1);%构造访问所有字段的循环器
					if size(fields,1)
						if ~isempty(getfield(dynObj.Value(rloop,cloop),fields{kloop,1}))%访问每个字段的值是否为空
							dynObj=dynObj.addMemory;
							return;
						end
					end
					
				case 2%细胞数组
					if ~isempty(dynObj.Value{rloop,cloop})
						dynObj=dynObj.addMemory;
						return;
					end	
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
            end
			dynObj.Value=cat(dim,dynObj.Value,newMemory);%拼接数组			
        end                    
    end
    
	methods(Access=private)%私密方法
		function type=checkType(dynObj)
		%checkType:适用于内部再判断对象的类型，会自动改变Type属性至当前对象类型
		%dynObj:被检测的动态内存对象
		%type:返回当前的类型
		%versin:1.0.0
        %author:jinshuguangze
		%data:4/19/2018	
		
			if ~ismatrix(dynObj.Value)%非数组判定为未知类型
				type=-1;
				clear dynObj;
				disp('对象类型错误，已经自我清除！');
				return;
			elseif isstruct(dynObj.Value)%结构体数组
				type=1;
			elseif iscell(dynObj.Value)%细胞数组
				type=2;
			else%其他所有统称为普通数组
				type=0;
			end
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
=======
classdef(Sealed) DynMemory%������̳�
%DynMemory:һ����̬�ڴ��࣬ʵ����������������������ѭ�����Զ�����Ƿ�������
%                  ���Զ������µĺ��ʵ��ڴ棬Ҳ�ṩ�������ֶ��뺯���Թ��ֶ��������ڴ��Ƿ��㹻
%TODO:
%1.�˽��¼����ͣ�event����ʹ�ü�����ģ��������ֶ��ⲿѭ����ȫ���������Ͳ��ּ���������ģ��
%ȫ����������һ��ʹ����ģ�ͣ�ÿ��ԭ��С��ά���е�0����䵽���ֵʱ������ʹ���ʱ�������ʹ�������ӵ�
%Paraʱ�����Զ�addMemory������ռ���ڴ����϶ࣻ���ּ�����ֻ�������Para֮�����ֵ�仯��һ���б仯��
%������addMemory���������ܲ�̫׼ȷ����Ϊ�п������ⲿ��ֵ�ǴӺ󲿿�ʼѭ����
%2.��һ��ö�ټ�ֵ�����洢type��ʵ������
    properties%�����ֶ�
        Value%�洢��ֵ
        %�����ֵ��洢�ڴ��ֶ��У�
        %����ԭ������Ҫ�ⲿ���ʣ���ֵ
    end
    
    properties(SetAccess=private)%��˽���ֶ�
        OriginalSize%ԭʼ��������
        %�빫��ԭ������Ҫ�ڲ���ֵ���ⲿ����
    end
    
    properties(GetAccess=private,SetAccess=private)%˽���ֶ�
        Type%��������
        %����ʹ���κι�������ʱ�Զ����£�
        %˽��ԭ���ǿ�������û�е��ö���ķ�����
        %��ֱ�ӷ����ֶζ�������Ϣ����
        %-1:δ֪
        %0:����
        %1:�ṹ������
        %2:ϸ������
    end
    
    properties(Constant)%�����ֶ�
        Scale=0.9%Ĭ�ϳ��ȱ���ֵ
        %����ԭ������Ҫ�����������ֵ�Ҳ��ܸ���
    end
    
    
    methods%���캯��
        function dynObj = DynMemory(varargin)
        %DynMemory:����һ���ڴ棬���ڵ��ڴ治����ʱ���Զ�����
        %varargin:�ɱ��������������һ�����������������汾�Ĳ����ֲ��ǡ��������������������͡�
        %dynObj:����һ���Ѿ�������ڴ�Ķ�̬�ڴ�����������Ŀռ�ᱻ0���
        %versin:1.0.2
        %author:jinshuguangze
        %data:4/15/2018
        %TODO:
        %1.���ȶ�ȡmatlab������Ϣ��Ȼ��������Զ�ȡsystem('systeminfo')��ȡ��Ϣ�õ��ڴ�
        %���ֵ�󣬸���matlabԤ����õ�RAMռ�ȣ�Ȼ��ȷ�������С�����ֵ��Ĭ��Ϊ����СΪ
        %intmax('uint16')�����˽ṹ���������⣬�ṹ�������������Ϊintmax('uint64')
        %2.����һ������ȷ��Ԥ�������������
		%3.�޸ĺ�������Ӧ���캯���࣬���ֶθ�ֵ
		%4.����tall,table������
		%5.���Ӷ�ά��֧��

            switch nargin
                case 0%�������������ʱ���������棬��������ʧ��
                    disp('��������ʧ�ܣ�����������һ��������');    
                    return;

                case 1%���������ֻΪһ��ʱ����Ĭ���������飬�Ҳ���ֻ�����������  
                    if isscalar(varargin{1}) && isnumeric(varargin{1}) && varargin{1}>0        
                        %��ʱ��̬�ڴ���󱻸���Ϊ���������������Ϊintmax('uint16')
                        if varargin{1}>intmax('uint16')%�����������
                            dynObj.Value=zeros(1,intmax('uint16'));%��������						
                            disp(['����1���������󣬳�����',num2str(intmax('uint16')),...
								'��Ĭ�����ɴ�СΪ1x',num2str(intmax('uint16'),'�����顣')]);             
                        else%��������ڷ�Χ��
                            dynObj.Value=zeros(1,uint16(varargin{1}));%��������
                        end
                    else%�����������ֲ�Ϊ����
                        disp('��������ʧ�ܣ�����1����������Ϊһ��������');
                        return;
                    end
					dynObj.Type=0;%�洢���͵��ֶΣ����ͣ�����

                case 2%���������Ϊ����ʱ����������������������������ַ���
                    if isscalar(varargin{1}) && isnumeric(varargin{1}) && varargin{1}>0
                        if isscalar(varargin{2}) && isnumeric(varargin{2}) && varargin{2}>0%���ּ�����
                            %��ʱ��̬�ڴ���󱻸���Ϊ���飬�������С������intmax('uint16')
                            if varargin{1}*varargin{2}>intmax('uint16')%�����������
                                dynObj.Value=zeros(intmax('uint8'),intmax('uint8'));%��������
								disp(['����1�����������2�������ĳ˻����󣬳�����',...
									num2str(intmax('uint16')),'��Ĭ�����ɴ�СΪ',...
									num2str(intmax('uint8')),'x',num2str(intmax('uint8')),'�����顣']);
                            else%��������ڷ�Χ��                 
                                dynObj.Value=zeros(uint16(varargin{1}),uint16(varargin{2}));%��������
                            end
							dynObj.Type=0;%�洢���͵��ֶΣ����ͣ�����
                        elseif ischar(varargin{2})%���ּ��ַ���
                            switch varargin{2}
                                case 'array'%��ʱ��̬�ڴ���󱻸���Ϊ���������������Ϊintmax('uint16')
                                    if varargin{1}>intmax('uint16')%�����������
                                        dynObj.Value=zeros(1,intmax('uint16'));%��������
										disp(['����1���������󣬳�����',num2str(intmax('uint16')),...
											'��Ĭ�����ɴ�СΪ1x',num2str(intmax('uint16'),'�����顣')]);      
                                    else%��������ڷ�Χ��
                                        dynObj.Value=zeros(1,uint16(varargin{1}));%��������
                                    end
									dynObj.Type=0;%�洢���͵��ֶΣ����ͣ�����
									
                                case 'struct'%��ʱ��̬�ڴ���󱻸���Ϊ�ṹ���������������Ϊintmax('uint64')
                                    if varargin{1}>intmax('uint64')%�����������
                                        dynObj.Value(1,intmax('uint64'))=struct;%��������,��ά��֧�ֺ�����repmat
										disp(['����1���������󣬳�����',num2str(intmax('uint64')),...
											'��Ĭ�����ɴ�СΪ1x',num2str(intmax('uint64'),'�Ľṹ�����顣')]);    
                                    else%��������ڷ�Χ��
                                        dynObj.Value(1,uint64(varargin{1}))=struct;%��������
                                    end
									dynObj.Type=1;%�洢���͵��ֶΣ����ͣ��ṹ������

                                case 'cell'%��ʱ��̬�ڴ���󱻸���Ϊϸ�����������������Ϊintmax('uint16')
                                    if varargin{1}>intmax('uint16')%�����������
                                        dynObj.Value=cell(1,intmax('uint16'));%��������
										disp(['����1���������󣬳�����',num2str(intmax('uint16')),...
											'��Ĭ�����ɴ�СΪ1x',num2str(intmax('uint16'),'��ϸ�����顣')]); 
                                    else%��������ڷ�Χ��
                                        dynObj.Value=cell(1,varargin{1});%��������
                                    end
									dynObj.Type=2;%�洢���͵��ֶΣ����ͣ�ϸ������
									
                                otherwise%�ַ���������������
                                    dynObj.Value=zeros(1,intmax('uint16'));%��������
                                    disp(['Ŀǰֻ֧��''array''��''struct''��''cell''�������͵Ķ�̬�ڴ�����',...
                                        '��Ĭ�����ɴ�СΪ1x',num2str(intmax('uint16'),'�����顣')]); 
									dynObj.Type=0;%�洢���͵��ֶΣ����ͣ�����	
                            end
                        else%�ڶ�����������������
                            disp('��������ʧ�ܣ�����2���������������ͣ�����Ϊһ���������ַ�������');
                            return;
                        end
                    else%��һ����������������
                        disp('��������ʧ�ܣ�����1����������Ϊһ��������');
                        return;
                    end

                case 3%���������Ϊ����ʱ��˳����������֣����֣��ַ���
                    if isscalar(varargin{1}) && isnumeric(varargin{1}) && varargin{1}>0 ...
                            && isscalar(varargin{2}) && isnumeric(varargin{2}) && varargin{2}>0 ...
                            && ischar(varargin{3})%�������������ַ������
                        switch varargin{3}
                            case 'array'%��ʱ��̬�ڴ���󱻸���Ϊ���飬�������С������intmax('uint16')
                                if varargin{1}*varargin{2}>intmax('uint16')%�����������
                                    dynObj.Value=zeros(intmax('uint8'),intmax('uint8'));%��������
									disp(['����1�����������2�������ĳ˻����󣬳�����',...
										num2str(intmax('uint16')),'��Ĭ�����ɴ�СΪ',...
										num2str(intmax('uint8')),'x',num2str(intmax('uint8')),'�����顣']);
                                else%��������ڷ�Χ��                 
                                    dynObj.Value=zeros(uint16(varargin{1}),uint16(varargin{2}));%��������
                                end
								dynObj.Type=0;%�洢���͵��ֶΣ����ͣ�����

                            case 'struct'%��ʱ��̬�ڴ���󱻸���Ϊ�ṹ�����飬������������������intmax('uint64')
                                if varargin{1}>intmax('uint64') && varargin{2}<=intmax('uint64')%����1����
                                    dynObj.Value(intmax('uint64'),uint64(varargin{2}))=struct;%��������
                                    disp(['����1���������󣬳�����',num2str(intmax('uint64')),...
										'��Ĭ�����ɴ�СΪ',num2str(intmax('uint64')),'x',...
										num2str(uint64(varargin{2})),'�Ľṹ�����顣']);
                                elseif varargin{1}<=intmax('uint64') && varargin{2}>intmax('uint64')%����2����
                                    dynObj.Value(uint64(varargin{1}),intmax('uint64'))=struct;%��������
                                    disp(['����2���������󣬳�����',num2str(intmax('uint64')),...
										'��Ĭ�����ɴ�СΪ',num2str(uint64(varargin{1})),'x',...
										num2str(intmax('uint64')),'�Ľṹ�����顣']);
								elseif	varargin{1}>intmax('uint64') && varargin{2}>intmax('uint64')%����1,2������
                                    dynObj.Value(intmax('uint64'),intmax('uint64'))=struct;%��������
                                    disp(['����1�������Ͳ���2�����������󣬶�������',num2str(intmax('uint64')),...
										'��Ĭ�����ɴ�СΪ',num2str(uint64(varargin{1})),'x',...
										num2str(intmax('uint64')),'�Ľṹ�����顣']);																								
                                else%��������ڷ�Χ��
                                    dynObj.Value(uint64(varargin{1}),uint64(varargin{2}))=struct;%��������
                                end
								dynObj.Type=1;%�洢���͵��ֶΣ����ͣ��ṹ������
								
                            case 'cell'%��ʱ��̬�ڴ���󱻸���Ϊϸ�����飬�������С������intmax('uint16')
                                if varargin{1}*varargin{2}>intmax('uint16')%�����������
                                    dynObj.Value=cell(intmax('uint8'),intmax('uint8'));%��������
									disp(['����1�����������2�������ĳ˻����󣬳�����',...
										num2str(intmax('uint16')),'��Ĭ�����ɴ�СΪ',...
										num2str(intmax('uint8')),'x',num2str(intmax('uint8')),'��ϸ�����顣']);
                                else%��������ڷ�Χ��                 
                                    dynObj.Value=cell(uint16(varargin{1}),uint16(varargin{2}));%��������
                                end
								dynObj.Type=2;%�洢���͵��ֶΣ����ͣ�ϸ������

                            otherwise%�ַ���������������
                                dynObj.Value=zeros(intmax('uint8'),intmax('uint8'));%��������
								disp(['Ŀǰֻ֧��''array''��''struct''��''cell''�������͵Ķ�̬�ڴ�����',...
									'��Ĭ�����ɴ�СΪ',num2str(intmax('uint8'),'x',...
									num2str(intmax('uint8')),'�����顣')]); 
								dynObj.Type=0;%�洢���͵��ֶΣ����ͣ�����	
                        end
                    else%����������ϲ���������
                        disp(['��������ʧ�ܣ�'...
							'����1����������Ϊһ��������',...
                            '����2����������Ϊһ��������',...
                            '����3���������ͱ���Ϊһ���ַ�����']);
                        return;
                    end

                otherwise%�������������ʱ
                    disp('��������ʧ�ܣ�����������࣡');
                    return;
            end
			dynObj.OriginalSize=size(dynObj.Value);%����ԭʼ��С���ֶ�
        end	
    end
    
	
    methods%��������
        function dynObj=refresh(dynObj,varargin)
        %refresh:���ʶ������ڴ�ĩ�����һϵ�������Ƿ�Ϊ0����������ָ��Ĺ���
		%		    �����������ڴ��п��ܻ���Ϊ�����������һϵ������Ϊ0��ˢ��ʧ�ܣ�
		%		    ����˶���ʱ����Ч�ʣ�һ���з�0�������룬���������Ч��
		%dynObj:������Ķ�̬�ڴ���󣬿����г��ȵ�����
		%varargin:��ѡ�����룬��������ѭ�����ĳ��ȱ�������Χ��0~1֮�䣬Խ�ӽ�1��
		%		      ���ķ�Χ��ԽС����������ʱ��Ĭ��Ϊ0.9
        %versin:1.0.0
        %author:jinshuguangze
        %data:4/17/2018	
		%TODO:���ǲ���ʹ�ó��ȱ�������ʹ�ù̶���ֵ
		%���Ƕ�ά�������������������
        %��ڼ��
        
            para=dynObj.Scale;%���ȱ�����Ĭ��ֵ����ΪScale
            if nargin==1%������ʱ������Ĭ��ֵ
            elseif nargin==2%����һ���������
                if varargin{1}>0 && varargin{1}<1%��ⷶΧ�Ƿ�����
                    para=varargin{1};
                else%�����㵯����ʾ�������ó�Ĭ��ֵ
                    disp('����1�����ȱ�����������0~1��Χ�ڣ������ó�Ĭ��ֵ��',num2str(para),'��');
                end
            else%�����������
                disp('ˢ�¶���ʧ�ܣ�ԭ������������࣡');
                return;
            end
			
			[row,col]=size(dynObj.Value);%��ȡ��������������		
			switch dynObj.Type%���ڶ���Ĳ�ͬ�����в�ͬ����			
				case 0%�������������
					for i=row:-1:ceil(para*row)
						for j=col:-1:ceil(para*col)
							if dynObj.Value(i,j)%��������������µ�ֵ�Ƿ�Ϊ0
								dynObj=dynObj.addMemory;
                                return;
							end
						end
					end
					
				case 1%��������ǽṹ�����飬�������ԣ�Ҫ�����ֶ�
					fields=fieldnames(dynObj.Value);
					if size(fields,1)%ȷ���ṹ������������һ���ֶ�
						for k=1:size(fields,1)
							for i=row:-1:ceil(para*row)
								for j=col:-1:ceil(para*col)
									if ~isempty(getfield(dynObj.Value(i,j),fields{i,1}))%����ÿ���ֶε�ֵ�Ƿ�Ϊ��
										dynObj=dynObj.addMemory;
                                        return;
									end
								end
							end
						end
					end
					
				case 2%���������ϸ������
					for i=row:-1:ceil(para*row)
						for j=col:-1:ceil(para*col)
							if ~isempty(dynObj.Value{i,j})%���ʸ�ϸ��������Ԫ�µ�ֵ�Ƿ�Ϊ��
								dynObj=dynObj.addMemory;
                                return;
							end
						end
					end
					
				otherwise%���������δ֪���ͣ������⵽����۸ģ����򲻻ᷢ��
                    clear dynObj;
					disp('ˢ�¶���ʧ�ܣ�ԭ�򣺶���״̬�쳣���Ѿ��Ի٣�');						
					return;
			end
        end       
        
		
        function dynObj=addMemory(dynObj,varargin)
        %addMemory:���ں����ǹ����ģ����Կ����ֶ�ȥ���������ڴ棬
		%                  Ĭ��Ϊ������������ֵΪ��ʼ�����ڴ������
        %dynObj:������Ķ�̬�ڴ���󣬳����Ѿ�����
		%varargin:��ѡ�����룬���Ը�����������������ֵ�Ĵ�С��
		%             ����ѡ�����ӵķ������л����У����߶�����
        %versin:1.0.2
        %author:jinshuguangze
        %data:4/17/2018	
		%TODO:
		%1.��ά������֧�֣���������ά�ȣ���('D1',2,'D2',4,'D5',9,10<-���Ĭ��Ϊǰ��ȷ��ά�ȵĺ�һά����D6)	
		%2.�������ά�Ⱥʹ�С�ı��ˣ�cat�������������������dim�����ϵ�ƴ�ӣ�����뱣֤����dim��������С��Ҫ����	
		%	for i=1:nargin
		%		if ischar(varargin{i}) && ...�ַ�ƴ�����	
		
			dim=1;%����Ĭ��Ϊ��������
			rowadd=dynObj.OriginalSize(1);%����Ĭ������orignalRow
			coladd=0;%����Ĭ������0
			if nargin==1%����޲������룬���ΪĬ��			
			elseif nargin==2%�����һ���������룬�п�����һ���������ӷ�����ַ����������Ǿ���������ֵ������
				if ischar(varargin{1})%�����Ǹ��ַ���
					if varargin{1}=='col'
						dim=1;%�����Ϊ��������
					else
						disp('����1���������Ϊ''row''��''col''����֮һ�������ó�Ĭ��ֵ����һά�ȡ�');
					end
				elseif isscalar(varargin{1}) && isnumeric(varargin{1}) && varargin{1}>0%�����Ǹ�����
					rowadd=uint16(varargin{1});%�޸���������
				else%�������������
					disp('�����ڴ�ʧ�ܣ�ԭ�򣺲���1��������������������Ϊ�ַ�������������');
					return;
				end
			elseif nargin==3%����������������룬����Ϊ��������
				if isscalar(varargin{1}) && isnumeric(varargin{1}) && varargin{1}>0 ...
                    && isscalar(varargin{2}) && isnumeric(varargin{2}) && varargin{2}>0%��������
					rowadd=unit16(varargin{1});%������������ֵ
					coladd=unit16(varargin{2});%������������ֵ
				else
					disp('�����ڴ�ʧ�ܣ�ԭ�򣺲���1���������������2�������������붼Ϊ������');
					return;
				end	
			else%�����������
				disp('�����ڴ�ʧ�ܣ�ԭ������������࣡');
				return;
			end
			
            switch dynObj.Type%���ڶ���Ĳ�ͬ�����в�ͬ����
				case 0%�������������
					newMemory=zeros(dynObj.OriginalSize);
					
				case 1%��������ǽṹ������
					newMemory=repmat(struct,dynObj.OriginalSize);
					
				case 2%���������ϸ������
					newMemory=cell(dynObj.OriginalSize);
					
				otherwise
					dynObj.free;	
					disp('�����ڴ�ʧ�ܣ�ԭ�򣺶���״̬�쳣���Ѿ��Ի٣�');						
					return;
            end
			dynObj.Value=cat(dim,dynObj.Value,newMemory);%ƴ������			
        end                    
    end
    
    methods%set,get��������
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
    
>>>>>>> 45c2f446b7e2900776a7fea54c7ce62d99658884
end