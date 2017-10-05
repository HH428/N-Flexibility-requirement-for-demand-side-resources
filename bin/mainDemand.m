close all
clear
clc
mypath = '../data/allDemandNYC2015.mat';
load(mypath)
nIntv = 365 * 24 * 12; % a whole year with 5 min interval
barDensity = 200;
powerDemand5 = allDemand.load;

% Ramping 5min
rampDemand5 = abs(powerDemand5(2:end) - powerDemand5(1:end-1))/5; % per min

% Ramping 15min
nIntv15 = nIntv/3;
powerDemand15 = zeros(nIntv15,1);
for i = 1:nIntv15
    tempIdx = (i*3-2):(i*3);
    powerDemand15(i) = mean(powerDemand5(tempIdx));
end
rampDemand15 = abs(powerDemand15(2:end) - powerDemand15(1:end-1))/15; % per min


% Ramping 60min
nIntv60 = nIntv/12;
powerDemand60 = zeros(nIntv60,1);
for i = 1:nIntv60
    tempIdx = (i*12-11):(i*12);
    powerDemand60(i) = mean(powerDemand5(tempIdx));
end
rampDemand60 = abs(powerDemand60(2:end) - powerDemand60(1:end-1))/60; % per min

rampMax = max([max(rampDemand5) max(rampDemand15) max(rampDemand60)]);
xbin = linspace(0,rampMax,barDensity); % get the same bin for 5min, 15min, and 60min

[countsDemand5,centersDemand5] = hist(rampDemand5,xbin);
ratesDemand5 = countsDemand5/(nIntv-1);
tempIdx = find(cumsum(ratesDemand5)>0.95,1);
Demand5Ramping = centersDemand5(tempIdx)/max(powerDemand5)

[countsDemand15,centersDemand15] = hist(rampDemand15,xbin);
ratesDemand15 = countsDemand15/(nIntv15-1);
tempIdx = find(cumsum(ratesDemand15)>0.95,1);
Demand15Ramping = centersDemand15(tempIdx)/max(powerDemand15)

[countsDemand60,centersDemand60] = hist(rampDemand60,xbin);
ratesDemand60 = countsDemand60/(nIntv60-1);
tempIdx = find(cumsum(ratesDemand60)>0.95,1);
Demand60Ramping = centersDemand60(tempIdx)/max(powerDemand60)

x = linspace(0,100,barDensity);
figure(1) %'5min Demand ramping'
title('5min Demand Ramping')
yyaxis left
bar(x,ratesDemand5);
xlim([0 100])
ylim([0 1])
xlabel('Ramping/Peak (%)')
ylabel('Probability Density (Logarithmic scale)')
set(gca,'YScale','log','FontSize',16);
yyaxis right
plot(x,cumsum(ratesDemand5));
ylim([0 1])
ylabel('Cumulative Probability')

figure(2) % '15min Demand ramping',
title('15min Demand Ramping')
yyaxis left
bar(x,ratesDemand15);
xlim([0 100])
ylim([0 1])
xlabel('Ramping/Peak (%)')
ylabel('Probability Density (Logarithmic scale)')
set(gca,'YScale','log','FontSize',16);
yyaxis right
plot(x,cumsum(ratesDemand15));
ylim([0 1])
ylabel('Cumulative Probability')

figure(3) %'60min Demand ramping',
title('60min Demand Ramping')
yyaxis left
bar(x,ratesDemand60);
xlim([0 100])
ylim([0 1])
xlabel('Ramping/Peak (%)')
ylabel('Probability Density (Logarithmic scale)')
set(gca,'YScale','log','FontSize',16);
yyaxis right
plot(x,cumsum(ratesDemand60));
ylim([0 1])
ylabel('Cumulative Probability')
