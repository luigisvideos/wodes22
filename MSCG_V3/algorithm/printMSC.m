function [status,cmdout,marksMap]= printMSC( graph,startNodeID, imageName, bw, notag,printDistance,smallerGraph)
    
% bw, optional: if true, black and white graph is printed, false by default
% notag, optional: if true tagging info of each class is not printed, true by defulat
% printDistance, optional: if true prints the depth of each class with
% respect to the initial node, false by default
% smallerGraph, optional: if provided, must be a sub graph of the provided graph;
% classes prints the classes contained in graph and not contained in
% smallerGraph as 'extensions' of smallerGraph by using dashed lines

colorsWheel={'purple','black','red','blue','GoldenRod','maroon','darksalmon','Tomato'};

if exist('bw','var') && bw
    colorsWheel={'black','black'};
end
if not(exist('notag','var'))
    notag=true;
end
if not(exist('printDistance','var'))
   printDistance = false; 
end
showID=true;
showLambda=false;
nPOb = 0;
isSeq = false;
printM_i = false;

function toAddStr = addStr(str)
    if not(iscell(str))
      toAddStr = str;
    else
       toAddStr=[];
       for s=1:length(str)
          thisInt=strrep(str{s},'<=','&le;');
          thisInt=strrep(thisInt,'theta_','&theta;');
          thisInt=strrep(thisInt,'delta_','&Delta;');
          toAddStr = [toAddStr,thisInt];
          if s<length(str)
              toAddStr=[toAddStr,'\n '];
          end
       end
   end
end

nodes = values(graph);
nodesIDs = keys(graph);

extraNodesIDs = cell(0);
fronteerIDs = cell(0);

if exist('smallerGraph','var')
    lessNodesIDs = keys(smallerGraph);

    for i=1:length(nodesIDs)
       if not(isSmallerArrayContainedInBigger(nodesIDs(i), lessNodesIDs))
           extraNodesIDs=[extraNodesIDs,nodesIDs(i)];
       end
    end


    for j=1:length(extraNodesIDs)
        nodeID = extraNodesIDs{j};
        precNodes = getPredecessorNodes(graph,nodeID);
        for k=1:length(precNodes)
           fronteerIDs=[fronteerIDs, {getNodeID(precNodes(k))}];
        end
    end
end

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

dotCode=['digraph G{ ',newline,'',newline]; 

% states code
dotCode=[dotCode,'',newline...
    'style=filled; color=white; ',newline...
    'node [shape=record]; node [fontname="Greek"];',newline,'	',newline];

toAddLater = '';
stringToAdd='';
for i=1:length(nodes)
       stringToAdd=[getSString(i),' [label="'];
       
       stringToAdd=[stringToAdd,'{ C',getNodeID(nodes{i}),' |'];
       
       % printing infos
       infos=getNodeInfos(nodes{i});
       if not(isempty(infos))
           infosIDs = keys(infos);
           indexMultiEn = find(cellfun(@(x) isequal(x,getMultiEnablingConstraintsInfoID()),infosIDs)>0);
           if not(isempty(indexMultiEn))
               infosIDs(indexMultiEn) = [];
           end
           if ~isempty(infosIDs)
               for in=1:length(infosIDs)
                   info = infos(infosIDs{in});
                   if not(notag && isequal(infosIDs{in},getTagInfoID()))

                       str = infoToString(info,infosIDs{in});
                       
                       stringToAdd = [stringToAdd,addStr(str)];
                       
                       if isequal(infosIDs{in},getConstraintsInfoID())
                           if not(isempty(indexMultiEn))
                               stringToAdd=[stringToAdd,'\n '];
                               stringToAdd=[stringToAdd,addStr(infoToString(infos(getMultiEnablingConstraintsInfoID()),getMultiEnablingConstraintsInfoID()))];
                           end
                       end
                       
                       if in<length(infosIDs) && not(notag && isequal(infosIDs{in+1},getTagInfoID()) && in+1==length(infosIDs)) && not(isempty(infoToString(infos(infosIDs{in+1}),infosIDs{in+1})))
                          stringToAdd = [stringToAdd,' | '];
                       end
                   end
               end
           end
       end
           % end printing infos
           stringToAdd=[stringToAdd,'}", fontsize=',num2str(fontsize)];
   if(isequal(startNodeID,getNodeID(nodes{i})))
       stringToAdd=[stringToAdd,', color=red'];
   end
   if isSmallerArrayContainedInBigger({getNodeID(nodes{i})},extraNodesIDs)
       stringToAdd=[stringToAdd,', style=dashed'];
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
color = 'black';
% edges code
toAddLater = '';
for i=1:length(nodes)
    node = nodes{i};
    if isequal(getNodeID(node),'15')
        disp('');
    end
    out = getOutIDs(node);
    for k=1:length(out)
        if(strcmp(out(k),getNodeID(node)))
%             concatTrLabels = true; ?????
            concatTrLabels=false;
        else
            concatTrLabels=false;
        end
        tr = getLinkingTransitions( node ,char(out(k)));
        
        tLabel = 'labelfontname=Greek;';
        for tInd=1:length(tr)
            if(concatTrLabels)
                addVirgol = ',';
                if(tInd==1)
                   addVirgol = ''; 
                end
                tLabel = [tLabel,addVirgol,' t<SUB>',num2str(tr(tInd)),'</SUB>'];
            else
                infos = getInfosOfLinkingTransition(node,tr(tInd));
                intstr=arcIntervalToString(getInfoFromInfos(getIntervalInfoID(),infos));
                intstr=strrep(intstr,'delta_','&Delta;');
                minoreqidcs=find(intstr=='<');
                lIdx=minoreqidcs(1)-2; uIdx = minoreqidcs(2)+3;
                
                isomorphs=getInfoFromInfos(getIsomorphismInfoID(),infos);
                [fstr] = isomorphismInfoToString(isomorphs);   
                isomostr='';
                if not(isempty(fstr))
                    for is=1:length(fstr)
                       isomostr=[isomostr, strrep(fstr{is},'delta_','&Delta;')];
                       if is<length(fstr)
                           isomostr=[isomostr,'<BR/>'];
                       end
                    end
                end
                distance = getInfoFromInfos(getDistanceInfoID(),infos);
                label = getInfoFromInfos(getLabelInfoID(),infos);
                if isnumeric(label)
                    label = num2str(label);
                end

%                 color = colorsWheel{};
                color = colorsWheel{randi([mod(k,length(colorsWheel)-1)+1,length(colorsWheel)])};
                tLabel = ['<font color="',color,'"> t<SUB>',num2str(tr(tInd)),'</SUB>, '];
                if not(isempty(label)) && not(isequal(label,''))
                    tLabel=[tLabel,' ',label];
                end
                tLabel=[tLabel,'<BR/>',intstr(lIdx+5:uIdx-5),' &euro; [',intstr(1:lIdx),',',intstr(uIdx:end),']'];
                if not(isempty(isomostr))
                    tLabel=[tLabel,',<BR/> ',isomostr];
                end
                if not(isempty(distance)) && printDistance
                    tLabel=[tLabel,',<BR/> minDistFromC0:',num2str(distance)];
                end

                tLabel=[tLabel,'</font>'];
            end
            if(not(concatTrLabels) || (concatTrLabels && tInd==length(tr)))
                stringToAdd=[getSString(i),'->',getSString(mapNodeToIndex(char(out(k)))),'[minlen=',num2str(minlen),', label=<',tLabel,'>, fontsize=',num2str(fontsize),', color=',color,', fontname=Greek'];
                
        
                if isSmallerArrayContainedInBigger({getNodeID(node)},fronteerIDs) || isSmallerArrayContainedInBigger({getNodeID(node)},extraNodesIDs)
                    succ = getSuccessorNode(graph, node,tr);
                    if isSmallerArrayContainedInBigger({getNodeID(succ)},extraNodesIDs)
                        stringToAdd=[stringToAdd,', style=dashed'];
                    end
                end
                
                stringToAdd=[stringToAdd,'];',newline];
                
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



%saving graphviz code to file dotGraph.txt
fileID = fopen('dotGraph.txt','w');
fprintf(fileID,'%s',dotCode);
fclose(fileID);

%executing dot from file dotGraph.txt
setenv('PATH','C:\Program Files\Graphviz\bin'); 

[status,cmdout] = system(['dot -Tsvg:cairo -Nfontname=Times-Roman dotGraph.txt > ',imageName,'.svg']);

if status==1
    warning(['Unable to write svg file: close open images or install graphviz at C:\Program Files\Graphviz. ERRROR: ',newline, char(9), cmdout]);
end
setenv('PATH','C:\Program Files\Inkscape\bin');
[status,cmdout] = system(['inkscape.exe --export-type=pdf ',imageName,'.svg']);
    
if status==1 || contains(cmdout,'denied')
    warning(['Unable to convert svg file to pdf file: close open PDFs or install Inkscape at C:\Program Files\Inkscape. ERRROR: ',newline, char(9), cmdout]);
else
    filePath = [pwd,'\',imageName,'.svg'];
    delete(filePath);
end

% deleting file dotGraph.txt
delete('dotGraph.txt');



end

