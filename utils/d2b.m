function y = d2b(x,digits)

% Convert a decimanl number into a binary array
% 
% Similar to dec2bin but yields a numerical array instead of a string and is found to
% be rather faster

if nargin == 1
    digits = 1;
end

if(x==0)
    y=0;
    
    y=[zeros(1,digits-length(y)),y];
    return;
end
if(x==1)
    y=1;
    
    y=[zeros(1,digits-length(y)),y];
    return;
end

l=log(x)/log(2);
c = ceil(l); % Number of divisions necessary ( rounding up the log2(x) )
y(c) = 0; % Initialize output array
for i = 1:c
    r = floor(x / 2);
    y(c+1-i) = x - 2*r;
    x = r;
    
end
if(l==c)
    y=[1,y];
end

if(digits>length(y))
    y=[zeros(1,digits-length(y)),y];
end