function [outputData,tform] = blindLayer(inputData,varargin)
%blindLayer:在未知分节点个数的情况下，估算节点个数并将一个数组聚集分类
%inputData:数据数组，可以为任意非0维实有限数组
%range:当分层数为一时，判断为有效的阈值，范围是(0,,1]，如果不输入，则默认为0.9
%outputData:已经分好层的细胞数组，每层均值是由小到大
%tform:记录输出数据中，数据在输入数组中的原始位置，即inputData(:)中的下标
%version:1.0.5
%author:jinshuguangze
%data:5/9/2018

    p=inputParser;%构造入口检测对象
    p.addRequired('inputData',@(x)validateattributes(x,{'numeric'},...
        {'real','nonempty','finite'},'blindLayer','inputData',1));
    p.addOptional('range',0.9,@(x)validateattributes(x,{'double'},...
        {'real','scalar','>','0','<=','1'},'blindLayer','range',2));
    p.parse(inputData,varargin{:});
    inputData=p.Results.inputData;
    range=p.Results.range;

    outputData={};%初始化输出数据
    tform={};%初始化转换细胞数组
    warning('off','all');%暂时取消由于算法本身的警告显示
    for i=1:(size(inputData,1)-1)%得到所有节点个数情况下的分组和有效度
        [thresh{i},metric(i)]=multithresh(inputData,i);
    end
    warning('on','all');%再次开启
    
    if isempty(thresh) || isempty(metric)
        disp('出错，无法分组！');
        return;
    else
        if metric(1)>range%如果第一次分层就超过阈值，则直接确定层数为一
            index=1;
        else%如果没超过阈值
            effect=find(metric==-inf | ~metric);%找到第一个-Inf或者0的位置
            if isempty(effect)%如果没有，则搜索所有
                End=size(metric,2);%循环末尾是最后一个数
            else
                End=effect-1;%循环末尾是无效数字前面一个数
            end
            %计算有效度增长相对于自身的增长幅度，选择幅度最大者作为分层数量
            [~,index]=max((metric(2:End)-metric(1:(End-1)))/metric(1:(End-1)));
        end

        index=index+1;%由于是记录的是有效值相差比例的序号，所以需要加一以修正为正确的分层次数
        temp=[min(inputData)-1;thresh{index}(:);max(inputData)];%将所有节点排布下来并在首尾加入不对称界限
        count=0;%初始化有效分层数，如果一层中没有数字存在，则不计入有效分层数里面

        for i=1:(index+1)%对于所有的分层区间
            inRange=find(inputData>temp(i) & inputData<=temp(i+1));%两个分层中所有满足的数据标号
            if ~isempty(inRange)%如果不为空
                count=count+1;%计数器增加
                outputData{count}=inputData(inRange);%输出此分层
                tform{count}=inRange;%保留原始坐标
            end
        end
    end
end