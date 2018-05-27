function outputPath = pcdDataZoomer(inputPath,zoom,transform)
%pcdDataZoomer:��һ��pcd�ļ��ڵ�����ֵ���ݽ��з���
%inputPath:����pcd�ļ���·��
%zoom:�����ߴ�
%outputPath:���pcd�ļ���·��
%version:1.0.2_���綨�ư�
%author:jinshuguangze
%data:5/21/2018

    p=inputParser;%������ڼ�����
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
        [filepath,name,~]=fileparts(inputPath);%����·��
        outputPath=[filepath,'\',name,'_zoomed_',strrep(datestr(now),':','-'),'.pcd'];%���·��
        pc=pcread(inputPath);%��ȡ�����ļ�
        Data=pc.Location*zoom*transform;%�õ�������������
        Width=pc.Count;%�õ����Ƴ���
        
        pcdFile=fopen(outputPath,'w+','n','GBK');%�½�pcd�ļ���д������
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
        disp('��д�ļ�����δ֪����');
        fclose(pcdFile);
        return;
    end
end