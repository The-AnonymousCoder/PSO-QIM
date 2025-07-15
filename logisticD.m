function ofy=logisticD(ozl,init)
[m n]=size(ozl);
l=linspace(0,0,m*n);
l(1)=init;
for i=2:m*n
    l(i)=1-2*l(i-1)*l(i-1);
end
[lsort,lindex]=sort(l);
ofy=ozl;
for i=1:m*n
    ofy(lindex(i))=ozl(i);
end

