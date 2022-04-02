function [elem,stack] = popElement(stack)
    elem = [];
    if not(isempty(stack))
        elem = stack{end};
        stack(end) = [];
    end
end