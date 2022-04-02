function removeSymVars(m,vars)
    for i=1:length(vars)
        if isKey(m,sym2str(vars(i)))
            remove(m,sym2str(vars(i)));
        end
    end
end