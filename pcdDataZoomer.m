function outputPath = pcdDataZoomer(inputPath,zoom,transform)
%pcdDataZoomer:对一个pcd文件内的坐标值数据进行放缩
%inputPath:输入pcd文件的路径
%zoom:放缩尺寸
%outputPath:输出pcd文件的路径
%version:1.0.2_昆哥定制版
%author:jinshuguangze
%data:5/21/2018

    p=inputParser;%构建入口检测对象
    p.addRequired('inputPath',@(x)validateattributes(x,{'char'},...
        {'row'},'pcdDataZoomer','inputPath',1));
    p.addRequired('zoom',@(x)validateattributes(x,{'numeric'},...
        {'real','finite','nonzero','scalar'},'pcdDataZoomer','zoom',2));
    p.addRequired('transform',@(x)validateattributes(x,{'numeric'},...
        {'real','finite','size',[3,3]},'pcdDataZoomer','transform',3));
    p.parse(inputPath,zoom,transform);
    inputPath=p.Results.inputPath;
    zoom=p.Results.zoom;
    transform=p.Results.transform;
    
    try
        [filepath,name,~]=fileparts(inputPath);%分离路径
        outputPath=[filepath,'\',name,'_zoomed_',strrep(datestr(now),':','-'),'.pcd'];%输出路径
        pc=pcread(inputPath);%读取点云文件
        Data=pc.Location*zoom*transform;%得到点云坐标数据
        Width=pc.Count;%得到点云长度
        
        pcdFile=fopen(outputPath,'w+','n','GBK');%新建pcd文件并写入数据
        fprintf(pcdFile,'%s\r\n','#.PCD v0.7 - The .pcd file is created automatically by the function pcdDataZoomer.m');
        fprintf(pcdFile,'%s\r\n','VERSION 0.7');
        fprintf(pcdFile,'%s\r\n','FIELDS x y z');
        fprintf(pcdFile,'%s\r\n','SIZE 4 4 4');
        fprintf(pcdFile,'%s\r\n','TYPE F F F');
        fprintf(pcdFile,'%s\r\n','COUNT 1 1 1');
        fprintf(pcdFile,'%s\r\n',['WIDTH ',num2str(Width)]);
        fprintf(pcdFile,'%s\r\n','HEIGHT 1');
        fprintf(pcdFile,'%s\r\n','VIEWPOINT 0 0 0 1 0 0 0');
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