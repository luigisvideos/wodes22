function [str] = timePassedInfoToString(timePassedInfo)
if isnumeric(timePassedInfo)
     str = num2str(timePassedInfo);
else
    
    str = sym2str(timePassedInfo);
end
end