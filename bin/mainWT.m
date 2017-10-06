clear
clc
mypath = '../data/selectedCAWT2006';
nIntv = 365 * 24 * 12; % a whole year with 5 min interval
barDensity = 1000;
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

% Ramping 5min, 15min, 60min
rampWT5 = abs(powerWT5(2:end) - powerWT5(1:end-1));

nIntv15 = nIntv/3;
powerWT15 = zeros(nIntv15,1);
for i = 1:nIntv15
    tempIdx = (i*3-2):(i*3);
    powerWT15(i) = mean(powerWT5(tempIdx));
end
rampWT15 = abs(powerWT15(2:end) - powerWT15(1:end-1)); 

nIntv60 = nIntv/12;
powerWT60 = zeros(nIntv60,1);
for i = 1:nIntv60
    tempIdx = (i*12-11):(i*12);
    powerWT60(i) = mean(powerWT5(tempIdx));
end
rampWT60 = abs(powerWT60(2:end) - powerWT60(1:end-1)); 

powerMax = max(powerWT5);
xbin = linspace(0,powerMax,barDensity); % get the same bin for 5min, 15min, and 60min

%Ramping 5min
[countsWT5,centersWT5] = hist(rampWT5,xbin);
ratesWT5 = countsWT5/(nIntv-1);
tempIdx = find(cumsum(ratesWT5)>0.95,1);
WT5Ramping = centersWT5(tempIdx)/powerMax

% Ramping 15min
[countsWT15,centersWT15] = hist(rampWT15,xbin);
ratesWT15 = countsWT15/(nIntv15-1);
tempIdx = find(cumsum(ratesWT15)>0.95,1);
WT15Ramping = centersWT15(tempIdx)/powerMax

% Ramping 60min
[countsWT60,centersWT60] = hist(rampWT60,xbin);
ratesWT60 = countsWT60/(nIntv60-1);
tempIdx = find(cumsum(ratesWT60)>0.95,1);
WT60Ramping = centersWT60(tempIdx)/powerMax

x = linspace(0,100,barDensity);
% figure(1) %'5min WT ramping'
subplot(1,3,1)
title('5min Wind Ramping')
yyaxis left
bar(x,ratesWT5);
xlim([0 50])
ylim([0 1])
xlabel('Ramping/Capacity Ratio (%)')
ylabel('Probability Density (Logarithmic scale)')
set(gca,'YScale','log','FontSize',16);
yyaxis right
plot(x,cumsum(ratesWT5));
ylabel('Cumulative Probability')
ylim([0 1])

%figure(2) % '15min WT ramping',
subplot(1,3,2)
title('15min Wind Ramping')
yyaxis left
bar(x,ratesWT15);
xlim([0 50])
ylim([0 1])
xlabel('Ramping/Capacity Ratio (%)')
ylabel('Probability Density (Logarithmic scale)')
set(gca,'YScale','log','FontSize',16);
yyaxis right
plot(x,cumsum(ratesWT15));
ylim([0 1])
ylabel('Cumulative Probability')

%figure(3) %'60min WT ramping',
subplot(1,3,3)
title('60min Wind Ramping')
yyaxis left
bar(x,ratesWT60);
xlim([0 50])
ylim([0 1])
xlabel('Ramping/Capacity Ratio (%)')
ylabel('Probability Density (Logarithmic scale)')
set(gca,'YScale','log','FontSize',16);
yyaxis right
plot(x,cumsum(ratesWT60));
ylim([0 1])
ylabel('Cumulative Probability')
