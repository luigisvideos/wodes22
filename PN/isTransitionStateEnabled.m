function [ en ] = isTransitionStateEnabled( Ms, PRE, t )
%ISTRANSITIONENABLED checks if a given transition (by its index>=1) can be fired
%considering only the state of the PN
%   Firable checking. Boolean conditions associated to transitions are
%   ignored

% verifications
assert(length(Ms)==size(PRE,1),'PRE has an incorrect number of rows');
assert(t>=1 && t<=size(PRE,2),'The transition index is not valid');

%implementation
en = all(Ms>=PRE(:,t));

end
