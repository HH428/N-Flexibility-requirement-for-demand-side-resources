clear
clc

mypath = '../data/selectedCAWT2006';
nIntv = 365 * 24 * 12; % a whole year with 5 min interval
barDensity = 1000;


%% Load Wind data
nIntv10 = nIntv / 2; % a whole year with 10 min interval
powerWT5 = zeros(nIntv,1);
powerWT10 = zeros(nIntv10,1);
listing = dir(mypath);
nFiles = length(listing);
names = cell(nFiles,1);

for i = 1:nFiles % read file names
    names(i,1) = cellstr(listing(i).name);
end
nameLength = cellfun(@length, names);
names(nameLength < 5) = []; % record file names
nNames = length(names);

for i = 1:nNames % the data is clean and strictly stick with 10 min interval
    temp = readtable([mypath '/' char(names(i))]); % power records in the 6th col
    powerWT10 = powerWT10 + temp{:,6};
end

powerWT5(1) =  powerWT10(1);
for i = 1:(nIntv10 - 1) % the convert 10min to 5 min using interpolation
    powerWT5(i*2) = (powerWT10(i) + powerWT10(i+1))/2;
    powerWT5(i*2 + 1) =  powerWT10(i+1);
end
powerWT5(end) = powerWT10(end);

%% Load PV data
mypath = '../data/selectedCAPV2006';
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

%% Load Demand data
mypath = '../data/allDemandNYC2015.mat';
load(mypath)
powerDemand5 = allDemand.load;


% 30000: 9900: 6200 = Load: Solar: Wind
maxDemand = max(powerDemand5);
maxWT = max(powerWT5);
maxPV = max(powerPV5);

scaleWT = maxDemand*6200/30000/maxWT;
scalePV = maxDemand*9900/30000/maxPV;

powerPV5 = powerPV5 * scalePV;
powerWT5 = powerWT5 * scaleWT;
powerNetDemand5 = powerDemand5 - powerPV5 - powerWT5;


% Ramping 5min
rampNetDemand5 = abs(powerNetDemand5(2:end) - powerNetDemand5(1:end-1)); % per min

% Ramping 15min
nIntv15 = nIntv/3;
powerNetDemand15 = zeros(nIntv15,1);
for i = 1:nIntv15
    tempIdx = (i*3-2):(i*3);
    powerNetDemand15(i) = mean(powerNetDemand5(tempIdx));
end
rampNetDemand15 = abs(powerNetDemand15(2:end) - powerNetDemand15(1:end-1)); % per min


% Ramping 60min
nIntv60 = nIntv/12;
powerNetDemand60 = zeros(nIntv60,1);
for i = 1:nIntv60
    tempIdx = (i*12-11):(i*12);
    powerNetDemand60(i) = mean(powerNetDemand5(tempIdx));
end
rampNetDemand60 = abs(powerNetDemand60(2:end) - powerNetDemand60(1:end-1)); % per min

powerMax = max(powerNetDemand5);
xbin = linspace(0,powerMax,barDensity); % get the same bin for 5min, 15min, and 60min

[countsNetDemand5,centersNetDemand5] = hist(rampNetDemand5,xbin);
ratesNetDemand5 = countsNetDemand5/(nIntv-1);
tempIdx = find(cumsum(ratesNetDemand5)>0.95,1);
NetDemand5Ramping = centersNetDemand5(tempIdx)/powerMax

[countsNetDemand15,centersNetDemand15] = hist(rampNetDemand15,xbin);
ratesNetDemand15 = countsNetDemand15/(nIntv15-1);
tempIdx = find(cumsum(ratesNetDemand15)>0.95,1);
NetDemand15Ramping = centersNetDemand15(tempIdx)/powerMax

[countsNetDemand60,centersNetDemand60] = hist(rampNetDemand60,xbin);
ratesNetDemand60 = countsNetDemand60/(nIntv60-1);
tempIdx = find(cumsum(ratesNetDemand60)>0.95,1);
NetDemand60Ramping = centersNetDemand60(tempIdx)/powerMax

x = linspace(0,100,barDensity);
%figure(1) %'5min NetDemand ramping'
subplot(1,3,1)
title('5min NetDemand Ramping')
yyaxis left
bar(x,ratesNetDemand5);
xlim([0 50])
ylim([0 1])
xlabel('Ramping/Peak (%)')
ylabel('Probability Density (Logarithmic scale)')
set(gca,'YScale','log','FontSize',16);
yyaxis right
plot(x,cumsum(ratesNetDemand5));
ylim([0 1])
ylabel('Cumulative Probability')

%figure(2) % '15min NetDemand ramping',
subplot(1,3,2)
title('15min NetDemand Ramping')
yyaxis left
bar(x,ratesNetDemand15);
xlim([0 50])
ylim([0 1])
xlabel('Ramping/Peak (%)')
ylabel('Probability Density (Logarithmic scale)')
set(gca,'YScale','log','FontSize',16);
yyaxis right
plot(x,cumsum(ratesNetDemand15));
ylim([0 1])
ylabel('Cumulative Probability')

%figure(3) %'60min NetDemand ramping',
subplot(1,3,3)
title('60min NetDemand Ramping')
yyaxis left
bar(x,ratesNetDemand60);
xlim([0 50])
ylim([0 1])
xlabel('Ramping/Peak (%)')
ylabel('Probability Density (Logarithmic scale)')
set(gca,'YScale','log','FontSize',16);
yyaxis right
plot(x,cumsum(ratesNetDemand60));
ylim([0 1])
ylabel('Cumulative Probability')
