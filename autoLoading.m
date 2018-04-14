for i=1:5
    I{i}=imread(['C:/Users/阿坤/Desktop/',num2str(i),'_o.jpg']);
    I{i}=autoRotating(I{i});
    J{i}=rgb2gray(I{i});
    J{i}=autoCutting(J{i});
end
%%TODO:加载籽数量真实值%%