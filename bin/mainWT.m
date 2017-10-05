clear
clc
mypath = '../data/selectedCAWT2006';
nIntv = 365 * 24 * 12; % a whole year with 5 min interval
barDensity = 200;
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

% Ramping 5min
rampWT5 = abs(powerWT5(2:end) - powerWT5(1:end-1))/5; % per min
countsWT5 = hist(rampWT5,barDensity);
ratesWT5 = countsWT5/(nIntv-1);

% Ramping 15min
nIntv15 = nIntv/3;
powerWT15 = zeros(nIntv15,1);
for i = 1:nIntv15
    tempIdx = (i*3-2):(i*3);
    powerWT15(i) = mean(powerWT5(tempIdx));
end
rampWT15 = abs(powerWT15(2:end) - powerWT15(1:end-1))/15; % per min
countsWT15 = hist(rampWT15,barDensity);
ratesWT15 = countsWT15/(nIntv15-1);

% Ramping 60min
nIntv60 = nIntv/12;
powerWT60 = zeros(nIntv60,1);
for i = 1:nIntv60
    tempIdx = (i*12-11):(i*12);
    powerWT60(i) = mean(powerWT5(tempIdx));
end
rampWT60 = abs(powerWT60(2:end) - powerWT60(1:end-1))/60; % per min
countsWT60 = hist(rampWT60,barDensity);
ratesWT60 = countsWT60/(nIntv60-1);

figure(1) %'5min WT ramping'
yyaxis left
bar(1:barDensity,ratesWT5);
yyaxis right
plot(1:barDensity,cumsum(ratesWT5));
ylim([0 1])

figure(2) % '15min WT ramping',
yyaxis left
bar(1:barDensity,ratesWT15);
yyaxis right
plot(1:barDensity,cumsum(ratesWT15));
ylim([0 1])

figure(3) %'60min WT ramping',
yyaxis left
bar(1:barDensity,ratesWT60);
yyaxis right
plot(1:barDensity,cumsum(ratesWT60));
ylim([0 1])


