function outputImage = regionFilter(inputImage,method,length,varargin)
%regionFilter:������ͼ����л���ʵ���˽�ѡ������ߴ���������
%inputImage:����ͼ�񣬿���ΪRGB���ҶȺͶ�ֵͼ��
%method:ʶ���Ե�ķ�������ʹ�á�Sobel������Prewitt������Roberts������Log������Zerocross������Canny������Approxcanny�������ַ���
%length:����Ȥ����Ĺ��Ƴ��ȣ�������˸ú��򳤶����µ�����ᱻ����ع��˵�
%width:����Ȥ����Ĺ��ƿ�ȣ�������˸����򳤶����µ�����ᱻ����ع��˵�����������룬����ֵĬ�Ϻͳ������
%outputImage:����������ͼ��������ͼ������һ��
%version:1.0.5
%author:jinshuguangze
%data:5/22/2018

    p=inputParser;%������ڼ�����
    p.addRequired('inputImage',@(x)validateattributes(x,{'numeric'},...
        {'3d','real','nonnegative'},'regionFilter','inputImage',1));
    p.addRequired('method',@(x)any(validatestring(x,...
        {'Sobel','Prewitt','Roberts','Log','Zerocross','Canny','Approxcanny'},'regionFilter','method',2)));
    p.addRequired('length',@(x)validateattributes(x,{'numeric'},...
        {'scalar','integer','positive'},'regionFilter','length',3));    
    p.addOptional('width',0,@(x)validateattributes(x,{'numeric'},...
        {'scalar','integer','positive'},'regionFilter','width',4));
    p.parse(inputImage,method,length,varargin{:});
    inputImage=p.Results.inputImage;
    method=p.Results.method;
    length=p.Results.length;
    width=p.Results.width;
    
    if ndims(inputImage)==3%�������ͼ����RGBͼ����ת�ɻҶ�ͼ��
        handleImage=rgb2gray(inputImage);
    else
        handleImage=inputImage;
    end
    
    if ~width%�����������룬����ֵ�볤�����
        width=length;
    end
    
    edgeImage=edge(handleImage,method);%��ͼ����б�Ե���
    closeImage=imclose(imclose(edgeImage,strel('line',width,0)),strel('line',length,90));%��ͼ������������ϵ���ģ��պ�
    openImage=imopen(closeImage,strel('square',min(length,width)));%��ͼ����п����������˱��˺�����
    %��ͼ��ȡ���õ����ͼ��
    
    row=size(openImage,1);%ͼ�������
    col=size(openImage,2);%ͼ�������
    inputImage=im2double(inputImage);%˫���Ȼ�
    outputImage=ones(row,col,3);%����հױ��������ͼ��
    for i=1:row
        for j=1:col
            if openImage(i,j)
                outputImage(i,j,:)=inputImage(i,j,:);%���
            end
        end
    end         
end