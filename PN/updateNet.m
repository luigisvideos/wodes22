function [ Mn ] = updateNet( Ms, PRE,POST, seq )
%UPDATENET Starting from Ms and the PRE & POST matrices it fires the
%seq array that contains a succession of transition IDs. It is supposed
%that t indices start from 1
%   Simple status equation law

% verifications
assert(size(PRE,2)==size(POST,2),'PRE and POST matrices have different columns number');
assert(length(Ms)==size(PRE,1) && length(Ms)==size(POST,1),'PRE and POST matrices have different rows number');
%assert(t>=1 && t<=size(PRE,2),'The transition index is not valid');

Mn=Ms;

% implementation
for k=1:length(seq)
    % test conditions
    assert(isTransitionStateEnabled( Mn, PRE, seq(k) )==1,['The transition t',num2str(seq(k)),' is not firable!']);

    tvec = getFiringCountVector(seq(k),size(PRE,2));

    %net update

    Mn = Mn + (POST-PRE)*tvec;
end

end

