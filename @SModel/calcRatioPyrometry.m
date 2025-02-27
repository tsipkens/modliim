
% CALCRATIOPYROMETRY  Evaluate temperature by two-colour pyrometry.
%  
%  T = SModel.calcRatioPyrometry(J1, J2) evaluates the temperature using
%  ratio pyrometry and the optical properties embedded in SModel.
%  
%  AUTHOR: Timothy Sipkens, 2017

function [To, Co, s_T, out] = calcRatioPyrometry(smodel,J1,J2)

l = smodel.l;  % local copy
if length(l) > 2  % check the number of wavelengths
    error('Too many wavlengths in SModel for two-color pyrometry.');
end

Emr = smodel.prop.Emr(l(1), l(2), smodel.prop.dp0); % ratio of Em at two wavelengths
Jr = J1 ./ J2;  % ratio of incandescences


%-- Basic ratio calculation ----------------------------------------------%
To = (0.0143877696 * (1/(l(2)*1e-9) - 1/(l(1)*1e-9))) ./ ...
    log(Jr .* (((l(1)/l(2))^6) / Emr)); % phi=0.0143...
To = real(To);
    % Note: Imaginary values result from negative values in J matrices
s_T = std(To,[],2);


%-- Calculate scaling constant -------------------------------------------%
Co = bsxfun(@rdivide,J2,...
    (smodel.blackbody(To,l(end)).*smodel.prop.Em(l(end),smodel.prop.dp0)./...
    (l(end)*1e-9.*smodel.data_sc)));
out = [];
out.s_C = std(Co,[],2);


%-- Calculate correlation ------------------------------------------------%
ntime = length(To(:,1));
r_TC = zeros(ntime,1);
for ii=1:ntime
    r_TC(ii) = corr(Co(ii,:)',To(ii,:)');
end
out.r_TC = r_TC;

end

