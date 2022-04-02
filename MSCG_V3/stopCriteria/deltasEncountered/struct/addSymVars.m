function addSymVars(m,vars)
    for i=1:length(vars)
        m(sym2str(vars(i)))=[];
    end
end