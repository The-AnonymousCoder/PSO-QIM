% coordinates : [x1,x2,x3,...,xn]
function   coordinates= isdwt(L,H)
  scoord = idwt(L,H,'haar');
  n = length(L);
  sM=[];
  sM(2*n,n)=0;
  for i=1:n
      sM(2*i-1,i)=1;
  end
  coordinates=scoord*sM;
  
end

%   Copyright QCY