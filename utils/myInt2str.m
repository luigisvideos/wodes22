function [ o ] = myInt2str( x )
if(x==0)
    o='0';
    return;
end
if(isequal(x,inf))
    o='inf';
    return;
end
negative=false;
if(lt(x,0))
    x=-x;
    negative=true;
end
maxvalue=max(x(:));
%maxvalue=intmax(class(x));%Alternative implementation based on class
required_digits=ceil(log(double(maxvalue+1))/log(10));
o=repmat(x(1)*0,size(x,1),required_digits);%initialize array of required size
for c=size(o,2):-1:1
   o(:,c)=mod(x,10);
   x=(x-o(:,c))/10;
end
o=char(o+'0');
if(negative)
    o=['-',o];
end