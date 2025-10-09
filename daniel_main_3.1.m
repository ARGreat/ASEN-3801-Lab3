%% Housekeeping 

% Clear workspace, close figures, and reset command window
clc; clear; close all;

%% Section 3.1: Gyro Calibration Analysis

% This script analyzes and calibrates gyro output data from multiple test runs.
% It compares measured gyro rates with true encoder rates, applies linear 
% calibration (bias and scale factor), evaluates performance, and integrates 
% rates to estimate angular position.

%% Data input

% Each dataset corresponds to a different test run at various amplitudes and frequencies.
% The raw text files contain time (s), gyro output (rad/s), and input rate (rpm).

data_RW = readmatrix("2025_09_23_001_A05F025.txt");       % Load dataset
time_1 = data_RW(2:end, 1) - 2495.620;                    % Adjust time to start at zero
Gyro_Output = data_RW(2:end, 2);                          % Gyro output data
Rate_Input = data_RW(2:end, 3) * 0.10472;                 % Convert input rate from rpm to rad/s

data_RW_2 = readmatrix("2025_09_23_001_A03_F075.txt");   
time_2 = data_RW_2(2:end, 1) - 2622.450;                 
Gyro_Output2 = data_RW_2(2:end, 2);                      
Rate_Input2 = data_RW_2(2:end, 3) * 0.10472;            

data_RW_3 = readmatrix("2025_09_23_001_A025F05.txt");    
time_3 = data_RW_3(2:end, 1) - 2187.220;
Gyro_Output3 = data_RW_3(2:end, 2);
Rate_Input3 = data_RW_3(2:end, 3) * 0.10472;

data_RW_4 = readmatrix("2025_09_23_001_A1_F025.txt");
time_4 = data_RW_4(2:end, 1) - 2748.390;
Gyro_Output4 = data_RW_4(2:end, 2);
Rate_Input4 = data_RW_4(2:end, 3) * 0.10472;

%% Part 1: Raw Gyro vs Input Rate

% Compare uncalibrated gyro output to true input rate for a sample run.

figure;
% Plot raw gyro output over time
plot(time_1, Gyro_Output)               
hold on;
% Plot true input rate over time
plot(time_1, Rate_Input)               
xlabel('Time History (s)')             
ylabel('Rate Measurement (rad/s)')     
legend('Gyro Output', 'Rate Input');    
title('Gyro Output and Rate Input Over Time') 
grid on;                                

%% Part 2: Calibration via Linear Fit

% Use linear regression (polyfit) to find bias and scale factor.
% Apply correction and visualize before/after calibration.

% Linear fit: y = scale*input + bias
p = polyfit(Rate_Input, Gyro_Output, 1);   
scale_factor = p(1);                        % Extract scale factor
bias = p(2);                                % Extract bias

% Apply calibration
Corrected_Output = (Gyro_Output - bias) / scale_factor; 

% Fit line for visual comparison
x_fit = linspace(min(Rate_Input), max(Rate_Input), 100); % Points along x for line
y_fit = polyval(p, x_fit);                               % Compute corresponding y

figure;
subplot(2,1,1)
% Scatter raw data
scatter(Rate_Input, Gyro_Output, 2.5, 'filled') 
hold on;
% Plot fitted line
plot(x_fit, y_fit, 'r', 'LineWidth', 1)                           
xlabel('Input Rate (rad/s)')
ylabel('Gyro Output (rad/s)')
legend('Data', 'Line of Best Fit')
title('Gyro Calibration Fit')
grid on;

subplot(2,1,2)
% Plot calibrated output over time
plot(time_1, Corrected_Output)                    
hold on;
% Compare to true input rate
plot(time_1, Rate_Input)                          
xlabel('Time (s)')
ylabel('Angular Rate (rad/s)')
legend('Corrected Output', 'True Input')
title('Corrected Gyro Output vs True Input')
grid on;

%% Part 3: Statistical Evaluation

% Repeat calibration for all datasets and compute overall statistics.

p = polyfit(Rate_Input2, Gyro_Output2, 1);
scale_factor2 = p(1); bias2 = p(2);

p = polyfit(Rate_Input3, Gyro_Output3, 1);
scale_factor3 = p(1); bias3 = p(2);

p = polyfit(Rate_Input4, Gyro_Output4, 1);
scale_factor4 = p(1); bias4 = p(2);

% All scale factors
% All biases
scale_factor_vec = [scale_factor, scale_factor2, scale_factor3, scale_factor4]; 
bias_vec = [bias, bias2, bias3, bias4];                                          

% Average scale factor
mean_s = mean(scale_factor_vec); 
% Standard deviation of scale factor
std_s = std(scale_factor_vec); 
% Average bias
mean_b = mean(bias_vec);   
% Standard deviation of bias
std_b = std(bias_vec);           

% Display the results 
fprintf('Mean Scale Factor: %.4f, Standard Deviation: %.4f\n', mean_s, std_s); 
fprintf('Mean Bias: %.4f, Standard Deviation: %.4f\n', mean_b, std_b);

%% Part 4: Validation and Error Analysis 

% Apply calibration to remaining datasets.
% Compare corrected outputs, compute integration to estimate angular position,
% and visualize error between measured and true values.

Corrected_Output2 = (Gyro_Output2 - bias2) / scale_factor2;
Corrected_Output3 = (Gyro_Output3 - bias3) / scale_factor3;
Corrected_Output4 = (Gyro_Output4 - bias4) / scale_factor4;

% Calibrated vs True Angular Rate
figure;
subplot(2,1,1)
% Calibrated angular rate (run 3)
plot(time_3, Corrected_Output3) 
hold on;
% True angular rate (run 3)
plot(time_3, Rate_Input3)       
xlabel('Time (s)')
ylabel('Angular Rate (rad/s)')
legend('Calibrated Output', 'True Input');
title('Calibrated vs True Angular Rate (Run 3)');
grid on;

subplot(2,1,2)
% Calibrated angular rate (run 4)
plot(time_4, Corrected_Output4) 
hold on;
% True angular rate (run 4)
plot(time_4, Rate_Input4)       
xlabel('Time (s)')
ylabel('Angular Rate (rad/s)')
legend('Calibrated Output', 'True Input');
title('Calibrated vs True Angular Rate (Run 4)');
grid on;

% Rate Measurement Errors
% Error: calibrated (measured) - true
Measurement_error3 = Corrected_Output3 - Rate_Input3; 
Measurement_error4 = Corrected_Output4 - Rate_Input4;

% Measurement error plots
figure; 
subplot(2,1,1)
plot(time_3, Measurement_error3)
xlabel('Time (s)')
ylabel('Angular Rate Error (rad/s)')
title('Rate Measurement Error (Run 3)');
grid on;

subplot(2,1,2)
plot(time_4, Measurement_error4)
xlabel('Time (s)')
ylabel('Angular Rate Error (rad/s)')
title('Rate Measurement Error (Run 4)');
grid on;

% Integrate Angular Rate to Get Position
Gyro_position3 = cumtrapz(time_3, Corrected_Output3);
Gyro_position4 = cumtrapz(time_4, Corrected_Output4);
Input_position3 = cumtrapz(time_3, Rate_Input3);    
Input_position4 = cumtrapz(time_4, Rate_Input4);

% Compare Angular Positions 
figure; 
subplot(2,1,1)
% Calibrated angular position (run 3)
plot(time_3, Gyro_position3) 
hold on;
% True angular position (run 3)
plot(time_3, Input_position3) 
xlabel('Time (s)')
ylabel('Angular Position (rad)')
legend('Measured Position', 'True Position');
title('Angular Position vs Time (Run 3)');
grid on;

subplot(2,1,2)
% Calibrated angular position (run 4)
plot(time_4, Gyro_position4)
hold on;
% True angular position (run 4)
plot(time_4, Input_position4)
xlabel('Time (s)')
ylabel('Angular Position (rad)')
legend('Measured Position', 'True Position');
title('Angular Position vs Time (Run 4)');
grid on;

% Angular Position Errors 
Gyro_error3 = Gyro_position3 - Input_position3; 
Gyro_error4 = Gyro_position4 - Input_position4;

figure; 
subplot(2,1,1)
plot(time_3, Gyro_error3)
xlabel('Time (s)')
ylabel('Angular Position Error (rad)')
title('Angular Position Error vs Time (Run 3)');
grid on;

subplot(2,1,2)
plot(time_4, Gyro_error4)
xlabel('Time (s)')
ylabel('Angular Position Error (rad)')
title('Angular Position Error vs Time (Run 4)');
grid on;

% Input Rate and Angular Position Error Comparison
figure;
subplot(2,1,1)
plot(Rate_Input3, Gyro_error3)
xlabel('True Angular Position (rad)')
ylabel('Measured Angular Position (rad)')
title('Measured vs True Angular Position (Run 3)');
grid on;

subplot(2,1,2)
plot(Rate_Input4, Gyro_error4)
xlabel('True Angular Position (rad)')
ylabel('Measured Angular Position (rad)')
title('Measured vs True Angular Position (Run 4)');
grid on;

