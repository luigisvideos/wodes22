function [W] = computeCombinations(S,maxNumberOfAlternativeCauses)
 
N = numel(S) ;
if N == 0
    % nothing to do
    W = {} ;
    return ;
end

% 
% if numel(X1) ~= 1 || numel(X2) ~= 1 || ~islogical(X1) || ~islogical(X2)
%     error('The criterion function should return a logical scalar.') ;
% end

% The selection of elements is based on the binary representation of all
% numbers X between 1 and M. This binary representation is is retrieved by
% the formula: bitget(X * (2.^(N-1:-1:0)),N) > 0 
% See NCHOOSE (available on the File Exchange) for details

idx0 = 1:N ;

% We pre-allocate the output, but only to a certain extend
W = cell(2^12,1) ;
SetCounter = 0 ; % We'll add the subsets to the list one by one

% loop over all subsets, this can take some time ...
for h=1:maxNumberOfAlternativeCauses
    C = combnk(1:N,h);
    for k=1:size(C,1)
        tf = toLogicalIndexing(C(k,:),N);
        % calculate the (reversed) binary representation of k
        % select the elements of the set based on this representation
        
        res=1;
        if res==1
            % does it fullfill the criterion? 
            SetCounter = SetCounter + 1 ; % go to the next element in W
            W{SetCounter} = idx0(tf) ;
        end
    end
end

% get the subsets
W = cellfun(@(c) S(c), W(1:SetCounter), 'un', 0) ;
end

