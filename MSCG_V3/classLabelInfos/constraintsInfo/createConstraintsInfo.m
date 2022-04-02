function [info] = createConstraintsInfo(intervalInfos)
    % intervalInfos must be a map associating to each theta an interval
    assert(isequal(class(intervalInfos),'containers.Map'));
    info = intervalInfos;
end