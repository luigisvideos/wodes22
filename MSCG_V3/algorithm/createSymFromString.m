function [thisVar] = createSymFromString(str)
    eval(['syms ',str,' positive;']);
    eval(['thisVar = ',str,';']);
end

