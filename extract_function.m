
function [img,nc,ber]=extract_function(originshpfile,w)

M =size(w);
watermarkLength = M(1)*M(2);

ww={};
for i=1:watermarkLength
   ww{i}=[];
end

R=3*10^-2;
Mcof = 10^6;

geotype = originshpfile(1).Geometry;
allP=[];
allEmbed=[];
for i=1:length(originshpfile)
    xarray = originshpfile(i).X;
    yarray =  originshpfile(i).Y;
    xnotnanindex=find(~isnan(xarray));
    ynotnanindex=find(~isnan(yarray));
    xarray=xarray(xnotnanindex)';
    yarray=yarray(ynotnanindex)';
    
%      if(string(geotype)=='Polygon')
%         xarray=xarray(1:end-1);
%         yarray=yarray(1:end-1);
%      end

%     xarray = fliplr(xarray);
%     yarray = fliplr(yarray);

    xys=[xarray  yarray];
 
    if(length(xarray)==0)
        continue
    end
    [LX,HX] = sdwt(xys(:,1)');
    [LY,HY] = sdwt(xys(:,2)');
       
    % ����ˮӡǶ�룬QIMǶ��ˮӡ
    for n=1:length(HX)
        if(HY(n)==0)  %zero? skip
            continue;
        end  
        
        ratioLXY = HX(n) / HY(n);
        ratioLXY_forrecord=ratioLXY;
        ratioLXY = ratioLXY*Mcof;
        p=mod(floor(ratioLXY/100),watermarkLength)+1;
        
        % ˮӡ��ȡ
        if mod(ratioLXY,R)<=R/2
            ww{p}=[ww{p},0];
        else
            ww{p}=[ww{p},1];
        end
        
    end

end

w2=[];
w2(1:watermarkLength)=0;
% ͶƱ
for i=1:watermarkLength
    v = sum(ww{i})/length(ww{i});
    if( v <0.5)
      w2(i)=0;
    else
      w2(i)=1;
    end
end

w2=reshape(w2,[M(1),M(2)]);
w2=logisticD(w2,0.98);
img=w2;
nc=NC(w2,w);
ber=BER(w2,w);
end

