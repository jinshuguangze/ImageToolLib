function outputPath = txt2pcd(viewPoint,varargin)
%txt2pcd:��ȡtxt�ļ����߶���������ļ�ת��Ϊpcd�ļ����洢�ڵ�һ����Ч�ļ�����Ŀ¼��
%viewPoint:����ɼ��ӵ������������������������ܵ�����ת����������ƽ�淨�����꣬
%               ��ʽ��ƽ��(tx ty tz) + ��Ԫ��(qw qx qy qz)�������ȷ�����Ǿ���дĬ��ֵ[0 0 0 1 0 0 0]
%varargin:�����ļ�������Ϊ������ʽRGB/�Ҷ�ͼ��Ҳ����Ϊtxt�������ݣ�
%             ����ж����Чtxt�ļ����룬�����ǵ�λ�����ݺϲ���
%             ����ж����Ч�Ҷ�ͼ�����룬�����ķ�������ݻḲ��ǰ��ķ��������
%             ����ж����Ч��ɫͼ�����룬������RGB���ݻḲ��ǰ���RGB����
%outputPath:���pcd�ļ���·��
%version:1.0.9
%author:jinshuguangze
%data:5/4/2018
    
    p=inputParser;%������ڼ������ֻ����һ���������ɼ��ӵ�
    p.addRequired('viewPoint',@(x)validateattributes(x,{'numeric'},...
        {'real','finite','size',[1,7]},'txt2pcd','viewPoint',1));
    p.parse(viewPoint);
    viewPoint=p.Results.viewPoint;
    
    isLegalPath=0;%��ʼ���׸��Ϸ�·��ָʾ��
    handleList={};%��ʼ�������б�
    count=0;%��ʼ�������б���Ŀ
    positionData=[];%��ʼ����������
    colorData=[];%��ʼ��RGB����
    intensityData=[];%��ʼ�����������
    outputPath='';%��ʼ������ֵ
    
    for i=1:size(varargin,2)
        if ischar(varargin{i})
            if isfolder(varargin{i})%�����������ļ���
                files=dir(varargin{i});%��ȡ�ļ��������е����ļ�
                for j=1:size(files,1)%����Ч�ļ���ȫ�����뵽�����б�����
                    if ~strcmp(files(j).name,'.') && ~strcmp(files(j).name,'..')
                        count=count+1;
                        handleList{count}=[varargin{i},'\',files(j).name];
                    end
                end
            elseif isfile(varargin{i})%�����������ļ�
                handleList{count}=varargin{i};
            end
        else
            disp('����ĵ�',num2str(i),'��·����Ч���Ѻ��Ը����ݣ�');
        end
    end
    
    for i=1:count%�����б�
        try
            [filepath,~,ext]=fileparts(handleList{i});%����·��
            if ~isLegalPath
                if ~isempty(filepath)%����ǺϷ�·��
                    outputPath=[filepath,'\',strrep(datestr(now),':','-'),'.pcd'];%���·��
                    isLegalPath=1;
                end
            end
           
            switch ext%��ȡ�ļ���ʽ
                case '.jpg' | '.png' | '.bmp'%ͼ���ļ�
                    temp=imread(handleList{i});
                    if size(temp,3)==1%����ǻҶ�ͼ����ֵ�����������
                        intensityData=temp;
                    elseif size(temp,3)==3%����ǲ�ɫͼ����ֵ��RGB����
                        colorData=temp;
                    end
                    
                case '.txt'%�ı��ĵ�
                    positionData=[positionData;load(handleList{i})];
                    
                otherwise%��֧�ֵĸ�ʽ
                    disp(['�����б��еĵ�',num2str(i),'���ļ��ĸ�ʽ����֧�֣��Ѻ��Ը����ݣ�']);
            end
        catch%������Ч·��
            disp(['�����б��еĵ�',num2str(i),'��·����Ч���Ѻ��Ը����ݣ�']);
        end
    end
    
    if isempty(positionData)%������Ҫ��һ����������
        disp('����������һ��txt�ļ���');
        return;
    else
        Fields='FIELDS x y z';%�����������µ�Ԥ��
        Size='SIZE 4 4 4';
        Type='TYPE F F F';
        Count='COUNT 1 1 1';
        Width=size(positionData,1);%��ȡ�������ݸ���
        %���޹ر�����colorData��intensityData���޳���TODO
        Data=horzcat(positionData,colorData,intensityData);%ƴ����������
        
        if ~isempty(colorData)%�������RGB����
            Fields=[Fields,' r g b'];
            Size=[Size,' 1 1 1'];
            Type=[Type,' U U U'];
            Count=[Count,' 1 1 1'];
        end
        
        if ~isempty(intensityData)%������ڷ��������
            Fields=[Fields,' intensity'];
            Size=[Size,' 1'];
            Type=[Type,' U'];
            Count=[Count,' 1'];         
        end
 
        try%�����ļ���д������
            pcdFile=fopen(outputPath,'w+','n','GBK');
            fprintf(pcdFile,'%s\r\n','#.PCD v0.7 - The .pcd file is created automatically by the function txt2pcd.m');
            fprintf(pcdFile,'%s\r\n','VERSION 0.7');
            fprintf(pcdFile,'%s\r\n',Fields);
            fprintf(pcdFile,'%s\r\n',Size);
            fprintf(pcdFile,'%s\r\n',Type);
            fprintf(pcdFile,'%s\r\n',Count);
            fprintf(pcdFile,'%s\r\n',['WIDTH ',num2str(Width)]);
            fprintf(pcdFile,'%s\r\n','HEIGHT 1');
            fprintf(pcdFile,'%s\r\n',['VIEWPOINT ',num2str(viewPoint)]);
            fprintf(pcdFile,'%s\r\n',['POINTS ',num2str(Width)]);
            fprintf(pcdFile,'%s\r\n','DATA ascii');
            for i=1:Width
                fprintf(pcdFile,'%s\r\n',num2str(Data(i,:)));
            end
            fclose(pcdFile);
        catch
            disp('��д�ļ�����δ֪����');
            fclose(pcdFile);
            return;
        end
    end
end