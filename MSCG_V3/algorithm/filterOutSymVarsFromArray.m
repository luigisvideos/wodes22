function [v,filteredIdcs]=filterOutSymVarsFromArray(v)
       vars = symvar(v); 
       idcs = [];
       filteredIdcs = zeros(1,length(v));
       for idx=1:length(v)
          try 
              double(v(idx));
          catch ME
              filteredIdcs(idx)=1;
          end
       end
       filteredIdcs=logical(filteredIdcs);
       v(filteredIdcs) = [];
end

