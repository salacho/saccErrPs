function thesis_AgrestiCoullInterval
%
%
%
%
%
%
%

ratioIpsiCont

X = ratioIpsiCont;
alpha = 0.05;
z = 1 - 0.5*alpha;
z = 1.96
n = 10;

n_hat = n + z^2;
p_hat = (1/n_hat)*(X + 0.5*(z^2));

CI_low = p_hat - z*sqrt((1/n_hat)*p_hat*(1-p_hat));
CI_high = p_hat + z*sqrt((1/n_hat)*p_hat*(1-p_hat));

[CI_low CI_high]

end