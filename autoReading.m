%自动读取角果点云并对齐
for i=1:4
    mat=zeros(1,7);
    mat(i+3)=1;
    pc{i}=pcread(txt2pcd(mat,['C:\Users\40825\Desktop\点云数据\方向',num2str(i)]));
    %pc{i}=pcdenoise(pc{i});
end

pcCompose=pc{1};
for i=2:4
    pcTform=pcregistericp(pc{i},pcCompose,'Extrapolate',true,'MaxIterations',10000000,'Tolerance',[0.0001,0.0005]);
    pcCompose=pcmerge(pc{1},pctransform(pc{i},pcTform),0.0001);
end

pcshow(pcCompose);
clear i;
clear mat;