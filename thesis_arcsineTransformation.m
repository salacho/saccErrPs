function thesis_arcsineTransformation
%
%
%
%
%
% Need to have p different from 0 and 1

alpha = 0.05;
X = 5;      % number o successes in n trials
n = 10;     % number of trials
p = X/n;
z = 1 - 0.5*alpha;

varP = (p*(1-p))/n;
varArcSinSqrtP = 1/(4*n);

z2n = z/(2*sqrt(n));




end