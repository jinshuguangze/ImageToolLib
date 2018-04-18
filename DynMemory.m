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
    
end