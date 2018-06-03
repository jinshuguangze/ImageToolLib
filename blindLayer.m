function [outputData,tform] = blindLayer(inputData,varargin)
%blindLayer:��δ֪�ֽڵ����������£�����ڵ��������һ������ۼ�����
%inputData:�������飬����Ϊ�����0άʵ��������
%range:���ֲ���Ϊһʱ���ж�Ϊ��Ч����ֵ����Χ��(0,,1]����������룬��Ĭ��Ϊ0.9
%outputData:�Ѿ��ֺò��ϸ�����飬ÿ���ֵ����С����
%tform:��¼��������У����������������е�ԭʼλ�ã���inputData(:)�е��±�
%version:1.0.8
%author:jinshuguangze
%data:5/9/2018

    p=inputParser;%������ڼ�����
    p.addRequired('inputData',@(x)validateattributes(x,{'numeric'},...
        {'real','nonempty','finite'},'blindLayer','inputData',1));
    p.addOptional('range',0.9,@(x)validateattributes(x,{'double'},...
        {'real','scalar','>','0','<=','1'},'blindLayer','range',2));
    p.parse(inputData,varargin{:});
    inputData=p.Results.inputData;
    range=p.Results.range;

    outputData={};%��ʼ���������
    tform={};%��ʼ��ת��ϸ������
    thresh={};%��ʼ���ָ�ϸ������
    metric=[];%��ʼ������ϸ������
    
    warning('off','all');%��ʱȡ�������㷨����ľ�����ʾ
    for i=1:min(20,(size(inputData,1)-1))%�õ����нڵ��������µķ������Ч��
        [thresh{i},metric(i)]=multithresh(inputData,i);
    end
    warning('on','all');%�ٴο���
    
    if isempty(thresh) || isempty(metric)
        disp('�����޷����飡');
        return;
    else
        if metric(1)>range%�����һ�ηֲ�ͳ�����ֵ����ֱ��ȷ������Ϊһ
            index=0;
        else%���û������ֵ
            effect=find(metric==-inf | ~metric);%�ҵ���һ��-Inf����0��λ��
            if isempty(effect)%���û�У�����������
                End=size(metric,2);%ѭ��ĩβ�����һ����
            else
                End=effect-1;%ѭ��ĩβ����Ч����ǰ��һ����
            end
            %������Ч�����������������������ȣ�ѡ������������Ϊ�ֲ�����
            [~,index]=max((metric(2:End)-metric(1:(End-1)))/metric(1:(End-1)));
        end

        index=index+1;%�����Ǽ�¼������Чֵ����������ţ�������Ҫ��һ������Ϊ��ȷ�ķֲ����
        temp=[min(inputData)-1;thresh{index}(:);max(inputData)];%�����нڵ��Ų�����������β���벻�Գƽ���
        count=0;%��ʼ����Ч�ֲ��������һ����û�����ִ��ڣ��򲻼�����Ч�ֲ�������

        for i=1:(index+1)%�������еķֲ�����
            inRange=find(inputData>temp(i) & inputData<=temp(i+1));%�����ֲ���������������ݱ��
            if ~isempty(inRange)%�����Ϊ��
                count=count+1;%����������
                outputData{count}=inputData(inRange);%����˷ֲ�
                tform{count}=inRange;%����ԭʼ����
            end
        end
    end
end