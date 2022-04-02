function [maxClassNumber] = getMaxClassNumber(tree)
    maxClassNumber = max(cellfun(@(x)str2double(x),keys(tree)));
end

