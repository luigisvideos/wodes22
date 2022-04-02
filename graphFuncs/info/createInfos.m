function [infos] = createInfos(infoCouples)
    %infoCouples is a cell-array where in position i (i odd) there is a
    %the ID of the info and in position i+1 there is the info itself
    
    nCouples=length(infoCouples)/2;
    assert(floor(nCouples)==nCouples,'Infos must be a cell array of couples: infoID,infoData')
    infos = createEmptyInfos();
    for i=1:2:length(infoCouples)
        type = infoCouples{i};
        info = infoCouples{i+1};
        infos=setInfoToInfos(info,type,infos);
    end
end

