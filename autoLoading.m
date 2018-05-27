for i=1:5
    I{i}=imread(['C:/Users/Default/Desktop/',num2str(i),'_o.jpg']);
    I{i}=autoRotating(I{i});
    J{i}=rgb2gray(I{i});
    J{i}=autoCutting(J{i});
    K{i}=regionExpanding_Gray(J{i},0.1,0,0,'method','None','operator','Low');
end
clear i;
%%TODO:加载籽数量真实值%%