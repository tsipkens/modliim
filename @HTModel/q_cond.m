
% Q_COND Rate of free-molecular conduction energy loss from the nanoparticle.
% AUTHOR: Timothy Sipkens, 2018-12-17
% 
% INPUTS:
%   T       Vector of nanoparticle temperature, [K]
%   dp      Nanoparticle diameter, [nm]
%
% OUTPUTS:
%   q       Rate of conductive losses, [W]
%=========================================================================%

function [q] = q_cond(htmodel,T,dp)

dp = dp .* 1e-9; % convert to meters so everything is in SI units
prop = htmodel.prop;
prop.alpha = min(max(prop.alpha, 0), 1); % added to force constraints
q = ((prop.alpha * prop.Pg * prop.ct(prop) * pi .* ...
    (dp .^ 2) ./ (8 * prop.Tg)) .* ...
    prop.gamma2(T) .* (T - prop.Tg));

end

