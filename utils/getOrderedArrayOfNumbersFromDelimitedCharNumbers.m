function arr = getOrderedArrayOfNumbersFromDelimitedCharNumbers(tline,delimiter,order)
    assert(length(delimiter)==1);
    sidx = find(tline==delimiter);
    sidx =[0,sidx,length(tline)+1];
    arr=[];
    for i=1:length(sidx)-1
        arr=[arr,str2num(tline(sidx(i)+1:sidx(i+1)-1))];
    end
    if (exist('order','var') && order)
        arr=sort(arr);
    end
end