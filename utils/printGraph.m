function [status,cmdout,marksMap]= printGraph( graph,startNodeID, imageName, showID, showLambda,nPOb, isSeq, printM_i)
    
assert(nargin==3 || nargin==8,'Incorrect number of input args');
   
if nargin==3
    showID=true;
    showLambda=false;
    nPOb = 0;
    isSeq = false;
    printM_i = false;
end

nodes = values(graph);
showXLabels=false;
if(not(exist('percIncr','var')))
    percIncr=1;
end

marksMap=[];
if(isSeq && printM_i)
    marksMap = containers.Map( 'KeyType','int32', 'ValueType','int32'); %initializing map
    [ initmark, trans ] = getMarkingsAndTransitionsFromID( startNodeID, nPOb);
    marksMap(initmark{end}) = 0;
    counter=1;
    vMarkings=[];
   for i=1:length(nodes)
       [ marks, trans ] = getMarkingsAndTransitionsFromID( getNodeID(nodes{i}), nPOb);
       %if(not(isKey(marksMap,marks{end})))
       %   marksMap(marks{end}) = counter  ;
       %   counter=counter+1;
       %end
       vMarkings = union(vMarkings,marks{end});
   end
   vMarkings = setdiff(vMarkings,initmark{end});
   %ordering and changing value (1->nMarks-1)
   counter = 1;
   for i=1:length(vMarkings)
       minv = min(vMarkings);
       marksMap(minv) = counter;
       vMarkings(vMarkings==minv)=[];
       counter=counter+1;
   end
end

fontsize=22*percIncr;
minlen=1;
newline=char(13);
infSym = '&#969;';
nodesWidth=1.7;
mapNodeToIndex = containers.Map( 'KeyType','char', 'ValueType','any'); %initializing map

function string = getSString(index)
    string = ['s',num2str(index),''];
end

function string = getTString(index)
    string = ['t',num2str(index),''];
end

dotCode=['digraph G{ ',newline,'rankdir=LR',newline]; 

% states code
dotCode=[dotCode,'',newline...
    'style=filled; color=white; ',newline...
    'node [shape=circle, fixedsize=true, width=',num2str(nodesWidth),'];',newline,'',newline];

toAddLater = '';
stringToAdd='';
for i=1:length(nodes)
       stringToAdd=[getSString(i),' [label=<'];
       
       if(showID)
           if(isSeq)
               if(not(printM_i))
                stringToAdd=[stringToAdd,strrep(getPedicedNodeID(getNodeID(nodes{i})),'inf',infSym),'<br/> '];
               else
                   [ marks, trans ] = getMarkingsAndTransitionsFromID( getNodeID(nodes{i}), nPOb);
                   stringToAdd=[stringToAdd,strrep(getPedicedM_iNodeID(marks, trans, marksMap),'inf',infSym),'<br/> '];
               end
           else
               stringToAdd=[stringToAdd,getNodeID(nodes{i}),'<br/> '];
           end
       end
       if(showLambda)
            if(not(isSeq) || not(printM_i))
                stringToAdd=[stringToAdd,'<I>&lambda;=',getLabel(nodes{i}),'</I>'];
            else
                stringToAdd=[stringToAdd,'<I>&lambda;=',getPedicedM_iNodeID({str2num(getLabel(nodes{i}))},[],marksMap),'</I>'];
            end
       end
       stringToAdd=[stringToAdd,'>, fontsize=',num2str(fontsize)];
       if(showXLabels)
       stringToAdd=[stringToAdd,', xlabel=<<I>',getSString(i),'</I>>'];
       end
   if(isequal(startNodeID,getNodeID(nodes{i})))
       stringToAdd=[stringToAdd,', color=red'];
   end
    stringToAdd=[stringToAdd,'];',newline];
    if(isequal(startNodeID,getNodeID(nodes{i})))
        dotCode=[dotCode,stringToAdd];
    else
        toAddLater=[toAddLater,stringToAdd];
    end
    mapNodeToIndex(getNodeID(nodes{i})) = i;
end
dotCode=[dotCode,toAddLater];
dotCode=[dotCode,'s0 [style = invis width=0.001];'];
dotCode=[dotCode,newline,newline];

% edges code
toAddLater = '';
for i=1:length(nodes)
    node = nodes{i};
    out = getOutIDs(node);
    for k=1:length(out)
        if(strcmp(out(k),getNodeID(node)))
            concatTrLabels = true;
        else
            concatTrLabels=false;
        end
        tr = getLinkingTransitions( node ,char(out(k)));
        tLabel = '';
        for tInd=1:length(tr)
            if(concatTrLabels)
                addVirgol = ',';
                if(tInd==1)
                   addVirgol = ''; 
                end
                tLabel = [tLabel,addVirgol,' t<SUB>',num2str(tr(tInd)),'</SUB>'];
            else
                tLabel = ['t<SUB>',num2str(tr(tInd)),'</SUB>'];
            end
            if(not(concatTrLabels) || (concatTrLabels && tInd==length(tr)))
                stringToAdd=[getSString(i),'->',getSString(mapNodeToIndex(char(out(k)))),'[minlen=',num2str(minlen),', label=<',tLabel,'>, fontsize=',num2str(fontsize),'];',newline'];
                if(not(isequal(startNodeID,getNodeID(nodes{i}))))
                    toAddLater = [toAddLater,stringToAdd];
                else
                    dotCode=[dotCode,stringToAdd];
                end
            end
        end
    end
end
dotCode = [dotCode,toAddLater,'s0->',getSString(mapNodeToIndex(startNodeID)),';'];
% ending graph
dotCode=[dotCode,newline,'}',newline];



%saving code to file
fileID = fopen('dotGraph.txt','w');
fprintf(fileID,'%s',dotCode);
fclose(fileID);

%executing dot
% [status,cmdout] = system(['dot -T jpg dotGraph.txt -o ',imageName,'.jpg']);
setenv('PATH','C:\graphviz\bin');
[status,cmdout] = system(['dot -Tpng:cairo -Gdpi=250 dotGraph.txt > ',imageName,'.png']);

filePath = [pwd,'\',imageName,'.png'];
im=imread(filePath);
imwrite(im,[pwd,'\',imageName,'.jpg']);
delete(filePath);
delete('dotGraph.txt');

if status==1
    warning('Unable to write: close open images or install graphviz');
end


end

