function map=verticallyAppendInMap( map,key,value )
    if(isKey(map,key))
        map(key)=[map(key);value];
    else
        map(key)=value;
    end
end

