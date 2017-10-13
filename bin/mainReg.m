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

% 30000: 9900: 6200 = Load: Solar: Wind
maxDemand = max(powerDemand5);
maxWT = max(powerWT5);
maxPV = max(powerPV5);

NetDemand5Ramping = [];
NetDemand15Ramping = [];
NetDemand60Ramping = [];
powerNetDemand5 = zeros(nIntv,1);
nIntv15 = nIntv/3;
powerNetDemand15 = zeros(nIntv15,1);
nIntv60 = nIntv/12;
powerNetDemand60 = zeros(nIntv60,1);


maxPercentage = 11;
caseNum = maxPercentage^2;
powerPV5all = [];
powerWT5all = [];

for WTpercent = 0:5:50 %11:maxPercentage + 10
    for PVpercent = 0:5:50 %11:maxPercentage + 10
        scaleWT = maxDemand*WTpercent/100/maxWT;
        scalePV = maxDemand*PVpercent/100/maxPV;
        powerPV5temp = powerPV5 * scalePV;
        powerWT5temp = powerWT5 * scaleWT;
        powerPV5all = [powerPV5all scalePV];
        powerWT5all = [powerWT5all scaleWT];
        
        powerNetDemand5 = powerDemand5 - powerPV5temp - powerWT5temp;
        % Ramping 5min
        rampNetDemand5 = abs(powerNetDemand5(2:end) - powerNetDemand5(1:end-1)); 
        % Ramping 15min

        for i = 1:nIntv15
            tempIdx = (i*3-2):(i*3);
            powerNetDemand15(i) = mean(powerNetDemand5(tempIdx));
        end
        rampNetDemand15 = abs(powerNetDemand15(2:end) - powerNetDemand15(1:end-1)); 

        % Ramping 60min
        for i = 1:nIntv60
            tempIdx = (i*12-11):(i*12);
            powerNetDemand60(i) = mean(powerNetDemand5(tempIdx));
        end
        rampNetDemand60 = abs(powerNetDemand60(2:end) - powerNetDemand60(1:end-1));
             
        powerMax = max(powerNetDemand5);
        xbin = linspace(0,powerMax,barDensity); % get the same bin for 5min, 15min, and 60min

        [countsNetDemand5,centersNetDemand5] = hist(rampNetDemand5,xbin);
        ratesNetDemand5 = countsNetDemand5/(nIntv-1);
        tempIdx = find(cumsum(ratesNetDemand5)>0.95,1);
        NetDemand5Ramping = [NetDemand5Ramping centersNetDemand5(tempIdx)];

        [countsNetDemand15,centersNetDemand15] = hist(rampNetDemand15,xbin);
        ratesNetDemand15 = countsNetDemand15/(nIntv15-1);
        tempIdx = find(cumsum(ratesNetDemand15)>0.95,1);
        NetDemand15Ramping = [NetDemand15Ramping centersNetDemand15(tempIdx)];

        [countsNetDemand60,centersNetDemand60] = hist(rampNetDemand60,xbin);
        ratesNetDemand60 = countsNetDemand60/(nIntv60-1);
        tempIdx = find(cumsum(ratesNetDemand60)>0.95,1);
        NetDemand60Ramping = [NetDemand60Ramping centersNetDemand60(tempIdx)];
    end
end

% X = zeros(3,caseNum);
% X(1,:) = 1; X(1,:) = X(1,:) * maxDemand;
% X(2,:) = powerPV5all; X(2,:) = X(2,:) * maxPV;
% X(3,:) = powerWT5all; X(3,:) = X(3,:) * maxWT;

X = zeros(2,caseNum);
%X(1,:) = 1; X(1,:) = X(1,:) * maxDemand;
X(1,:) = powerPV5all; X(1,:) = X(1,:) * maxPV;
X(2,:) = powerWT5all; X(2,:) = X(2,:) * maxWT;


mdl5 = fitlm(X',NetDemand5Ramping' - 0.006*maxDemand); % change 5,15,60 for different ramping time
figure(1)
plot(NetDemand5Ramping - 0.006*maxDemand,'r')  % change 5,15,60 for different ramping time
hold on
%ypred = predict(mdl,X');
plot(mdl5.Fitted,'b')

mdl15 = fitlm(X',NetDemand15Ramping' - 0.013*maxDemand); % change 5,15,60 for different ramping time
figure(2)
plot(NetDemand15Ramping - 0.013*maxDemand,'r')  % change 5,15,60 for different ramping time
hold on
%ypred = predict(mdl,X');
plot(mdl15.Fitted,'b')

mdl60 = fitlm(X',NetDemand60Ramping' - 0.0501*maxDemand); % change 5,15,60 for different ramping time
figure(3)
plot(NetDemand60Ramping - 0.0501*maxDemand,'r')  % change 5,15,60 for different ramping time
hold on
%ypred = predict(mdl,X');
plot(mdl60.Fitted,'b')

mdl5.Coefficients
mdl15.Coefficients
mdl60.Coefficients

figure(4)
surf(0:5:50,0:5:50,reshape(NetDemand60Ramping' - 0.0501*maxDemand,[11,11]))
hold on
syms x y z
temp = reshape(NetDemand60Ramping' - 0.0501*maxDemand,[11,11])
p1 = [50,0,temp(1,11)];
p2 = [0,50,temp(11,1)];
p3 = [50,50,temp(11,11)];
q = [ones(4,1),[[x y z];p1;p2;p3]]; 
d = det(q);
Z = solve(d,z);
fmesh(Z)




