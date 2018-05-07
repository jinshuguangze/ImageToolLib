function outputPath = txt2pcd(viewPoint,varargin)
%txt2pcd:读取txt文件或者额外的数据文件转换为pcd文件并存储在第一个有效文件所在目录中
%viewPoint:输入采集视点行向量，可以用来后续可能的坐标转换，或者求平面法线坐标，
%               格式是平移(tx ty tz) + 四元数(qw qx qy qz)，如果不确定，那就填写默认值[0 0 0 1 0 0 0]
%varargin:输入文件，可以为常见格式RGB/灰度图像，也可以为txt点云数据，
%             如果有多个有效txt文件输入，则将它们的位置数据合并，
%             如果有多幅有效灰度图像输入，则后面的反射光数据会覆盖前面的反射光数据
%             如果有多幅有效彩色图像输入，则后面的RGB数据会覆盖前面的RGB数据
%outputPath:输出pcd文件的路径
%version:1.0.9
%author:jinshuguangze
%data:5/4/2018
    
    p=inputParser;%构造入口检测器，只检查第一个参数：采集视点
    p.addRequired('viewPoint',@(x)validateattributes(x,{'numeric'},...
        {'real','finite','size',[1,7]},'txt2pcd','viewPoint'));
    p.parse(viewPoint);
    viewPoint=p.Results.viewPoint;
    
    isLegalPath=0;%初始化首个合法路径指示物
    handleList={};%初始化处理列表
    count=0;%初始化处理列表数目
    positionData=[];%初始化坐标数据
    colorData=[];%初始化RGB数据
    intensityData=[];%初始化反射光数据
    outputPath='';%初始化返回值
    
    for i=1:size(varargin,2)
        if ischar(varargin{i})
            if isfolder(varargin{i})%如果输入的是文件夹
                files=dir(varargin{i});%获取文件夹下所有单层文件
                for j=1:size(files,1)%将有效文件名全部输入到处理列表里面
                    if ~strcmp(files(j).name,'.') && ~strcmp(files(j).name,'..')
                        count=count+1;
                        handleList{count}=[varargin{i},'\',files(j).name];
                    end
                end
            elseif isfile(varargin{i})%如果输入的是文件
                handleList{count}=varargin{i};
            end
        else
            disp('输入的第',num2str(i),'个路径无效，已忽略该数据！');
        end
    end
    
    for i=1:count%处理列表
        try
            [filepath,~,ext]=fileparts(handleList{i});%分离路径
            if ~isLegalPath
                if ~isempty(filepath)%如果是合法路径
                    outputPath=[filepath,'\',strrep(datestr(now),':','-'),'.pcd'];%输出路径
                    isLegalPath=1;
                end
            end
           
            switch ext%读取文件格式
                case '.jpg' | '.png' | '.bmp'%图像文件
                    temp=imread(handleList{i});
                    if size(temp,3)==1%如果是灰度图像，则赋值给反射光数据
                        intensityData=temp;
                    elseif size(temp,3)==3%如果是彩色图像，则赋值给RGB数据
                        colorData=temp;
                    end
                    
                case '.txt'%文本文档
                    positionData=[positionData;load(handleList{i})];
                    
                otherwise%不支持的格式
                    disp(['处理列表中的第',num2str(i),'个文件的格式不被支持，已忽略该数据！']);
            end
        catch%不是有效路径
            disp(['处理列表中的第',num2str(i),'个路径无效，已忽略该数据！']);
        end
    end
    
    if isempty(positionData)%至少需要有一个坐标数据
        disp('请至少输入一个txt文件！');
        return;
    else
        Fields='FIELDS x y z';%无其他数据下的预设
        Size='SIZE 4 4 4';
        Type='TYPE F F F';
        Count='COUNT 1 1 1';
        Width=size(positionData,1);%获取坐标数据个数
        %将无关变量从colorData和intensityData中剔除，TODO
        Data=horzcat(positionData,colorData,intensityData);%拼接所有数据
        
        if ~isempty(colorData)%如果存在RGB数据
            Fields=[Fields,' r g b'];
            Size=[Size,' 1 1 1'];
            Type=[Type,' U U U'];
            Count=[Count,' 1 1 1'];
        end
        
        if ~isempty(intensityData)%如果存在反射光数据
            Fields=[Fields,' intensity'];
            Size=[Size,' 1'];
            Type=[Type,' U'];
            Count=[Count,' 1'];         
        end
 
        try%创建文件，写入数据
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
            disp('读写文件出现未知错误！');
            fclose(pcdFile);
            return;
        end
    end
end