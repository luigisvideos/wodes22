function [sortedC] = sortCellArrayOfStrings(C)
    assert(iscell(C));
    [dummy, index] = sort([C{:}]);
    sortedC = C(index);
end

