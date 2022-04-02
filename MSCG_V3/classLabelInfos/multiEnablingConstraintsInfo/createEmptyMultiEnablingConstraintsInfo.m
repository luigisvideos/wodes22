function [info] = createEmptyMultiEnablingConstraintsInfo(T)
    %info is a cell array of length |T|, each element is an array of
    %intervals; these intervals represent the "extra" intervals that
    %account for the enablings other than the main one, which is still
    %handled by "constraintsInfo". in other words, this info is void if no
    %transition has degree greater than 1.
    %in each of such arrays, the last interval (aged k) is the youngest and the
    %first (aged 1) is the oldest. the age field is contained in each
    %interval info.
    info = cell(1,T);
end