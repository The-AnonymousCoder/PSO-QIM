% 第一个参数 提取到的水印  第二个参数  原始水印  并且一定是二值图像 逻辑值
function N=NC(mark_get,mark_prime)
if size(mark_get)~=size(mark_prime)
    error('Input vectors must  be the same size!')%mark_get和mark_prime大小不等时，无法计算相关系数，报错！
else
    [m,n]=size(mark_get);
    fenzi=0;
    fenmu1=0;
    fenmu2=0;
    for i=1:m
        for j=1:n
            fenzi=fenzi+ mark_get(i,j)*mark_prime(i,j);
            fenmu1=fenmu1+mark_get(i,j)^2;
            fenmu2=fenmu2+mark_prime(i,j)^2;
        end
    end

    N=fenzi/sqrt(fenmu1*fenmu2);
end
end