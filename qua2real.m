function realMatrix = qua2real(quaternion)
%qua2real:����Ԫ����ʵ�������ʾ
%quaternion:������Ԫ������
%realMatrix:����4*4��ʵ������
%version:1.0.0
%author:jinshuguangze
%data:5/6/2018
    
    if ~isa(quaternion,'quaternion')
        disp('��������Ԫ������');
    end
    
    mat=quaternion.compact;
    realMatrix=mat(1)*[1 0 0 0;0 1 0 0;0 0 1 0;0 0 0 1]+...
        mat(2)*[0 -1 0 0;1 0 0 0;0 0 0 -1;0 0 1 0]+...
        mat(3)*[0 0 -1 0;0 0 0 1;1 0 0 0;0 -1 0 0]+...
        mat(4)*[0 0 0 -1;0 0 -1 0;0 1 0 0;1 0 0 0];
end