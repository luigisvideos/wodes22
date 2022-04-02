function [str] = sym2str(symb)
    
    str = arrayfun(@char, symb, 'uniform', 0);
    str = str{1};
end