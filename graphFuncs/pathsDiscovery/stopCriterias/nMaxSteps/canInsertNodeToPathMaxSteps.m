function [bool,ASO] = canInsertNodeToPathMaxSteps(ASO)
    bool = ASO.stepsCounter<ASO.nMaxSteps;
end