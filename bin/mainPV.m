close all
clear
clc
mypath = '../data/selectedCAPV2006';
% mypath = '../data/selectedCAWT2006';
nIntv = 365 * 24 * 12; % a whole year with 5 min interval
barDensity = 100;
powerPV5 = zeros(nIntv,1);
listing = dir(mypath);
nFiles = length(listing);
names = cell(nFiles,1);
for i = 1:nFiles % read file names
    names(i,1) = cellstr(listing(i).name);
end
nameLength = cellfun(@length, names);
names(nameLength < 5) = []; % record file names

nNames = length(names);

for i = 1:nNames % the data is clean and strictly stick with 5 min interval
    temp = readtable([mypath '/' char(names(i))]);
    powerPV5 = powerPV5 + temp{:,2};
end

% Ramping 5min
rampPV5 = abs(powerPV5(2:end) - powerPV5(1:end-1))/5; % per min
countsPV5 = hist(rampPV5,barDensity);
ratesPV5 = countsPV5/(nIntv-1);

% Ramping 15min
nIntv15 = nIntv/3;
powerPV15 = zeros(nIntv15,1);
for i = 1:nIntv15
    tempIdx = (i*3-2):(i*3);
    powerPV15(i) = mean(powerPV5(tempIdx));
end
rampPV15 = abs(powerPV15(2:end) - powerPV15(1:end-1))/15; % per min
countsPV15 = hist(rampPV15,barDensity);
ratesPV15 = countsPV15/(nIntv15-1);

% Ramping 60min
nIntv60 = nIntv/12;
powerPV60 = zeros(nIntv60,1);
for i = 1:nIntv60
    tempIdx = (i*12-11):(i*12);
    powerPV60(i) = mean(powerPV5(tempIdx));
end
rampPV60 = abs(powerPV60(2:end) - powerPV60(1:end-1))/60; % per min
countsPV60 = hist(rampPV60,barDensity);
ratesPV60 = countsPV60/(nIntv60-1);


figure(1) %'5min PV ramping'
yyaxis left
bar(1:barDensity,ratesPV5);
yyaxis right
plot(1:barDensity,cumsum(ratesPV5));
ylim([0 1])

figure(2) % '15min PV ramping',
yyaxis left
bar(1:barDensity,ratesPV15);
yyaxis right
plot(1:barDensity,cumsum(ratesPV15));
ylim([0 1])

figure(3) %'60min PV ramping',
yyaxis left
bar(1:barDensity,ratesPV60);
yyaxis right
plot(1:barDensity,cumsum(ratesPV60));
ylim([0 1])
