function [ node ] = createNodeByID( ID, label,nodeInfos)

node = struct('win',[],'winID', ID,'in',containers.Map( 'KeyType','char', 'ValueType','any'),'out',containers.Map( 'KeyType','char', 'ValueType','any'),'inTransitions',[],'outTransitions',[],'label',label,...
    'outTransitionsInfos',containers.Map( 'KeyType','double', 'ValueType','any'));

if(exist('nodeInfos','var'))
    node.nodeInfos = nodeInfos;
else
    node.nodeInfos = createEmptyInfos(); 
end
end