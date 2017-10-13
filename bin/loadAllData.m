close all
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
