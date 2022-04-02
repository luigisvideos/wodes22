function [npre,npost,nsequences,nlabels] = fuseTransitions(pre,post,sequences,labels)
    assert(iscell(labels));
    assert(length(labels)==size(pre,2) && length(labels)==size(post,2));
    
    tr=[];
    for k=1:length(sequences)
        tr=union(tr,sequences{k});
    end
    assert(isequal(tr.',1:size(pre,2)),'Almeno una sequenza contiene una transizione con indice superiore al numero di colonne di pre o post');
    
    transMap=[];
    tCount=1;
    toIgnore=[];
    for t=1:size(pre,2)
        if(isempty(find(toIgnore==t,1)))
            for tt=t+1:size(pre,2)
               if (isempty(find(toIgnore==tt, 1)) && isequal([pre(:,t);post(:,t)],[pre(:,tt);post(:,tt)]) && isequal(labels{t},labels{tt}))
                   transMap(tt) = tCount;
                   toIgnore=union(toIgnore,tt);
               end
            end
            transMap(t) = tCount;
            tCount=tCount+1;
        end
    end
    
    nsequences=[];
    for t=1:size(pre,2)
       npre(:,transMap(t)) = pre(:,t); 
       npost(:,transMap(t)) = post(:,t); 
       nlabels{transMap(t)} = labels{t};
    end
    
    for s=1:length(sequences)
       seq=sequences{s};
       for t=1:size(pre,2)
           seq(seq==t) = transMap(t);
           nsequences{s}=seq;
       end
    end
end

