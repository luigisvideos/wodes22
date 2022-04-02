function printIDsArray(array,IOData)
      if not(isempty(array)) disp(strcat(9,getSignalNameAndInfoFromID(array{1},IOData))); end
      for j=2:length(array)
          if not(isempty(array{j})) disp(strcat(9,getSignalNameAndInfoFromID(array{j},IOData))); end
      end
end

