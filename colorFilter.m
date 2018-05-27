function outputImage = colorFilter(inputImage,filter,varargin)
%colorFilter:RGBͼ�����ͨ������
%inputImage:����ͼ��ָ��ΪRGBͼ��
%filter:��������Χ���飬Ϊ3*2�����飬�ֱ�Ϊ[Rͨ�����ޣ�Rͨ������;
%                                                             Gͨ�����ޣ�Gͨ������;
%                                                             Bͨ�����ޣ�Bͨ������]����Ϊ������
%openStrel:����strel���󣬶Բ������п�����
%closeStrel:����strel���󣬶Բ������бղ���
%outputImage:���ͼ���Ѿ������˹��˲���
%version:1.0.3
%author:jinshuguangze
%data:5/23/2018

   	p=inputParser;%������ڼ�����
    p.addRequired('inputImage',@(x)validateattributes(x,{'numeric'},...
        {'size',[NaN,NaN,3],'real','nonnegative'},'regionFilter','inputImage',1));
    p.addRequired('filter',@(x)validateattributes(x,{'double'},...
        {'size',[3,2],'>=',0,'<=',1},'colorFilter','filter',2));
    p.addOptional('openStrel',[],@(x)validateattributes(x,{'strel'},...
        {},'colorFilter','strel',3));
	p.addOptional('closeStrel',[],@(x)validateattributes(x,{'strel'},...
        {},'colorFilter','strel',4));
    p.parse(inputImage,filter,varargin{:});
    inputImage=p.Results.inputImage;
    filter=p.Results.filter;
    openStrel=p.Results.openStrel;
    closeStrel=p.Results.closeStrel;
    
    inputImage=im2double(inputImage);
    [row,col,~]=size(inputImage);%���ͼ�񳤿�
    [Rrow,Rcol]=find(inputImage(:,:,1)>=filter(1,1) & inputImage(:,:,1)<=filter(1,2));%��ȡRͨ��
    [Grow,Gcol]=find(inputImage(:,:,2)>=filter(2,1) & inputImage(:,:,2)<=filter(2,2));%��ȡGͨ��
    [Brow,Bcol]=find(inputImage(:,:,3)>=filter(3,1) & inputImage(:,:,3)<=filter(3,2));%��ȡBͨ��
    indexArray=intersect(intersect(cat(2,Rrow,Rcol),cat(2,Grow,Gcol),'rows'),cat(2,Brow,Bcol),'rows');%��ȡ��������
    
    filterImage=ones(row,col);
    for i=1:size(indexArray,1)
        filterImage(indexArray(i,1),indexArray(i,2))=0;
    end
    
    if ~isempty(openStrel)%������
        filterImage=imopen(filterImage,openStrel);
    end
    if ~isempty(closeStrel)%�ղ���
        filterImage=imclose(filterImage,closeStrel);
    end 
    
    outputImage=ones(row,col,3);%����հױ��������ͼ��
    for i=1:row
        for j=1:col
            if ~filterImage(i,j)
                outputImage(i,j,:)=inputImage(i,j,:);%���
            end
        end
    end
end

