classdef(Sealed) DynMemory<handle%������̳У������ǳ�����handle
%DynMemory:һ����̬�ڴ��࣬ʵ���������Ķ�ά������������ѭ�����Զ�����Ƿ�������
%                  ���Զ������µĺ��ʵ��ڴ棬Ҳ�����ֶ����������ڴ�
%TODO:
%1.�����¼����ͣ�event����ʹ�ü�����ģ��������ֶ��ⲿѭ����ȫ���������Ͳ��ּ���������ģ��
%ȫ����������һ��ʹ����ģ�ͣ�ÿ��ԭ��С��ά���е�0����䵽���ֵʱ������ʹ���ʱ�������ʹ�������ӵ�
%Paraʱ�����Զ�addMemory������ռ���ڴ����϶ࣻ���ּ�����ֻ�������Para֮�����ֵ�仯��һ���б仯��
%������addMemory���������ܲ�̫׼ȷ����Ϊ�п������ⲿ��ֵ�ǴӺ󲿿�ʼѭ����
%2.��һ��ö�ټ�ֵ�����洢type��ʵ�����ͣ���ʧ�ܣ���ʱû�кõ�˼·
%3.��������ʹ��any()��ʵ�ֶ�ά��⹦��

    properties%�����ֶ�
        %�洢��ֵ�������ֵ��洢�ڴ��ֶ��У�����������������ֹ��Ԥ�ڸ���
        Value{mustBeNonempty,mustBeMatrix}=0
    end
    
    properties(SetAccess=private)%��˽���ֶ�
        OriginalSize%ԭʼ��������
    end
    
    properties(GetAccess=private,SetAccess=private)%˽���ֶ�
        Type%��������
        %����ʹ���κι�������ʱ�Զ����£�
        %˽��ԭ���ǿ�������û�е��ö���ķ�����
        %��ֱ�ӷ����ֶζ�������Ϣ����
        %0:����
        %1:�ṹ������
        %2:ϸ������
    end
    
    properties(Constant)%�����ֶ�
        Scale=0.9%Ĭ�ϳ��ȱ���ֵ
    end
    
    methods%���캯��
        function dynObj = DynMemory(varargin)
        %DynMemory:����һ���ڴ棬���ڵ��ڴ治����ʱ�����ʵ���Զ�����
        %varargin:�ɱ���������������������������������汾�Ĳ����ֲ��ǡ��������������������͡�
        %dynObj:����һ���Ѿ�������ڴ�Ķ�̬�ڴ�����������Ŀռ�ᱻ0���
        %version:1.0.6
        %author:jinshuguangze
        %data:4/15/2018
        %TODO:
        %1.���ȶ�ȡmatlab������Ϣ��Ȼ��������Զ�ȡsystem('systeminfo')��ȡ��Ϣ�õ��ڴ�
        %���ֵ�󣬸���matlabԤ����õ�RAMռ�ȣ�Ȼ��ȷ�������С�����ֵ��Ĭ��Ϊ����СΪ
        %intmax('uint16')�����˽ṹ���������⣬�ṹ�������������Ϊintmax('uint64')
		%2.����tall,table������

            p=inputParser;%������������
            p.addOptional('row',1,@(x)validateattributes(x,{'numeric'},...
                {'scalar','integer','positive'},'DynMemory','row',1));
            p.addOptional('col',1,@(x)validateattributes(x,{'numeric'},...
                {'scalar','integer','positive'},'DynMemory','col',2));
            p.addOptional('type','array',@(x)any(validatestring(x,...
                {'array','struct','cell'},'DynMemory','type',3)));            
            p.parse(varargin{:});
            
            row=p.Results.row;%�õ���ڼ�����ֵ
            col=p.Results.col;
            type=p.Results.type;
            
            dynObj.OriginalSize=[row,col];%����ԭʼ��С
            switch type%��ͬ�����͵Ĳ�ͬ�����ڴ淽��
                case 'array'%����       
                    dynObj.Value=zeros(row,col);%�������󣬹���
                    dynObj.Type=0;%���ö�������
                    
                case 'struct'%�ṹ������              
                    temp(row,col)=struct;%���������ÿ�
                    dynObj.Value=temp;%����MATLABʵ�ֻ������⣬ֻ��ʹ����ʱ����
                    dynObj.Type=1;%���ö�������
                    
                case 'cell'%ϸ������   
                    dynObj.Value=cell(row,col);%���������ÿ�
                    dynObj.Type=2;%���ö�������
            end
        end
    end
    
    methods%��������
        function dynObj=refresh(dynObj,varargin)
        %refresh:���ʶ������ڴ�ĩ�����һϵ�������Ƿ��ޱ仯����������ָ��Ĺ���
		%		    �����������ڴ��п��ܻ���Ϊ�����������һϵ������Ϊ0��ˢ��ʧ�ܣ�
		%		    ����˶���ʱ����Ч�ʣ�һ���з�0�������룬���������Ч��
		%dynObj:������Ķ�̬�ڴ���󣬿����г��ȵ�����
		%varargin:��ѡ�����룬��������ѭ�����ĳ��ȱ������߼��̶����ȣ�
		%			  �������ֵС��1�����ǰ��ճ��ȱ����������ǰ��չ̶�����
		%			  ����Ǹ��������ͷ��ʼ�������Ǵ�β����ʼ��⣬
		%		      ��������룬���ʹ��Ĭ��ֵ�����ֻ����һ��ֵ����ô����������
		%			  �����������Խ������������������һ�£����ʧ�ܣ������������ó�Ĭ��ֵ
        %version:1.0.7
        %author:jinshuguangze
        %data:4/17/2018	
        
            dynObj.checkType;%�Զ����ֵ��������ͼ��   

			[row,col]=size(dynObj.Value);%��ȡ��������������
			
			p=inputParser;%������������
			p.addOptional('rowScale',dynObj.Scale,@(x)validateattributes(x,{'numeric'},...
				{'real','scalar','nonzero','>',-row,'<',row},'refresh','rowScale',1));			
			p.addOptional('colScale',dynObj.Scale,@(x)validateattributes(x,{'numeric'},...
				{'real','scalar','nonzero','>',-col,'<',col},'refresh','colScale',2));
			p.parse(varargin{:});	
            
			rScale=p.Results.rowScale;%�õ���ڼ�����ֵ
			cScale=p.Results.colScale;
			
            if nargin==2%���ֻ����һ����ֵ���������������Ե�����������
				if rScale<col%���Գɹ�
					cScale=rScale;
				else%����ʧ�ܣ����ó�Ĭ��ֵ
					cScale=dynObj.Scale;
				end
            end							
			
            if rScale>=1%����������������Ķ���ֵ��ѭ����	
				rloop=row:-1:row-ceil(rScale);
			elseif rScale>0 && rScale<1
				rloop=row:-1:ceil(row*rScale);
			elseif rScale>-1 && rScale<0
				rloop=1:floor(-row*rScale);
			else
				rloop=1:floor(-rScale);
            end
			
            if cScale>=1%����������������Ķ���ֵ��ѭ����
				cloop=col:-1:col-ceil(cScale);
			elseif cScale>0 && cScale<1
				cloop=col:-1:ceil(col*cScale);
			elseif cScale>-1 && cScale<0
				cloop=1:floor(-col*cScale);
			else
				cloop=1:floor(-cScale);
            end
			
			switch dynObj.Type%���ڶ���Ĳ�ͬ�����в�ͬ����
				case 0%����
                    checkArray=dynObj.Value(rloop,cloop);%�����������
                    %ʹ����ѭ�������������ȫ�ֿ��������ڳ���Ч�ʵ���ߣ����ڼ��һ�����ֳɹ�֮���return
                    for i=1:size(checkArray,1)
                        for j=1:size(checkArray,2)
                            if checkArray(i,j)%���
                                %��������ķ����ж�����ڴ�ķ���
                                dynObj.addMemory(dynObj.OriginalSize(1)*rScale/abs(rScale));
                                return;
                            end
                        end
                    end
				
                case 1%�ṹ������
                    fields=fieldnames(dynObj.Value);
                    if ~size(fields,1)%ȷ��������һ���ֶ�
                        return;
                    end
                    %�����������
                    checkArray=dynObj.Value(rloop,cloop);
                    %ʹ����ѭ�������������ȫ�ֿ��������ڳ���Ч�ʵ���ߣ����ڼ��һ�����ֳɹ�֮���return
                    for i=1:size(checkArray,1)
                        for j=1:size(checkArray,2)
                            for k=1:size(fields,1)%������������ֶε�ѭ����
                                % ����Ƿ�Ϊ�գ�ͬʱ����һ��Ӧ���Ǳ����������getfield�ǿ⺯��������get�����Ĵ���
                                if ~isempty(getfield(checkArray(:),fields{k,1}))%#ok<GFLD>
                                    %��������ķ����ж�����ڴ�ķ���
                                    dynObj.addMemory(dynObj.OriginalSize(1)*rScale/abs(rScale));
                                    return;
                                end
                            end
                        end
                    end
					
				case 2%ϸ������
                    checkArray=dynObj.Value{rloop,cloop};%�����������
                    %ʹ����ѭ�������������ȫ�ֿ��������ڳ���Ч�ʵ���ߣ����ڼ��һ�����ֳɹ�֮���return
                    for i=1:size(checkArray,1)
                        for j=1:size(checkArray,2)                   
                            if ~isempty(checkArray(:))%���
                                %��������ķ����ж�����ڴ�ķ���
                                dynObj.addMemory(dynObj.OriginalSize(1)*rScale/abs(rScale));
                                return;
                            end
                        end
                    end
			end
        end       
        	
        function dynObj=addMemory(dynObj,varargin)
        %addMemory:���ں����ǹ����ģ����Կ����ֶ�ȥ���������ڴ棬
		%                  Ĭ��Ϊ������������ֵΪ��ʼ�����ڴ��������
        %                  ������������������Բ�������д(0,col)��
        %                  ֧�����븺�����ڴ�����£���Ӷ�Ӧά�ȵ�ͷ�������ڴ������β��
        %dynObj:������Ķ�̬�ڴ���󣬳����Ѿ�����
		%varargin:��ѡ�����룬���Ը�����������������ֵ�Ĵ�С��
		%             ����ѡ�����ӵķ������л����У����߶�����
        %version:1.0.6
        %author:jinshuguangze
        %data:4/17/2018	
        
            dynObj.checkType;%�Զ����ֵ��������ͼ��
            
            p=inputParser;%������������
            p.addOptional('rowadd',dynObj.OriginalSize(1),@(x)validateattributes(x,{'numeric'},...
                {'scalar','integer'},'addMemory','rowadd',1));%�ڵõ�����������RAM���ƺڿƼ��󣬻��ж����������С������
            p.addOptional('coladd',0,@(x)validateattributes(x,{'numeric'},...
                {'scalar','integer'},'addMemory','coladd',2));
            p.parse(varargin{:});
            
            rowadd=p.Results.rowadd;%�õ���ڼ�����ֵ
            coladd=p.Results.coladd;
			
            if rowadd%�������������Ϊ0����Ȼ����ȡ0�����������Ϊ���Ż����㻹��������ڼ���
                switch dynObj.Type%����������ѡ����������
                    case 0%�������������
                        newMemory=zeros(abs(rowadd),size(dynObj.Value,2));

                    case 1%��������ǽṹ������
                        fields=fieldnames(dynObj.Value);%��ȡ����ԭ���ֶ�
                        structadd=struct;
                        for i=1:size(fields,1)%������ԭ���ֶμӽ��ṹ������
                            structadd=setfield(structadd,fields{i},[]);%#ok<SFLD>
                        end
                        newMemory=repmat(structadd,abs(rowadd),size(dynObj.Value,2));

                    case 2%���������ϸ������
                        newMemory=cell(abs(rowadd),size(dynObj.Value,2));
                end
                
                if rowadd>0
                    dynObj.Value=cat(1,dynObj.Value,newMemory);%����ĩ������ƴ������
                else
                    dynObj.Value=cat(1,newMemory,dynObj.Value);%���г�������ƴ������
                end
            end
            
            if coladd%�������������Ϊ0����Ȼ����ȡ0�����������Ϊ���Ż����㻹��������ڼ���
                switch dynObj.Type%����������ѡ����������
                    case 0%�������������
                        newMemory=zeros(size(dynObj.Value,1),abs(coladd));

                    case 1%��������ǽṹ������
                        fields=fieldnames(dynObj.Value);%��ȡ����ԭ���ֶ�
                        structadd=struct;
                        for i=1:size(fields,1)%������ԭ���ֶμӽ��ṹ������
                            structadd=setfield(structadd,fields{i},[]);%#ok<SFLD>
                        end             
                        newMemory=repmat(structadd,size(dynObj.Value,1),abs(coladd));

                    case 2%���������ϸ������
                        newMemory=cell(size(dynObj.Value,1),abs(coladd));
                end
                
                if coladd>0
                    dynObj.Value=cat(2,dynObj.Value,newMemory);%����ĩ������ƴ������
                else
                    dynObj.Value=cat(2,newMemory,dynObj.Value);%���г�������ƴ������
                end
            end              
        end                    
    end
       
	methods(Access=private)%˽�ܷ���
		function checkType(dynObj)
		%checkType:�������ڲ����ж϶�������ͣ����Զ��ı�Type��������ǰ��������
		%dynObj:�����Ķ�̬�ڴ����
		%type:���ص�ǰ������
		%version:1.0.3
        %author:jinshuguangze
		%data:4/19/2018	

			if isstruct(dynObj.Value)%�ṹ������
				dynObj.Type=1;
			elseif iscell(dynObj.Value)%ϸ������
				dynObj.Type=2;
			else%��������ͳ��Ϊ��ͨ���飬�������԰����������⣬���������ٴμ��
				dynObj.Type=0;
			end
		end
    end
end

function mustBeMatrix(value)
%mustBeMatrix:��ΪDynMemory����������ƺ���������ֵ�����Ƕ�ά����
%value:���������ֵ
%version:1.0.1
%author:jinshuguangze
%data:4/21/2018	

    if ~ismatrix(value)
        error('�����ֵ�����Ա����Ƕ�ά���飡');
    end
end