function outputImage = autoFilling(inputImage,varargin)
%autoReducing:�Զ����ͼ���еĿ�϶��
%inputImage:�������뵥��ͼ���ͼ��ϸ��������
%operator:�������ӵȼ�������ѡ��Low������Medium������High������Extra���ĸ��ȼ�
%outputImage:�Զ������ͼ��ϸ������
%version:1.0.6
%author:jinshuguangze
%data:5/7/2018

    outputImage={};%��ʼ�����
    if iscell(inputImage) && isrow(inputImage)%������ͼ��ת��Ϊϸ�����鴦���
        handleList=inputImage;
    elseif islogical(inputImage) && isnumeric(inputImage)...
            && (ismatrix(inputImage) || ndims(inputImage)==3)%������RGB/�Ҷ�/��ֵͼ��
        handleList{1}=inputImage;
    else
        disp('�������ʹ���');
        return;
    end

    p=inputParser;%������ڼ�����
    p.addOptional('operator','Low',@(x)any(validatestring(x,...
        {'Low','Medium','High','Extra'},'autoFilling','operator',2)));
    p.parse(varargin{:});
    operator=p.Results.operator;
    
    switch upper(operator)%��ά�ۺ�����ʵ����
        case 'LOW'
            neibor=[-1 0;0 1;1 0;0 -1];
            
        case 'MEDIUM'
            neibor=[-1 0;0 1;1 0;0 -1;-1 -1;-1 1;1 1;1 -1];
            
        case 'HIGH'
            neibor=[-1 0;0 1;1 0;0 -1;-1 -1;-1 1;1 1;1 -1;0 -2;-2 0;0 2;2 0];
            
        case 'EXTRA'
            neibor=[-1 0;0 1;1 0;0 -1;-1 -1;-1 1;1 1;1 -1;0 -2;-2 0;0 2;2 0;
                2 -1;2 -2;1 -2;-1 -2;-2 -2;-2 -1;-2 1;-2 2;-1 2;1 2;2 2;2 1];
            
        otherwise%����validatestring�����ԣ������һЩ��ֵĽ����ַ���������ʱֻ���趨ΪĬ��ֵ
            neibor=[-1 0;0 1;1 0;0 -1];
    end
    
    for i=1:size(handleList,2)
        validateattributes(handleList{i},{'numeric'},{'3d','nonnegative'},'autoFixing');%ͼ����ڼ��
        handleList{i}=im2double(handleList{i});%��ͼ��˫���Ȼ�
        [row,col,~]=size(handleList{i});%��ȡͼ�񳤿�
        while true
            done=false;
            for j=1:row
                for k=1:col
                    if handleList{i}(j,k,:)==1%�����׵�
                        count=0;%��ʼ������
                        adv=0;%��ʼ��ƽ��ֵ
                        for l=1:size(neibor,1)
                            if (j==1 && neibor(l,1)<0) ||...%�ڱ�Եʱ��ĳ������ᱻ����
                                    (j==row && neibor(l,1)>0)||...
                                    (k==1 && neibor(l,2)<0)||...
                                    (k==col && neibor(l,2)>0)
                                continue;
                            end
                            
                            x=j+neibor(l,1);%�ض�λ����ֵ
                            y=k+neibor(l,2);
                            if handleList{i}(x,y,:)~=1%�������Ϊ��   
                                adv=(adv*count+handleList{i}(x,y,:))/(count+1);%���¼���ƽ��ֵ��adv��1*1*1����1*1*3������
                                count=count+1;
                            end
                        end
                        
                        if count>size(neibor,1)/2%��������������һ��
                            done=true;
                            handleList{i}(j,k,:)=adv(:);%��ƽ��ֵ�������ص�
                        end
                    end
                end
            end
            
            if ~done%���û�е���䣬������ѭ��
                break;
            end                      
        end
    end
    
    outputImage=handleList;%���
end