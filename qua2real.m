function realMatrix = qua2real(quaternion)
%qua2real:将四元数用实数矩阵表示
%quaternion:输入四元数对象
%realMatrix:返回4*4的实数矩阵
%version:1.0.0
%author:jinshuguangze
%data:5/6/2018
    
    if ~isa(quaternion,'quaternion')
        disp('请输入四元数对象！');
    end
    
    mat=quaternion.compact;
    realMatrix=mat(1)*[1 0 0 0;0 1 0 0;0 0 1 0;0 0 0 1]+...
        mat(2)*[0 -1 0 0;1 0 0 0;0 0 0 -1;0 0 1 0]+...
        mat(3)*[0 0 -1 0;0 0 0 1;1 0 0 0;0 -1 0 0]+...
        mat(4)*[0 0 0 -1;0 0 -1 0;0 1 0 0;1 0 0 0];
end