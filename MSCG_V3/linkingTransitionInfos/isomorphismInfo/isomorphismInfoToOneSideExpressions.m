function [eqs] = isomorphismInfoToOneSideExpressions(isomorphismInfo)
    % generates an array of eqs based on the given isomorphism; each entry
    % is in the form Delta_e - Delta_q = 0 (one side)
    eqs = [];
    for i=1:size(isomorphismInfo,1)
        isomoEntry = isomorphismInfo(i,:);
        eqs = [eqs;isomoEntry(1) -  isomoEntry(2)];
    end
end

