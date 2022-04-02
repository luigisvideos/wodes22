function info = getInfoFromInfos(infoTypeID,infos)
    if isKey(infos,infoTypeID)
        info=infos(infoTypeID);
    else
%         warning(['Info ',infoTypeID,' was not found']);
        info=[];
    end
end