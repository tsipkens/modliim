function [hv, pv, mv, alpham] = vaporMichelsen()

% Reference temperatures for various species
Tref_C1 = 4603.48;
Tref_C2 = 4456.59;
Tref_C3 = 4136.78;
Tref_C4 = 4949.74;
Tref_C5 = 4772.87;

% Latent heats for different species
hv_C1 = @(T) 7.266e5-5.111.*T;
hv_C2 = @(T) 8.545e5-12.326.*T;
hv_C3 = @(T) 8.443e5-26.921.*T;
hv_C4 = @(T) 9.811e5-7.787.*T-2.114e-3.*T.^2;
hv_C5 = @(T) 9.898e5-7.069.*T-2.598e-3.*T.^2;

% Clausius-Clapyeron for partial pressures of each species
pv_C1 = @(T) 101325.*exp(hv_C1(Tref_C1)./8.3145.*...
    (1./Tref_C1-1./T));
pv_C2 = @(T) 101325.*exp(hv_C2(Tref_C2)./8.3145.*...
    (1./Tref_C2-1./T));
pv_C3 = @(T) 101325.*exp(hv_C3(Tref_C3)./8.3145.*...
    (1./Tref_C3-1./T));
pv_C4 = @(T) 101325.*exp(hv_C4(Tref_C4)./8.3145.*...
    (1./Tref_C4-1./T));
pv_C5 = @(T) 101325.*exp(hv_C5(Tref_C5)./8.3145.*...
    (1./Tref_C5-1./T));

% Fraction of total pressure for each species
pv_C1_frac = @(T) pv_C1(T)./(pv_C1(T)+pv_C2(T)+...
    pv_C3(T)+pv_C4(T)+pv_C5(T));
pv_C2_frac = @(T) pv_C2(T)./(pv_C1(T)+pv_C2(T)+...
    pv_C3(T)+pv_C4(T)+pv_C5(T));
pv_C3_frac = @(T) pv_C3(T)./(pv_C1(T)+pv_C2(T)+...
    pv_C3(T)+pv_C4(T)+pv_C5(T));
pv_C4_frac = @(T) pv_C4(T)./(pv_C1(T)+pv_C2(T)+...
    pv_C3(T)+pv_C4(T)+pv_C5(T));
pv_C5_frac = @(T) pv_C5(T)./(pv_C1(T)+pv_C2(T)+...
    pv_C3(T)+pv_C4(T)+pv_C5(T));

% MAIN OUTPUTS:
% Total pressure, molar mass of gas, and latent heat
pv = @(T,dp,hv) pv_C1(T)+...
    pv_C2(T)+pv_C3(T)+...
    pv_C4(T)+pv_C5(T);
Mv = @(T) (pv_C1_frac(T).*(12.01)+...
    pv_C2_frac(T).*(2.*12.01)+...
    pv_C3_frac(T).*(3.*12.01)+...
    pv_C4_frac(T).*(4.*12.01)+...
    pv_C5_frac(T).*(5.*12.01))./1000;
mv = @(T) Mv(T).*1.660538782e-24;
hv = @(T) (pv_C1_frac(T).*hv_C1(T)+...
    pv_C2_frac(T).*hv_C2(T)+...
    pv_C3_frac(T).*hv_C5(T)+...
    pv_C4_frac(T).*hv_C4(T)+...
    pv_C5_frac(T).*hv_C5(T))./Mv(T);
alpham = @(T) (0.5.*pv_C1(T).*hv_C1(T)./((12.01)./1000).^0.5+...
    0.5.*pv_C2(T).*hv_C2(T)./((2.*12.01)./1000).^0.5+...
    0.1.*pv_C3(T).*hv_C3(T)./((3.*12.01)./1000).^0.5+...
    1e-4.*pv_C4(T).*hv_C4(T)./((4.*12.01)./1000).^0.5+...
    1e-4.*pv_C5(T).*hv_C5(T)./((5.*12.01)./1000).^0.5...
    )./(pv(T).*Mv(T).^0.5.*hv(T));
    % effective value by taking ratio of total values to sum of specific values

% Fraction of total pressure for each species
mv_C1_frac = @(T) pv_C1_frac(T).*12.01./Mv(T);
mv_C2_frac = @(T) pv_C2_frac(T).*2.*12.01./Mv(T);
mv_C3_frac = @(T) pv_C3_frac(T).*3.*12.01./Mv(T);
mv_C4_frac = @(T) pv_C4_frac(T).*4.*12.01./Mv(T);
mv_C5_frac = @(T) pv_C5_frac(T).*5.*12.01./Mv(T);

end

