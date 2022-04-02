function [index] = findStringInCellArray(string,cellarray,multiple)
   if not(exist('multiple','var'))
       multiple=false;
   end
   
   if not(multiple)
       index = find(strcmp(cellarray,string), 1);
   else
       index = find(strcmp(cellarray,string));
   end
end

