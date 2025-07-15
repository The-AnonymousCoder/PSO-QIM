function ozl=logisticE(o,init)
[m n]=size(o);
%l=zeros(m,n);
l=linspace(0,0,m*n);
l(1)=init;
for i=2:m*n
    l(i)=1-2*l(i-1)*l(i-1);%logistic
end
[lsort,lindex]=sort(l); % If l is a vector, lsort = l(IX). 
%               If A is an m-by-n matrix, then each column of IX is a 
%               permutation vector of the corresponding column of A.
%ozl =original zhi luan 表示置乱后的原始图像
ozl=o;
for i=1:m*n
    ozl(i)=o(lindex(i));
end
