function tr=getMultiEnablingConstrainedTransitions(multiEnablingConstraintsInfo)
    idx = cellfun(@(x) not(isempty(x)),multiEnablingConstraintsInfo);
    tr = 1:length(idx);
    tr = tr(idx);
end