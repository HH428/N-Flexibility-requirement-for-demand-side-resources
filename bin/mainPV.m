clear
clc
mypath = '../data/selectedCAPV2006';
% mypath = '../data/selectedCAWT2006';
nIntv = 365 * 24 * 12; % a whole year with 5 min interval 
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

rampPV5 = abs(powerPV5(2:end) - powerPV5(1:end-1))/5; % per min
counts5 = hist(rampPV5,barDensity);
rates5 = counts5/(nIntv-1);
