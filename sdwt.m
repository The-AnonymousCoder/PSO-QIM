% coordinates : [x1,x2,x3,...,xn]
function   [L,H]= sdwt(coordinates)
  n = length(coordinates);

   v(1:n)=0;
  v(1:2:2*n-1)=coordinates;
  
  for i=2:2:2*n-2
      v(i) = 0.5*(v(i-1)+v(i+1));
  end
  v(2*n)=0.5*(v(1)+v(2*n-1));
  
%   spreadM = [];
%   spreadM(n,2*n)=0;
%   
%   for i=1:n
%       spreadM(i,2*i-1)=1;
%       spreadM(i,2*i)=0.5;
%       if (i<n)
%           spreadM(i+1,2*i)=0.5;
%       else
%           spreadM(1,2*i)=0.5;
%       end
%   end
%   
%     v=coordinates*spreadM;
    [L,H] = dwt(v,'haar');
end
%   Copyright QCY