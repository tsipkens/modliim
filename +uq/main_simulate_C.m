
clear;
close all;
clc;
load('+CENIDE\viridis.mat');

generalErrorModel.setup_C;
scale = 1;
J = J.*scale;

nn = 500;
theta = 1; % related to amplification
gamma = sqrt(15); % percentage of max, i.e. ~ 0.1 = 10%
tau = 0.3;%0.12; % percent variation, i.e. ~ 0.1 = 10%
% alpha = 1/2500; % photoelectric and other efficiencies

% theta = 17; % related to amplification
% sigma = 0.0077; % percentage of max, i.e. ~ 0.1 = 10%
% tau = 0.165; % percent variation, i.e. ~ 0.1 = 10%

x0 = [theta,gamma,tau];

[S,S_E,S_std,S_ss] = generalErrorModel.simulate_noise(J.*theta,theta,gamma,tau,nn); % generate neasured signals
% [T,T_E,T_std] = generalErrorModel.simulate_noise2(J.*theta,theta,sigma,tau,5000); % generate neasured signals

[S_poly,S_poly_var] = polyfit(S_E,S_std.^2,2);
S_std_std = sqrt((nn-1).*((nn-1).*moment(S',4)-(nn-3).*moment(S',2))./(nn^3))';

%%

max_plot = theta*max(J);
figure(2);
plot(S_E,S_std.^2,'.');
hold on;
% fplot(@(x) theta.*x+(sigma*max(theta.*J))^2,[0,max(S_E).*1.02],'k-');
% fplot(@(x) polyval(S_poly,x,S_poly_var),[0,max(S_E).*1.02]);
% plot(T_E,T_std.^2,'.');
fplot(@(x) gamma^2+theta.*x+(tau^2).*(x.^2),'-k',[0,max_plot]);
fplot(@(x) gamma^2+theta.*x,'-k',[0,max_plot]);
xlim([0,max_plot]);
ylim([0,300]);%1.02.*(gamma^2+theta.*max_plot+(tau^2).*(max_plot.^2))]);
hold off;

% xlim([0,1]);
% ylim([0,0.04]);

figure(1);
hold on;
plot(t,S(:,46),'.');
plot(t,theta.*J);
plot(t,S_ss(:,46));
hold off;

