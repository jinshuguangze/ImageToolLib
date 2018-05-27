function data = dataAnalyzer(varargin)
%dataAnalyzer:�õ��ǹ����������Ȳ���
%varargin:�ɱ����������ĵ���ͼ�����ͼ��ϸ������
%data:���ÿ����Ӧ����ͼ�����Ӧ�����Ľṹ��
%version:1.0.3
%author:jinshuguangze
%data:4/13/2018
%TODO:���Ӹ��������������data���óɿɱ䳤��

    if ~nargin%��ڼ��
        disp('�����뵥��ͼ��');
        return;
    else
        for i=1:nargin%����ÿ�����룬������һ��           
            %�������ݣ�ѭ����ϸ�������е�ÿ��Ԫ�أ����ֱ���ǵ���ͼ����ֻѭ��һ��
            for s=1:size(varargin{i},2)             
                if iscell(varargin{i})%���ֵ�ǰ�����Ƿ���ϸ������
                    vstruct=varargin{i}{s};
                else
                    vstruct=varargin{i};
                end
                [row,col]=size(vstruct);%���ͼ���С
                area=0;%��ʼ�����������
                total=0;%��ʼ�����������
                for j=1:row
                    count=0;%��ʼ���м�����
                    for k=1:col
                        if(vstruct(j,k))
                            count=count+1;%�м���������
                        end
                    end
                    area=area+pi*(count^2)/4;%����������ۼ�
                    total=total+count;%�������ص�����
                end
                if iscell(varargin{i})%�ֱ������������
                    data{i}{s}.acreage=total;%ϸ�����鵥��ͼ�����
                    data{i}{s}.volume=area;%ϸ�����鵥��ͼ�����
                else
                    data{i}.acreage=total;%��ͨ����ͼ�����
                    data{i}.volume=area;%��ͨ����ͼ�����
                end
            end
        end
    end
end

