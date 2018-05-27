function outputImages = regionGrowing(inputImage,filter,range)
%regionGrowing:ʹ���������������Ҷ�ͼ��ָ����
%inputImage:����ͼ�񣬿���Ϊ�Ҷ�ͼ����߶�ֵͼ��
%filter:������ʼ�Ҷ���ֵ
%range:��������������ҶȲ������ֵ
%outputImages:���ͼ��ϸ�����飬ÿ��Ԫ������һ������ͼ��
%version:1.0.2
%author:jinshuguangze
%data:4/10/2018

    [row,col]=size(inputImage);%���ԭͼ�����
    inputImage=im2double(inputImage);%������ͼ��ת��˫����
    outputImages{1}=zeros(row,col);%Ĭ�����
    count=0;%���ͼ��������Ĭ��Ϊ0
    for i=1:row
        for j=1:col
            if(inputImage(i,j)<filter)                
                Stack=[i,j,inputImage(i,j)];%ģ���ջ
                adv=inputImage(i,j);%���ó�ʼƽ���Ҷ�ֵ
                inputImage(i,j)=1;%��ֹ��ѭ����ȷ������󣬽�����1
                
                Point=0;%ջָ��
                miny=i;%��ͨ����Χ���������ʼ��
                maxy=i;
                minx=j;
                maxx=j;

                %����������
                while Point<size(Stack,1)%��ջָ��λ��ջβ��ʱ����ֹѭ��                    
                    y=Stack(Point+1,1);%ʹ����ʱ�����Խ�Լ���ʳɱ�
                    x=Stack(Point+1,2);
                    if(x>1 && inputImage(y,x-1)<=adv+range)%�������ֲ�ͬ��״̬�����з���
                        state=1;%������µ���ͨ��
                    elseif(x<col && inputImage(y,x+1)<=adv+range)
                        state=2;%�ұ����µ���ͨ��
                    elseif(y<row && inputImage(y+1,x)<=adv+range)
                        state=3;%�±����µ���ͨ��
                    else
                        state=0;%����ͨ��
                    end
                    
                    switch state
                        case 0
                            Point=Point+1;%�������ص�û��������ͨʱ��������һ��
                        case 1
                            x=x-1;
                           if(minx>x)%�����߽���չ�����������minx
                               minx=x;
                           end
                        case 2
                            x=x+1;
                            if(maxx<x)%����ұ߽���չ�����������maxx
                                maxx=x;
                            end
                        case 3
                            y=y+1;
                            if(maxy<y)%�����߽���չ�����������maxy
                                maxy=y;
                            end
                    end
                    
                    %�������ͨ�������״̬
                    if(state)
                        z=inputImage(y,x);%��ȡ�Ҷ�
                        adv=(adv*size(Stack,1)+z)/(size(Stack,1)+1);%���¼���Ҷ�ƽ��ֵ

                        if(Point)%���ڵ�PointΪ0ʱ���������ԣ��ʷ�������
                            Stack=[[y,x,z];Stack(Point+1:end,:)];%��ջ
                        else
                            Stack=[Stack(1:Point,:);[y,x,z];Stack(Point+1:end,:)];%��ջ
                        end                   
                        inputImage(y,x)=1;%��ֹ��ѭ����ȷ������󣬽�����1
                    end
                end
                
                %�趨�����ֵ���Թ�������
                if size(Stack,1)>100
                    count=count+1;%���ͼ����������
                    outputImages{count}=ones(maxy-miny+1,maxx-minx+1);%����ɫĬ��Ϊ��
                    for temp=1:size(Stack,1)%��λ����Ϣ��Ҷ������ȥ
                        outputImages{count}(Stack(temp,1)-miny+1,...
                            Stack(temp,2)-minx+1)=Stack(temp,3);
                    end
                end
            end
        end
    end
end
