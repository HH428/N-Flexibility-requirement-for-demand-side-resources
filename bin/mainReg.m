loadAllData;

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
%subplot(1,3,1)
s11 = surf(0:5:50,0:5:50,reshape((NetDemand60Ramping' - 0.0501*maxDemand)/powerMax * 100,[11,11]));
hold on
% surf(0:5:50,0:5:50,reshape(mdl60.Fitted,[11,11]))
% Calculate the upper bond
f = [sum(X(1,:)) sum(X(2,:)) length(X(1,:))];
A = -[X(1,:)' X(2,:)' ones(length(X(1,:)),1)];
b = -(NetDemand60Ramping - 0.0501*maxDemand);
x = linprog(f,A,b)
zPre = (x(1)*X(1,:)' + x(2)*X(2,:)')/powerMax * 100;
s12 = surf(0:5:50,0:5:50,reshape(zPre,[11,11]), 'FaceColor','red','FaceAlpha', 0.5,'EdgeAlpha', 0);
xlabel({'PV penetration (%)'})
ylabel({'Wind penetration (%)'})
zlabel({'60min Netdemand Ramping/ Peak Demand (%)'})
set(gca,'FontSize',16);
legend([s11, s12], {'actual', 'upper bond'});
xlim([0 50])
ylim([0 50])
zlim([0 10])

figure(5)
%subplot(1,3,2)
s21 = surf(0:5:50,0:5:50,reshape((NetDemand15Ramping' - 0.013*maxDemand)/powerMax * 100,[11,11]));
hold on
% Calculate the upper bond
f = [sum(X(1,:)) sum(X(2,:)) length(X(1,:))];
A = -[X(1,:)' X(2,:)' ones(length(X(1,:)),1)];
b = - (NetDemand15Ramping - 0.013*maxDemand);
x = linprog(f,A,b)
zPre = (x(1)*X(1,:)' + x(2)*X(2,:)')/powerMax * 100;
s22 = surf(0:5:50,0:5:50,reshape(zPre,[11,11]), 'FaceColor','red','FaceAlpha', 0.5,'EdgeAlpha', 0);
xlabel({'PV penetration (%)'})
ylabel({'Wind penetration (%)'})
zlabel({'15min Netdemand Ramping/ Peak Demand (%)'})
legend([s21, s22], {'actual', 'upper bond'});
set(gca,'FontSize',16);
xlim([0 50])
ylim([0 50])
zlim([0 10])

figure(6)
%subplot(1,3,3)
s31 = surf(0:5:50,0:5:50,reshape((NetDemand5Ramping' - 0.006*maxDemand)/powerMax * 100,[11,11]));
hold on
% Calculate the upper bond
f = [sum(X(1,:)) sum(X(2,:)) length(X(1,:))];
A = -[X(1,:)' X(2,:)' ones(length(X(1,:)),1)];
b = - (NetDemand5Ramping - 0.006*maxDemand);
x = linprog(f,A,b)
zPre = (x(1)*X(1,:)' + x(2)*X(2,:)')/powerMax * 100;
s32 = surf(0:5:50,0:5:50,reshape(zPre,[11,11]), 'FaceColor','red','FaceAlpha', 0.5,'EdgeAlpha', 0);
xlabel({'PV penetration (%)'})
ylabel({'Wind penetration (%)'})
zlabel({'5min Netdemand Ramping/ Peak Demand (%)'})
legend([s31, s32], {'actual', 'upper bond'});
set(gca,'FontSize',16);
xlim([0 50])
ylim([0 50])
zlim([0 10])