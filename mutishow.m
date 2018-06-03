function mutishow(varargin)
%mutishow:���ڸ���ĵ����Ա�ͼ�񴰿�
%varargin:�ɱ��������������������ͼ��֧����ͨ�������Ӧһάϸ�����鼯��
%version:1.0.6
%author:jinshuguangze
%data:3/22/2018

    %�ж�����ͼ������
    if(~nargin)
        disp('�޲������룡');
        return;
    else
        figure, %��ͼ�񴰿�
        count=nargin;%��ʼĬ��Ԫ����û��ϸ������
        
        %����һ����ͼ������
        for i=1:nargin
            if(iscell(varargin{i}))
                count=count+size(varargin{i},2)-1;%����������Ӧֵ
            end            
        end
           
        row=floor(sqrt(count));%����
        columns=ceil(count/row);%����
        point=0;%ͼ��ָ��
               
        %�ڶ�������Ų�ͼ��
        for i=1:nargin           
            if(iscell(varargin{i}))%���Ԫ����ϸ�����飬�������ʾ
                for j=1:size(varargin{i},2)%����ϸ������
                    point=point+1;%ָ���ƶ�
                    subplot(3,6,point);
                    imshow(varargin{i}{j});                    
                end
            else%�������ͨ���飬��ֱ����ʾ
                point=point+1;%ָ���ƶ�
                subplot(row,columns,point);
                imshow(varargin{i});                
            end
        end
    end
end

