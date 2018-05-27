function outputImage = colorFilter(inputImage,filter,varargin)
%colorFilter:RGB图像的三通道过滤
%inputImage:输入图像，指定为RGB图像
%filter:过滤器范围数组，为3*2的数组，分别为[R通道下限，R通道上限;
%                                                             G通道下限，G通道上限;
%                                                             B通道下限，B通道上限]，都为闭区间
%openStrel:输入strel对象，对布景进行开操作
%closeStrel:输入strel对象，对布景进行闭操作
%outputImage:输出图像，已经进行了过滤操作
%version:1.0.3
%author:jinshuguangze
%data:5/23/2018

   	p=inputParser;%构造入口检查对象
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
    [row,col,~]=size(inputImage);%获得图像长宽
    [Rrow,Rcol]=find(inputImage(:,:,1)>=filter(1,1) & inputImage(:,:,1)<=filter(1,2));%获取R通道
    [Grow,Gcol]=find(inputImage(:,:,2)>=filter(2,1) & inputImage(:,:,2)<=filter(2,2));%获取G通道
    [Brow,Bcol]=find(inputImage(:,:,3)>=filter(3,1) & inputImage(:,:,3)<=filter(3,2));%获取B通道
    indexArray=intersect(intersect(cat(2,Rrow,Rcol),cat(2,Grow,Gcol),'rows'),cat(2,Brow,Bcol),'rows');%获取交叉索引
    
    filterImage=ones(row,col);
    for i=1:size(indexArray,1)
        filterImage(indexArray(i,1),indexArray(i,2))=0;
    end
    
    if ~isempty(openStrel)%开操作
        filterImage=imopen(filterImage,openStrel);
    end
    if ~isempty(closeStrel)%闭操作
        filterImage=imclose(filterImage,closeStrel);
    end 
    
    outputImage=ones(row,col,3);%构造空白背景的输出图像
    for i=1:row
        for j=1:col
            if ~filterImage(i,j)
                outputImage(i,j,:)=inputImage(i,j,:);%填充
            end
        end
    end
end

