function [] = C(prop)

% Currently, opts.propmodel = 
%   'Sipkens', 'Michelsen', 'Kock', 'Liu', 'default', 'constant'
% Sensible energy properties **********************************************
prop.phi = prop.h*prop.c/prop.kb;
prop.M = 0.01201;

switch prop.opts.propmodel % Density in kg/m^3
    case {'default','Michelsen'}
        prop.Arho = 1;
        prop.Brho = 1;
        prop.rho = @(T) (prop.Arho.*2.303-prop.Brho.*7.3106e-5.*T).*1000; % Michelsen
    case {'Liu','Sipkens','Liu-MS','Melton-MS'}
        prop.Arho = 1;
        prop.rho = @(T) prop.Arho.*1.9*1000.*ones(size(T));
    case 'Charwath'
        prop.Arho = 1;
        prop.rho = @(T) prop.Arho.*1.91.*1000;
    case {'Kock','constant'} % constant
        prop.Arho = 1;
        prop.rho = @(T) prop.Arho.*1.86.*1000;
    case 'Will'
        prop.Arho = 1;
        prop.rho = @(T) prop.Arho.*1.85.*1000;
    case 'Melton' % original Melton model
        prop.Arho = 1;
        prop.rho = @(T) prop.Arho.*2.26.*1000;
end

switch prop.opts.propmodel % Specific heat in J/(kg K)
    case {'Michelsen'}
        prop.Ccp = 1;
        prop.cp = @(T) prop.Ccp.*(prop.R/0.01201).*(1.115.*(597./T).^2.*exp(597./T).*(exp(597./T)-1).^-2+...
            1.789.*(1739./T).^2.*exp(1739./T).*(exp(1739./T)-1).^-2+T./8260)...
            ; % Michelsen
    case {'Liu','Sipkens','Liu-MS','Melton-MS'}
        Tt = 1200; % Transition temperature, Liu
        prop.Ccp = 1;
        prop.cp = @(T) prop.Ccp.*1000.*prop.iif(T<Tt,...
            -9.7768e-4+(2.7943e-4*T)+(1.4554e-5*T^2)-(3.4432e-8*T^3)+...
                (3.6700e-11*T^4)-(1.9485e-14*T^5)+(4.1802e-18*T^6),...
            2.9497e-1+(2.9614e-3*T)-(2.1232e-6*T^2)+(8.1901e-10*T^3)-...
                (1.7516e-13*T^4)+(1.9628e-17*T^5)-(8.9817e-22*T^6));
    case {'Kock','default'}
        prop.Ccp = 1;
        prop.cp = @(T) prop.Ccp.*1000.*(1.878+1.082e-4.*T-1.5149e5./T.^2);
    case {'constant','Charwath'}
        prop.Ccp = 1;
        prop.cp = @(T) prop.Ccp.*1900;
    case 'Will'
        prop.Ccp = 1;
        prop.cp = @(T) prop.Ccp.*1000.*(2.90041-36.4073./sqrt(T));
    case 'Melton'
        prop.Ccp = 1;
        prop.cp = @(T) prop.Ccp.*1900;
end

% Conduction properties ***************************************************
switch prop.opts.propmodel % Specific heat in J/(kg K)
    case {'Liu','default','constant'}
        prop.alpha = 0.37; % Liu
    case {'Michelsen','Sipkens','Liu-MS','Melton-MS'}
        prop.alpha = 0.3;
    case 'Kock'
        prop.alpha = 0.23;
    case 'Charwath'
        prop.alpha = 0.28;
    case 'Will'
        prop.alpha = 0.275;
    case 'Melton'
        prop.alpha = 0.9;
end

prop.ct = @()sqrt(8*prop.kb*prop.Tg/(pi*prop.mg));

% Evaporation properties **************************************************
switch prop.opts.propmodel % Molar mass in kg/mol
    case {'default'} % simplified model
        prop.Mv = 3*prop.M;
        prop.Rs = prop.R./prop.Mv;
        prop.mv = 3*0.01201.*1.660538782e-24;
        prop.hv = @(T) (8.443e5-26.921.*T)./prop.Mv; % Michelsen, C3 only
        prop.hvb = prop.hv(prop.Tb)/1e6;
        prop.Pref = 101325; % atmospheric boiling point used
        prop.C = log(prop.Pref)+(prop.hvb*1e6)./prop.Rs./prop.Tb; % Constant for C-C Eqn. 
        prop.gamma = @(dp,T) 0.18; % (Shih, 2013)
        prop.pv = @prop.kelvinEqn;
        prop.alpham = @(T) 1;
        
    case {'Kock','constant'} % constant hv, mv
        prop.Mv = prop.M*3;
        prop.Rs = prop.R./prop.Mv;
        prop.mv = prop.Mv.*1.660538782e-24;
        prop.hv = @(T) 7.9078e5.*ones(size(T))./prop.Mv; % Kock
        prop.alpham = @(T) 1;
        
        % Clausius-Clapeyron eqn.
        prop.Pref = 61.5;
        prop.Tb = 3000; % artificial, reference temperature
        prop.hvb = prop.hv(prop.Tb)/1e6;
        prop.C = log(prop.Pref)+(prop.hvb*1e6)./prop.Rs./prop.Tb; % Constant for C-C Eqn. 
        prop.pv = @prop.clausClap;
        
    case {'Liu','Will','Liu-MS'}
        prop.Mv = prop.M*3;
        prop.Rs = prop.R./prop.Mv;
        
        prop.c0 = 17.179;
        prop.c1 = 6.8654e-4;
        prop.c2 = 2.9962e-6;
        prop.c3 = -8.5954e-10;
        prop.c4 = 1.0486e-13;
        prop.mv = @(T) (prop.c0+prop.c1.*T+prop.c2.*T.^2+...
            prop.c3.*T.^3+prop.c4.*T.^4)./1000.*1.660538782e-24;
        
        prop.b0 = 2.05398e5;
        prop.b1 = 7.3660e2;
        prop.b2 = -0.40713;
        prop.b3 = 1.1992e-4;
        prop.b4 = -1.7946e-8;
        prop.b5 = 1.0717e-12;
        prop.hv = @(T) (prop.b0+(prop.b1.*T)+(prop.b2.*T.^2)+...
            (prop.b3.*T.^3)+(prop.b4.*T.^4)+...
            (prop.b5.*T.^5))./(prop.mv(T)./1.660538782e-24);
        prop.hvb = prop.hv(prop.Tb)/1e6; % only included for reference
        
        prop.a0 = -122.96;
        prop.a1 = 9.0558e-2;
        prop.a2 = -2.7637e-5;
        prop.a3 = 4.1754e-9;
        prop.a4 = -2.4875e-13;
        prop.pv = @(T,dp,hv) 101325.*exp(prop.a0+(prop.a1.*T)+(prop.a2.*T.^2)+...
            (prop.a3.*T.^3)+(prop.a4.*T.^4)); % Liu
        if strcmp(prop.opts.propmodel,'Liu')
            prop.alpham = @(T) 0.77;
        else
            prop.alpham = @(T) 1;
        end
        
    case {'Sipkens'}
%         prop.c0 = 1975;
%         prop.c1 = 250;
%         prop.c2 = 0.012;
%         prop.c3 = 4200;
%         prop.c4 = 250;
        prop.c0 = 2025;
        prop.c1 = 375;
        prop.c2 = 0.012;
        prop.c3 = 4225;
        prop.c4 = 175;
        sigmoid_fun = @(T,a,b) 1./(1+exp(-1./b.*(T-a)));
            % a sigmoid function is used to transition
        prop.mv = @(T) (0.012+sigmoid_fun(T,prop.c0,prop.c1).*0.024+...
            sigmoid_fun(T,prop.c3,prop.c4).*prop.c2).*1.660538782e-24;
        
        % Roman equation for hv
        Tref = 5500;%5500; % reference point, Leider, 1973
        Mv = @(T) prop.mv(T)./1.660538782e-24; % correct for J/kg conversion @ 4000K
        hfus = 29.3*3.4838e5*(Mv(Tref)); % heat of fusion, Leider, 1973, 30 given or 29.3 ave kcal/gatom, in MJ/mol
        hvref = 0.34073; % reference point at T = 5500 K, MJ/mol, Leider, 1973
        prop.Tcr = 6810; % Leider, 1973
        prop.n = 0.38; % Watson/Roman
        prop.beta = 0.371;
        % prop.hv = @(T) ((((hvref*1e6).*exp((prop.n-prop.beta).*...
        %     ((T-Tref)./(prop.Tcr-Tref))).*...
        %     (((1-T./prop.Tcr)./(1-Tref/prop.Tcr)).^prop.n)))+...
        %     hfus.*((T)<=4765))./Mv(T).*(T<prop.Tcr); % 4765 K: triple point estimate, Leider, 1973
        
        prop.b0 = 6.9248e5;
        prop.b1 = 43.1429;
        prop.hv = @(T) ((((hvref*1e6).*exp((prop.n-prop.beta).*...
            ((T-Tref)./(prop.Tcr-Tref))).*...
            (((1-T./prop.Tcr)./(1-Tref/prop.Tcr)).^prop.n))).*(T>=4765).*(T<prop.Tcr)+...
            (prop.b0+prop.b1.*T).*((T<4765)&(T>=1000))+...
            7.3563e+05.*(T<1000))./Mv(T); % 4765 K: triple point estimate, Leider, 1973
        prop.alpham = @(T) 1;
        
        % Clausius-Clapeyron equation, Kelvin equation
        prop.Tb = 3000;
        prop.hvb = prop.hv(prop.Tb)*Mv(prop.Tb)/1e6;
        prop.Pref = 101325*6.07e-4;%*1.68;%103.4; % Leider et al., Table 3
        prop.C = log(prop.Pref)+(prop.hvb*1e6)./prop.R./prop.Tb; % Constant for C-C Eqn.
        Tref2 = 4765;
        Pref2 = exp(prop.C-prop.hvb*1e6./prop.R./4765);
        hvb2 = prop.hvb-(29.3*3.4838e+5/1e6)*Mv(Tref2);
        C2 = log(Pref2)+(hvb2*1e6)./prop.R./Tref2; % Constant for C-C Eqn. hv_low
        prop.gamma = @(dp,T) 0.18; % (Shih, 2013)
        pv0 = @(T) exp(prop.C-prop.hvb*1e6./prop.R./T).*(T<=4765)+... % 4765 K: triple point estimate, Leider, 1973
            exp(C2-hvb2*1e6./prop.R./T).*(T>4765);%exp(prop.C-prop.hvb*1e6./prop.Rs./T)*(T>4765); % Clausius-Clapeyron equation
        prop.pv = @(T,dp,hv) pv0(T).*...
            exp((4*prop.gamma(dp,T))./((dp).*prop.rho(T).*prop.R.*T)); % Kelvin equation
        
    case 'Michelsen'
        [prop.hv,prop.pv,prop.mv,prop.alpham] = ...
            prop.vaporMichelsen;
        prop.Tb = 4136.78; % Michelsen, C3 only
        prop.hvb = prop.hv(prop.Tb)/1e6;
        prop.Pref = 101325; % atmospheric boiling point used
        
    case 'Charwath'
        prop.Mv = 3*prop.M;
        prop.mv = prop.Mv.*1.660538782e-24;
        prop.hv = @(T) 7.125e5.*ones(size(T))./prop.Mv;
        prop.alpham = @(T) 0.9;
        prop.pv = @(T,dp,hv) 101325.*exp(-37500./T+9.579); % Antione equation
    
    case {'Melton','Melton-MS'}
        prop.Mv = prop.M*3;
        prop.Rs = prop.R./prop.Mv;
        prop.mv = prop.Mv.*1.660538782e-24;
        prop.b0 = 7.78e5;
        prop.hv = @(T) prop.b0.*ones(size(T))./prop.Mv;
        prop.alpham = @(T) 1;
        
        % Clausius-Clapeyron eqn.
        prop.Pref = 101325;
        prop.Tb = 3915; % artificial, reference temperature
        prop.hvb = prop.hv(prop.Tb)/1e6;
        prop.C = @()log(prop.Pref)+(prop.hvb*1e6)./prop.Rs./prop.Tb; % Constant for C-C Eqn. 
        prop.pv = @(T,dp,hv) exp(prop.C()-prop.hvb*1e6./prop.Rs./T);
end

% Optical properties ******************************************************
switch prop.opts.propmodel
    case 'Michelsen'
        prop.Em = @(l,dp) 0.34.*ones(1,length(l)); % Michelsen
        prop.CEmr = 1;
        prop.Emr = @(l1,l2,dp) prop.CEmr;
        prop.Eml = @(dp) 0.34;
    case 'Kock'
        prop.Em = @(l,dp) 0.23.*ones(1,length(l)); % Michelsen
        prop.CEmr = 1;
        prop.Emr = @(l1,l2,dp) prop.CEmr;
        prop.Eml = @(dp) 0.23;
    case 'Charwath'
        prop.Em = @(l,dp) 0.179.*ones(1,length(l)); % Michelsen
        prop.CEmr = 1;
        prop.Emr = @(l1,l2,dp) prop.CEmr;
        prop.Eml = @(dp) 0.179;
    case {'Liu','Sipkens','Liu-MS','Melton-MS'}
        prop.Em = @(l,dp) 0.38.*ones(1,length(l)); % Liu, constant
        prop.CEmr = 1;
        prop.Emr = @(l1,l2,dp) prop.CEmr;
        prop.Eml = @(dp) 0.38;
    case {'constant','default'}
        prop.Em = @(l,dp) 0.4.*ones(1,length(l)); % Liu, constant
        prop.CEmr = 1;
        prop.Emr = @(l1,l2,dp) prop.CEmr;
        prop.Eml = @(dp) 0.4;
    case 'Will'
        prop.Em = @(l,dp) 0.26.*ones(1,length(l)); % Liu, constant
        prop.CEmr = 1;
        prop.Emr = @(l1,l2,dp) prop.CEmr;
        prop.Eml = @(dp) 0.26;
    case 'Melton'
        prop.Em = @(l,dp) 0.18.*ones(1,length(l)); % Liu, constant
        prop.CEmr = 1;
        prop.Emr = @(l1,l2,dp) prop.CEmr;
        prop.Eml = @(dp) 0.18;
end

end

