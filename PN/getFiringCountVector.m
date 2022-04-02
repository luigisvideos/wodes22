function [ out ] = getFiringCountVector( sequence, nt )
%GETFIRINGCOUNTVECTOR Returns the firing count vector of a sequence of
%identifiers of transitions, given the number of transitions in the net
%   Ex: sequence = 1 5 1 3 2 1 and nt=6 -> out = [3 1 1 0 1 0]

out = zeros(nt,1);
for i=1:length(sequence)
    out(sequence(i))=out(sequence(i))+1;   
end

end

