function [IDpaths,transitionPaths,newWinFlags] = filterOutPrefixPaths(IDpaths,transitionPaths,newWinFlags)
    toFilter =[];
   %filter out prefixes
   for i=1:length(IDpaths)
      for j=i+1:length(IDpaths) 
         
         IDpath_i = IDpaths{i};
         IDpath_j = IDpaths{j};
         
         if length(IDpath_i) < length(IDpath_j)
             minIDpath = IDpath_i;
             maxIDpath = IDpath_j;
             minIdx = i;
         else
             minIDpath = IDpath_j;
             maxIDpath = IDpath_i;
             minIdx = j;
         end
         
         if isequal(maxIDpath(1:length(minIDpath)),minIDpath)
             toFilter = [toFilter,minIdx];
         end
         
      end
   end
   
   IDpaths(toFilter) =[]; transitionPaths(toFilter) = [];
   if exist('newWinFlags','var') && not(isempty(newWinFlags))
      newWinFlags(toFilter) =[];
   end
end

