function [thetaVar,trThetaState] = getTransitionTheta(tr,trThetaState,nTr)
    assert(isnumeric(tr));
    if not(exist('trThetaState','var')) || isempty(trThetaState)
        if not(exist('nTr','var'))
            thetaVar=  sym(['theta_',num2str(tr)],'positive');
            trThetaState = [];
            return;
        end
        trThetaState = sym('theta_%d',[1,nTr],'positive');
    end
    
    thetaVar = trThetaState(tr);
end