function [IDpaths,transitionPaths,ASO] = getAllPathsFromNodeSimple(startNodeID,tree, goBackwards, skipCycles)
   [IDpaths,transitionPaths,ASO] = getAllPathsFromNode(startNodeID,tree, goBackwards, skipCycles, @()([]), @(x)(deal(true,x)),  @(x)(x),@(x)(deal(true,x)), @(x,y,z)(deal(x,y,z)),@(x)(deal(true,x)), @(x,y,z,f)(x), @(x)(false));
end