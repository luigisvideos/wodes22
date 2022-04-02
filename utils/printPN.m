function [status,cmdout]= printPN( net, printEnabledTransitions, imageName, hidePreviousToFirst,infos)

printInfo = exist('infos','var');
if(printInfo)
    assert(length(infos)==size(net.PRE)-net.nPOb,'Infos must be a cell-array containing for each unobservable place a string describing it');
end

hidePreviousToFirstAux = exist('hidePreviousToFirst','var') && hidePreviousToFirst;
newPlacesID = [];
    
Ms=net.Ms;
PRE=net.PRE;
POST=net.POST;
nPOb=net.nPOb;
silentTransitions=net.silentTransitions;

fontsize=13;
newline=char(13);

toDeleteRows = [];
for i=1:size(PRE,1)
    if(isequal(PRE(i,:),zeros(1,size(PRE(1,:),2))) && isequal(POST(i,:),zeros(1,size(POST(1,:),2))))
        toDeleteRows=union(toDeleteRows,i);
    end
end
Ms(toDeleteRows) = []; PRE(toDeleteRows,:)=[]; POST(toDeleteRows,:)=[];


function string = getPString(index)
    if (index<=nPOb)
        string = ['"p',num2str(index),'"'];
    else
        string = ['"p',num2str(index),'"'];
    end
end

function string = getTString(index)
    string = ['"t',num2str(index),'"'];
end

dotCode=['digraph G{ rankdir=LR',newline]; 

% ob places code
dotCode=[dotCode,'subgraph cluster_obPlaces{',newline...
    'style=filled; color=white; ',newline...
    'node [shape=circle, fixedsize=true, width=0.5];',newline,'forcelabels=true',newline];

for i=1:nPOb
       dotCode=[dotCode,...
           getPString(i),' [label="',num2str(Ms(i)),'", xlabel=',getPString(i),'fontsize=',num2str(fontsize)];
    dotCode=[dotCode,'];',newline];
end
dotCode=[dotCode,'}',newline];

% unob places code
dotCode=[dotCode,'subgraph cluster_unobPlaces{',newline...
    'style=filled; color=white; ',newline...
    'node [shape=circle, fixedsize=true, width=0.5];',newline,'forcelabels=true',newline];

for i=nPOb+1:length(Ms)
    dotCode=[dotCode,...
    getPString(i),' [label="',num2str(Ms(i)),'", xlabel=',getPString(i),'fontsize=',num2str(fontsize)];

    color='black';
    if(not(isempty(find(newPlacesID==i,1))))
        color = 'red';
    end
    dotCode=[dotCode,...
       ', style="filled, dashed" color=',color,' fillcolor=white, penwidth=2'];
   if(hidePreviousToFirstAux && i>newPlacesID(1))
        dotCode=[dotCode,' style=invis'];
   end
    dotCode=[dotCode,'];',newline];
end    
dotCode=[dotCode,'}',newline];
% transitions code
dotCode=[dotCode,'subgraph transitions {',newline,...
    'node [shape=rect, height=0.1, width=1];',newline];
enabledTransitions =[];
if(printEnabledTransitions)
    if(hidePreviousToFirstAux)
        enabledTransitions = getStateEnabledTransitions(Ms(1:newPlacesID(1)),PRE(1:newPlacesID(1),:)); 
    else
        enabledTransitions = getStateEnabledTransitions(Ms,PRE); 
    end
end
for i=1:size(PRE,2)
    dotCode=[dotCode,...
        getTString(i),'[fontsize=',num2str(fontsize),' penwidth=2 color="'];
    if(not(isempty(find(enabledTransitions==i,1))))
        dotCode=[dotCode,'red'];
    else
        dotCode=[dotCode,'black'];
    end
    dotCode=[dotCode,'" '];
    if (ismember(i,silentTransitions))
        dotCode=[dotCode,'color="gray"'];
    end
    dotCode=[dotCode,'];',newline];
end
dotCode=[dotCode,'}',newline];
% edges code
c=1;
while(c<=2)
for t=1:size(PRE,2)
    for p=1:size(PRE,1)
        if(POST(p,t)>0 && c==1)
            
            dotCode=[dotCode,getTString(t),'->',getPString(p),'[minlen=2]'];
            if(POST(p,t)>1)
                dotCode=[dotCode,' [label= ',num2str(POST(p,t)),']'];
            end
            if(hidePreviousToFirstAux && p>newPlacesID(1))
                 dotCode=[dotCode,' [style=invis]'];
            end
            dotCode=[dotCode,';',newline];
        end
        if(PRE(p,t)>0 && c==2)
            dotCode=[dotCode,getPString(p),'->',getTString(t),'[minlen=2]'];
            
            if(PRE(p,t)>1)
                dotCode=[dotCode,' [label= ',num2str(PRE(p,t)),']'];
            end
            if(hidePreviousToFirstAux && p>newPlacesID(1))
                 dotCode=[dotCode,' [style=invis]'];
            end
            dotCode=[dotCode,';',newline];
        end
    end
end
c=c+1;
end
% printing infos
if(printInfo && size(PRE,1)>nPOb && not(isempty(infos)))
    dotCode=[dotCode,'rankdir=LR',newline,...
        'node [shape=plaintext]',newline...
        'subgraph cluster_infos {',newline...
        'label = infos',newline...
        'key [label=<<table border="0" cellpadding="2" cellspacing="0" cellborder="0">',newline];

    for i=nPOb+1:size(PRE,1)
       dotCode=[dotCode,'<tr><td><font color="'];

        if(not(isempty(find(newPlacesID>=i,1))))
            dotCode=[dotCode,'black'];
        else
            dotCode=[dotCode,'gray'];
        end

       dotCode=[dotCode,'">p',num2str(i),' ',infos{i-nPOb},'.</font></td></tr>',newline];
    end
    dotCode=[dotCode,'</table>>]}',newline];
end
% ending graph
dotCode=[dotCode,newline,'}',newline];



%saving code to file
fileID = fopen('dotNet.txt','w');
fprintf(fileID,'%s',dotCode);
fclose(fileID);


%executing dot
setenv('PATH','C:\graphviz\bin');
[status,cmdout] = system(['dot -Tpng -Gdpi=250 dotNet.txt > ',imageName,'.png']);
filePath = [pwd,'\',imageName,'.png'];
im=imread(filePath);
imwrite(im,[pwd,'\',imageName,'.jpg']);

end

