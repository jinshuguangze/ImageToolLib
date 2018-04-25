function Debugger_regionExpanding(inputImage)
%Debugger_regionExpanding:为函数regionExpanding的专用Debugger
%inputImage:输入函数中的stateImage，增大状态图中的状态分辨度并输出图像
%versin:1.0.2
%author:jinshuguangze
%data:4/23/2018

    [row,col]=size(inputImage);
    for i=1:row
        for j=1:col
            switch inputImage(i,j)
                case 0
                    color=[1,1,1];
                case 1
                    color=[0,0,0];
                case 2
                    color=[0,0,1];
                case 3
                    color=[1,1,0];
            end
            inputImage(i,j,1:3)=color;
        end
    end
    imshow(inputImage);
end

