%自动读取角果点云
for i=1:4
    mat=zeros(1,7);
    mat(i+3)=1;
    pc{i}=pcread(txt2pcd(mat,['C:\Users\阿坤\Desktop\点云数据\方向',num2str(i)]));
    pc{i}=pcdenoise(pc{i});
    pcsample{i}=pcdownsample(pc{i},'gridAverage',0.2);
end

for i=2:4
    pcTform=pcregistericp(pcsample{i},pcsample{1});
    pcCompose=pcmerge(pc{1},pctransform(pc{i},pcTform),0.01);
end

pcshow(pcCompose);
clear i;
clear mat;