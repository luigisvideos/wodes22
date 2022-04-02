function ASO = consolEnTrCallback(algoInfo,enTrCallbackASO)
    val = [];
    ASO.stop = false;
    t_i = algoInfo.t_i;
    Ck = algoInfo.Ck;
    while(not(isequal(val,'y') || isequal(val,'n') || isequal(val,'ys') || isequal(val,'ns')))

        disp([newline,'****** Current class C',getNodeID(Ck),'. In detail: ******',newline]);
        printClassAndNeighborhood(Ck,algoInfo.graph); 
        disp(newline)
        val = input(['Fire transition t',num2str(t_i),' from class C',getNodeID(Ck),'?',newline,'Type: y/n/ys/ns (yes, no, yes and then stop, no and then stop: '],'s');


    end
    if isequal(val,'y') || isequal(val,'ys')
        ASO.fire=true;
    end
    if isequal(val,'n') || isequal(val,'ns')
        ASO.fire=false;
    end
    if isequal(val,'ys') || isequal(val,'ns')
        ASO.stop = true;
    end
    
end