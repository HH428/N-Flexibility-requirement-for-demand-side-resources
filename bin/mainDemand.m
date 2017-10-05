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
[countsDemand5,centersDemand5] = hist(rampDemand5,barDensity);
ratesDemand5 = countsDemand5/(nIntv-1);
tempIdx = find(cumsum(ratesDemand5)>0.95,1);
Demand5Ramping = centersDemand5(tempIdx)/max(powerDemand5)

% Ramping 15min
nIntv15 = nIntv/3;
powerDemand15 = zeros(nIntv15,1);
for i = 1:nIntv15
    tempIdx = (i*3-2):(i*3);
    powerDemand15(i) = mean(powerDemand5(tempIdx));
end
rampDemand15 = abs(powerDemand15(2:end) - powerDemand15(1:end-1))/15; % per min
[countsDemand15,centersDemand15] = hist(rampDemand15,barDensity);
ratesDemand15 = countsDemand15/(nIntv15-1);
tempIdx = find(cumsum(ratesDemand15)>0.95,1);
Demand15Ramping = centersDemand15(tempIdx)/max(powerDemand15)

% Ramping 60min
nIntv60 = nIntv/12;
powerDemand60 = zeros(nIntv60,1);
for i = 1:nIntv60
    tempIdx = (i*12-11):(i*12);
    powerDemand60(i) = mean(powerDemand5(tempIdx));
end
rampDemand60 = abs(powerDemand60(2:end) - powerDemand60(1:end-1))/60; % per min
[countsDemand60,centersDemand60] = hist(rampDemand60,barDensity);
ratesDemand60 = countsDemand60/(nIntv60-1);
tempIdx = find(cumsum(ratesDemand60)>0.95,1);
Demand60Ramping = centersDemand60(tempIdx)/max(powerDemand60)


figure(1) %'5min Demand ramping'
title('5min Demand Ramping')
yyaxis left
bar(1:barDensity,ratesDemand5);
ylim([0 1])
ylabel('Probability Density (Logarithmic scale)')
set(gca,'YScale','log');

yyaxis right
plot(1:barDensity,cumsum(ratesDemand5));
ylim([0 1])
ylabel('Cumulative Probability')

figure(2) % '15min Demand ramping',
title('15min Demand Ramping')
yyaxis left
bar(1:barDensity,ratesDemand15);
ylim([0 1])
ylabel('Probability Density (Logarithmic scale)')
set(gca,'YScale','log');

yyaxis right
plot(1:barDensity,cumsum(ratesDemand15));
ylim([0 1])
ylabel('Cumulative Probability')

figure(3) %'60min Demand ramping',
title('60min Demand Ramping')
yyaxis left
bar(1:barDensity,ratesDemand60);
ylim([0 1])
ylabel('Probability Density (Logarithmic scale)')
set(gca,'YScale','log');

yyaxis right
plot(1:barDensity,cumsum(ratesDemand60));
ylim([0 1])
ylabel('Cumulative Probability')
