for i=1:6
    I{i}=imread(['C:/Users/Default/Desktop/',num2str(i),'_o.jpg']);
    I{i}=autoRotating(I{i});
    J{i}=rgb2gray(I{i});
    J{i}=autoCutting(J{i});
end
clear i;
%%TODO:加载籽数量真实值%%