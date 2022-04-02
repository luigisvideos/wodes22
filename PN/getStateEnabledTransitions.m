function [ set ] = getStateEnabledTransitions( Ms , PRE , ignoreSet)
%GETSTATEENABLEDTRANSITIONS returns the set of state-enabled transition
%from Ms marking
%   boolean conditions are not considered

% verifications
assert(length(Ms)==size(PRE,1),'PRE and Ms matrices have different rows number');

if not(exist('ignoreSet','var'))
    ignoreSet=[];
end
%implementation
set = 1:size(PRE,2);
for t=1:size(PRE,2)
    if not(isempty(find(ignoreSet==t, 1))) || not(isTransitionStateEnabled(Ms, PRE, t))
        set(set==t) = [];
    end
end

end

