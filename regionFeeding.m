function outputImages = regionFeeding(inputImage,filter,range)
%regionFeeding:ʹ���������������Ҷ�ͼ��ָ����
%inputImage:����ͼ�񣬿���Ϊ�Ҷ�ͼ����߶�ֵͼ��
%filter:������ʼ�Ҷ���ֵ
%range:��������������ҶȲ������ֵ
%outputImages:���ͼ��ϸ�����飬ÿ��Ԫ������һ������ͼ��
%version:1.0.2
%author:jinshuguangze
%data:4/12/2018

    [row,col]=size(inputImage);%���ԭͼ�����
    inputImage=im2double(inputImage);%������ͼ��ת��˫����
    outputImages{1}=ones(row,col);%Ĭ�����
    count=0;%���ͼ��������Ĭ��Ϊ0
    
    for i=1:row
        for j=1:col
            if(inputImage(i,j)<=filter)                             
                x=i;%������ʼ��
                y=j;
                right=y;%��ʼ��ͼ��Χֵ
                bottom=x;
                left=y;
                top=x;
                adv=inputImage(x,y);%���ó�ʼƽ���Ҷ�ֵ
                set=[x,y,adv];%������ʼ����
                inputImage(x,y)=1;%���õ��ԭͼ��ȥ��
                
                while 1
                    if(y<col && inputImage(x,y+1)<=adv+range)%�ұ�������ͨ��
                        y=y+1;
                    elseif(x<row && inputImage(x+1,y)<=adv+range)%�±�������ͨ��
                        x=x+1;
                    elseif(y>1 && inputImage(x,y-1)<=adv+range)%���������ͨ��
                        y=y-1;
                    elseif(x>1 && inputImage(x-1,y)<=adv+range)%�ϱ�������ͨ��
                        x=x-1;
                    else%û����ͨ���˳�ѭ��
                        break;
                    end
                                       
                    right=max(right,y);%����ͼ��Χֵ
                    bottom=max(bottom,x);         
                    left=min(left,y);
                    top=min(top,x);                  
                    h=inputImage(x,y);%��ô˵�Ҷ�ֵ
                    set=[set;x,y,h];%�����ݴ洢������
                    adv=(adv*size(set,1)+h)/(size(set,1)+1);%���¼���Ҷ�ƽ��ֵ
                    inputImage(x,y)=1;%���õ��ԭͼ��ȥ��
                end
                
                %�趨�����ֵ���Թ�������
                if size(set,1)>200
                    count=count+1;%���ͼ����������
                    outputImages{count}=ones(bottom-top+1,right-left+1);%����ɫĬ��Ϊ��
                    for temp=1:size(set,1)%��λ����Ϣ��Ҷ������ȥ
                        outputImages{count}(set(temp,1)-top+1,set(temp,2)-left+1)=set(temp,3);
                    end
                end
            end              
        end
    end
end
