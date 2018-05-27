function variable = molloc(varargin)
%molloc:����һ���ڴ棬���ڵ��ڴ治����ʱ���Զ�����
%varargin:�ɱ��������������һ�����������������汾�Ĳ����ֲ��ǡ��������������������͡�
%variable:����һ���Ѿ�������ڴ�ı������������Ŀռ�ᱻ0���
%version:1.0.3
%author:jinshuguangze
%data:4/15/2018
%TODO:
%1.���ȶ�ȡmatlab������Ϣ��Ȼ��������Զ�ȡsystem('systeminfo')��ȡ��Ϣ�õ��ڴ�
%���ֵ�󣬸���matlabԤ����õ�RAMռ�ȣ�Ȼ��ȷ�������С�����ֵ��Ĭ��Ϊ����СΪ
%intmax('uint16')�����˽ṹ���������⣬�ṹ�������������Ϊintmax('uint64')
%2.����һ������ȷ��Ԥ�������������

    switch nargin
        case 0%�������������ʱ����������
            variable=0;%Ĭ�����
            disp('����������һ��������');    
            return;
            
        case 1%���������ֻΪһ��ʱ��ֻ�����������  
            if isscalar(varargin{1}) && isnumeric(varargin{1}) && varargin{1}>0        
                %��ʱ����������Ϊ���������������Ϊintmax('uint16')
                if varargin{1}>intmax('uint16')%�����������
                    variable=zeros(1,intmax('uint16'));%Ĭ�����
                    disp(['����1��������������ܳ���',num2str(intmax('uint16')),'��']);             
                    return;
                else%��������ڷ�Χ��
                    variable=zeros(1,uint16(varargin{1}));
                end
            else%�����������ֲ�Ϊ����
                variable=zeros(1,intmax('uint16'));%Ĭ�����
                disp('����1������������һ��������');
                return;
            end
            
        case 2%���������Ϊ����ʱ����������������������������ַ���
            if isscalar(varargin{1}) && isnumeric(varargin{1}) && varargin{1}>0
                if isscalar(varargin{2}) && isnumeric(varargin{2}) && varargin{2}>0%���ּ�����
                    %��ʱ����������Ϊ���飬�������С������intmax('uint16')
                    if varargin{1}*varargin{2}>intmax('uint16')%�����������
                        variable=zeros(intmax('uint8'),intmax('uint8'));%Ĭ�����
                        disp(['����1�����������2�������ĳ˻���������ܳ���',...
                            num2str(intmax('uint16')),'��']);
                        return;
                    else%��������ڷ�Χ��                 
                        variable=zeros(uint16(varargin{1}),uint16(varargin{2}));
                    end
                elseif ischar(varargin{2})%���ּ��ַ���
                    switch varargin{2}
                        case 'array'%��ʱ����������Ϊ���������������Ϊintmax('uint16')
                            if varargin{1}>intmax('uint16')%�����������
                                variable=zeros(1,intmax('uint16'));%Ĭ�����
                                disp(['����1��������������ܳ���',num2str(intmax('uint16')),'��']);
                                return;
                            else%��������ڷ�Χ��
                                variable=zeros(1,uint16(varargin{1}));
                            end
                            
                        case 'struct'%��ʱ����������Ϊ�ṹ���������������Ϊintmax('uint64')
                            if varargin{1}>intmax('uint64')%�����������
                                variable(1,intmax('uint64'))=struct();%Ĭ�����
                                disp(['����1��������������ܳ���',num2str(intmax('uint64')),'��']);
                                return;
                            else%��������ڷ�Χ��
                                variable(1,uint64(varargin{1}))=struct();
                            end
                            
                        case 'cell'%��ʱ����������Ϊϸ�����������������Ϊintmax('uint16')
                            if varargin{1}>intmax('uint16')%�����������
                                variable=cell(1,intmax('uint16'));%Ĭ�����
                                variable(:)={0};
                                disp(['����1��������������ܳ���',num2str(intmax('uint16')),'��']);
                                return;
                            else%��������ڷ�Χ��
                                variable=cell(1,varargin{1});
                                variable(:)={0};
                            end
                            
                        otherwise%�ַ���������������
                            variable=zeros(1,intmax('uint16'));%Ĭ�����
                            disp('Ŀǰֻ֧��''array''��''struct''��''cell''�������͵Ķ�̬�ڴ����룡');
                            return;
                    end
                else%�ڶ�����������������
                    variable=zeros(1,intmax('uint16'));%Ĭ�����
                    disp('����2����������������һ�����������ַ�����');
                    return;
                end
            else%��һ����������������
                variable=zeros(1,intmax('uint16'));%Ĭ�����
                disp('����1����������Ϊ������');
                return;
            end
                
        case 3%���������Ϊ����ʱ��˳����������֣����֣��ַ���
            if isscalar(varargin{1}) && isnumeric(varargin{1}) && varargin{1}>0 ...
                    && isscalar(varargin{2}) && isnumeric(varargin{2}) && varargin{2}>0 ...
                    && ischar(varargin{3})%�������������ַ������
                switch varargin{3}
                    case 'array'%��ʱ����������Ϊ���飬�������С������intmax('uint16')
                        if varargin{1}*varargin{2}>intmax('uint16')%�����������
                            variable=zeros(intmax('uint8'),intmax('uint8'));%Ĭ�����
                            disp(['����1�����������2�������ĳ˻���������ܳ���',...
                                num2str(intmax('uint16')),'��']);
                            return;
                        else%��������ڷ�Χ��                 
                            variable=zeros(uint16(varargin{1}),uint16(varargin{2}));
                        end                       
                        
                    case 'struct'%��ʱ����������Ϊ�ṹ�����飬������������������intmax('uint64')
                        if varargin{1}>intmax('uint64')%����1����
                            variable(intmax('uint64'),intmax('uint64'))=struct();%Ĭ�����
                            disp(['����1��������������ܳ���',num2str(intmax('uint64')),'��']);
                            return;
                        elseif varargin{2}>intmax('uint64')%����2����
                            variable(intmax('uint64'),intmax('uint64'))=struct();%Ĭ�����
                            disp(['����2��������������ܳ���',num2str(intmax('uint64')),'��']);
                            return;                       
                        else%��������ڷ�Χ��
                            variable(uint64(varargin{1}),uint64(varargin{2}))=struct();
                        end
                        
                    case 'cell'%��ʱ����������Ϊϸ�����飬�������С������intmax('uint16')
                        if varargin{1}*varargin{2}>intmax('uint16')%�����������
                            variable=cell(intmax('uint8'),intmax('uint8'));%Ĭ�����
                            variable(:)={0};
                            disp(['����1�����������2�������ĳ˻���������ܳ���',...
                                num2str(intmax('uint16')),'��']);
                            return;
                        else%��������ڷ�Χ��                 
                            variable=cell(uint16(varargin{1}),uint16(varargin{2}));
                            variable(:)={0};
                        end    

                    otherwise%�ַ���������������
                        variable=zeros(intmax('uint8'),intmax('uint8'));%Ĭ�����
                        disp('Ŀǰֻ֧��''array''��''struct''��''cell''�������͵Ķ�̬�ڴ����룡');
                        return;
                end
            else%����������ϲ���������
                variable=zeros(intmax('uint8'),intmax('uint8'));%Ĭ�����
                disp(['����1����������Ϊ������',...
                    '����2����������Ϊ������',...
                    '����3���������ͱ���Ϊ�ַ�����']);
                return;
            end
            
        otherwise%�������������ʱ
            variable=0;%Ĭ�����
            disp('����������࣡');
            return;
    end
end

