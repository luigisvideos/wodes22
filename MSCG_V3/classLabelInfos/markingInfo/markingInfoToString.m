function [str] = markingInfoToString(markingInfo)
    markedPlaces=find(markingInfo>0);
    str=[];
    for i=1:length(markedPlaces)
       str=[str,'p',num2str(markedPlaces(i))];
       mark  = markingInfo(markedPlaces(i));
       if mark>1
           str=[str, '*',num2str(mark),' '];
       else
           if i<length(markedPlaces)
            str=[str, ' '];
           end
       end
    end
end