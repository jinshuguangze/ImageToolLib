classdef(Sealed) DynMemory<handle%不允许继承，超类是抽象类handle
%DynMemory:一个动态内存类，实例化出来的二维数据类型能在循环中自动检测是否已满，
%                  并自动申请新的合适的内存，也可以手动开启增加内存
%TODO:
%1.引入事件类型（event），使用监听器模型来替代手动外部循环，全监听器，和部分监听器两种模型
%全监听器包含一个使用率模型，每当原大小和维度中的0被填充到别的值时，增加使用率比例，在使用率增加到
%Para时，会自动addMemory，但是占用内存或许较多；部分监听器只会监听在Para之外的数值变化，一旦有变化，
%会立即addMemory，这样可能不太准确，因为有可能在外部对值是从后部开始循环的
%2.做一个枚举键值对来存储type与实际类型，已失败，暂时没有好的思路
%3.继续尝试使用any()来实现多维检测功能

    properties%公开字段
        %存储数值，对象的值域存储在此字段中，并且有限制条件防止非预期更改
        Value{mustBeNonempty,mustBeMatrix}=0
    end
    
    properties(SetAccess=private)%半私密字段
        OriginalSize%原始申请容量
    end
    
    properties(GetAccess=private,SetAccess=private)%私密字段
        Type%对象类型
        %将在使用任何公开方法时自动更新，
        %私密原因是可能由于没有调用对象的方法，
        %而直接访问字段而导致信息错误
        %0:数组
        %1:结构体数组
        %2:细胞数组
    end
    
    properties(Constant)%常量字段
        Scale=0.9%默认长度比例值
    end
    
    methods%构造函数
        function dynObj = DynMemory(varargin)
        %DynMemory:申请一段内存，并在当内存不够的时候可以实现自动扩充
        %varargin:可变参数，可以输入至多三个参数，完整版本的参数分布是“行数，列数，数据类型”
        %dynObj:返回一个已经分配好内存的动态内存对象，里面多余的空间会被0填充
        %versin:1.0.5
        %author:jinshuguangze
        %data:4/15/2018
        %TODO:
        %1.首先读取matlab语言信息，然后根据语言读取system('systeminfo')读取信息得到内存
        %最大值后，根据matlab预设项得到RAM占比，然后确定数组大小的最大值，默认为最大大小为
        %intmax('uint16')，除了结构体数组以外，结构体数组最大上限为intmax('uint64')
		%2.增加tall,table等类型

            p=inputParser;%构造检测器对象
            p.addOptional('row',1,@(x)validateattributes(x,{'numeric'},...
                {'scalar','integer','positive'},'DynMemory','row',1));
            p.addOptional('col',1,@(x)validateattributes(x,{'numeric'},...
                {'scalar','integer','positive'},'DynMemory','col',2));
            p.addOptional('type','array',@(x)any(validatestring(x,...
                {'array','struct','cell'},'DynMemory','type',3)));            
            p.parse(varargin{:});
            
            row=p.Results.row;%得到入口检验后的值
            col=p.Results.col;
            type=p.Results.type;
            
            dynObj.OriginalSize=[row,col];%保存原始大小
            switch type%不同的类型的不同申请内存方法
                case 'array'%数组       
                    dynObj.Value=zeros(row,col);%创建对象，归零
                    dynObj.Type=0;%设置对象类型
                    
                case 'struct'%结构体数组              
                    temp(row,col)=struct;%创建对象，置空
                    dynObj.Value=temp;%由于MATLAB实现机制问题，只能使用临时变量
                    dynObj.Type=1;%设置对象类型
                    
                case 'cell'%细胞数组   
                    dynObj.Value=cell(row,col);%创建对象，置空
                    dynObj.Type=2;%设置对象类型
            end
        end
    end
    
    methods%公开函数
        function dynObj=refresh(dynObj,varargin)
        %refresh:访问对象内内存末端最后一系列数字是否无变化，如果有数字更改过，
		%		    则申请更大的内存有可能会因为本身数组最后一系列数字为0而刷新失败，
		%		    会因此而暂时降低效率，一旦有非0数字输入，会马上提高效率
		%dynObj:被处理的动态内存对象，可能有长度的扩容
		%varargin:可选的输入，可以设置循环检测的长度比例或者检测固定长度，
		%			  如果绝对值小于1，则是按照长度比例，否则是按照固定长度
		%			  如果是负数，则从头开始检测而不是从尾部开始检测，
		%		      如果不输入，则会使用默认值，如果只输入一个值，那么会优先设置
		%			  行数，并尝试将列数和行数参数变成一致，如果失败，则列数会设置成默认值
        %versin:1.0.5
        %author:jinshuguangze
        %data:4/17/2018	
        
            dynObj.checkType;%对对象的值域进行类型检查   

			[row,col]=size(dynObj.Value);%获取对象行数和列数
			
			p=inputParser;%构造检测器对象
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
                    checkArray=dynObj.Value(rloop,cloop);%创建检测数组
                    %使用逐循环而不是数组的全局控制有助于程序效率的提高，会在检测一个数字成功之后就return
                    for i=1:size(checkArray,1)
                        for j=1:size(checkArray,2)
                            if checkArray(i,j)%检测
                                %根据输入的符号判断添加内存的方向
                                dynObj.addMemory(dynObj.OriginalSize(1)*rScale/abs(rScale));
                                return;
                            end
                        end
                    end
				
                case 1%结构体数组
                    fields=fieldnames(dynObj.Value);
                    if ~size(fields,1)%确保至少有一个字段
                        return;
                    end
                    %创建检测数组
                    checkArray=dynObj.Value(rloop,cloop);
                    %使用逐循环而不是数组的全局控制有助于程序效率的提高，会在检测一个数字成功之后就return
                    for i=1:size(checkArray,1)
                        for j=1:size(checkArray,2)
                            for k=1:size(fields,1)%构造访问所有字段的循环器
                                % 检测是否为空，同时忽略一个应该是编译器不清楚getfield是库函数而不是get函数的错误
                                if ~isempty(getfield(checkArray(:),fields{k,1}))%#ok<GFLD>
                                    %根据输入的符号判断添加内存的方向
                                    dynObj.addMemory(dynObj.OriginalSize(1)*rScale/abs(rScale));
                                    return;
                                end
                            end
                        end
                    end
					
				case 2%细胞数组
                    checkArray=dynObj.Value{rloop,cloop};%创建检测数组
                    %使用逐循环而不是数组的全局控制有助于程序效率的提高，会在检测一个数字成功之后就return
                    for i=1:size(checkArray,1)
                        for j=1:size(checkArray,2)                   
                            if ~isempty(checkArray(:))%检测
                                %根据输入的符号判断添加内存的方向
                                dynObj.addMemory(dynObj.OriginalSize(1)*rScale/abs(rScale));
                                return;
                            end
                        end
                    end
			end
        end       
        	
        function dynObj=addMemory(dynObj,varargin)
        %addMemory:由于函数是公开的，所以可以手动去申请更大的内存，
		%                  默认为增加行数，数值为初始申请内存的行数，
        %                  如果想增加列数，尝试参数中填写(0,col)，
        %                  支持输入负数，在此情况下，会从对应维度的头部增加内存而不是尾部
        %dynObj:被处理的动态内存对象，长度已经增加
		%varargin:可选的输入，可以根据输入来设置增加值的大小，
		%             或者选择增加的方向是行或者列，或者都设置
        %versin:1.0.5
        %author:jinshuguangze
        %data:4/17/2018	
        
            dynObj.checkType;%对对象的值域进行类型检查
            
            p=inputParser;%构造检测器对象
            p.addOptional('rowadd',dynObj.OriginalSize(1),@(x)validateattributes(x,{'numeric'},...
                {'scalar','integer'},'addMemory','rowadd',1));%在得到电脑配置与RAM限制黑科技后，会有对数组整体大小的限制
            p.addOptional('coladd',0,@(x)validateattributes(x,{'numeric'},...
                {'scalar','integer'},'addMemory','coladd',2));
            p.parse(varargin{:});
            
            rowadd=p.Results.rowadd;%得到入口检验后的值
            coladd=p.Results.coladd;
			
            if rowadd%如果行增加量不为0，虽然可以取0不会出错，但是为了优化计算还是增加入口检验
                switch dynObj.Type%对行数进行选择增加数组
                    case 0%如果对象是数组
                        newMemory=zeros(abs(rowadd),size(dynObj.Value,2));

                    case 1%如果对象是结构体数组
                        fields=fieldnames(dynObj.Value);%获取所有原本字段
                        structadd=struct;
                        for i=1:size(fields,1)%将所有原本字段加进结构体里面
                            structadd=setfield(structadd,fields{i},[]);%#ok<SFLD>
                        end
                        newMemory=repmat(structadd,abs(rowadd),size(dynObj.Value,2));

                    case 2%如果对象是细胞数组
                        newMemory=cell(abs(rowadd),size(dynObj.Value,2));
                end
                
                if rowadd>0
                    dynObj.Value=cat(1,dynObj.Value,newMemory);%在行末方向上拼接数组
                else
                    dynObj.Value=cat(1,newMemory,dynObj.Value);%在行初方向上拼接数组
                end
            end
            
            if coladd%如果列增加量不为0，虽然可以取0不会出错，但是为了优化计算还是增加入口检验
                switch dynObj.Type%对行数进行选择增加数组
                    case 0%如果对象是数组
                        newMemory=zeros(size(dynObj.Value,1),abs(coladd));

                    case 1%如果对象是结构体数组
                        fields=fieldnames(dynObj.Value);%获取所有原本字段
                        structadd=struct;
                        for i=1:size(fields,1)%将所有原本字段加进结构体里面
                            structadd=setfield(structadd,fields{i},[]);%#ok<SFLD>
                        end             
                        newMemory=repmat(structadd,size(dynObj.Value,1),abs(coladd));

                    case 2%如果对象是细胞数组
                        newMemory=cell(size(dynObj.Value,1),abs(coladd));
                end
                
                if coladd>0
                    dynObj.Value=cat(2,dynObj.Value,newMemory);%在列末方向上拼接数组
                else
                    dynObj.Value=cat(2,newMemory,dynObj.Value);%在列初方向上拼接数组
                end
            end              
        end                    
    end
       
	methods(Access=private)%私密方法
		function checkType(dynObj)
		%checkType:适用于内部再判断对象的类型，会自动改变Type属性至当前对象类型
		%dynObj:被检测的动态内存对象
		%type:返回当前的类型
		%versin:1.0.2
        %author:jinshuguangze
		%data:4/19/2018	

			if isstruct(dynObj.Value)%结构体数组
				dynObj.Type=1;
			elseif iscell(dynObj.Value)%细胞数组
				dynObj.Type=2;
			else%其他所有统称为普通数组，由于属性包含了输入检测，所以无需再次检测
				dynObj.Type=0;
			end
		end
    end
end

function mustBeMatrix(value)
%mustBeMatrix:作为DynMemory类的属性限制函数，属性值必须是二维数组
%value:输入的属性值
%version:1.0.1
%author:jinshuguangze
%data:4/21/2018	

    if ~ismatrix(value)
        error('对象的值域属性必须是二维数组！');
    end
end