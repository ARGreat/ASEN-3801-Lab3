%Question 3.3%
% Date: 10/7/2025
%Authors: Alexander  Godbout, 
%Inputs (Base Toques)

close; clc; close all;

% Run on singular data set

data = readmatrix("./ASENLAB3_DAY1/2025_09_23_001_BASE_T8t5");

time = (data(:,1))/1000; time(2) = .01; %sec
Command_T = data(:,2)/1000; %Nm
Angular_Vel = data(:,3)*2*pi; %rad/s
Current = data(:,4); %Amp
Actual_T = Current * 33.5; %  33.5 is Torque Constant from data sheet 

%Calculate Angular Acceleration
Angular_Acc = diff(Angular_Vel)./diff(time);
mean_Torque = (Actual_T(2:end)+Actual_T(1:(end-1)))/2;

%Calculate Moment of Inertia
MOI = mean_Torque/Angular_Acc;

figure('Theme',"light");
hold on;

subplot(3,1,1);
plot(time,Actual_T);
ylabel("Command Torque (mNm)");

subplot(3,1,2);
plot(time,Angular_Vel);
ylabel("Angular Velocity");

subplot(3,1,3);
plot(time(2:end),Angular_Acc);
ylabel("Angular Acceleration rad/s^2");
hold off;

figure
plot(time(2:end),MOI)


%Run In Loops

filenames = ("2025_09_23_001_BASE_T2t5", ...
    "2025_09_23_001_BASE_T4t5", ...
    "2025_09_23_001_BASE_T6t5", ...
    "2025_09_23_001_BASE_T8t5", ...
    "2025_09_23_001_BASE_T10t5");