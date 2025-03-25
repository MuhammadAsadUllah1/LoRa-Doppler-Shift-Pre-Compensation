% Author: Muhammad Asad Ullah
% Email: Asad.Ullah@vtt.fi
clear all
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fc: 400.45 MHz carrier frequency in downlink 
% fc_prime: 401.45 MHz nominal carrier frequency in uplink     
% fd: Theoratical Doppler shift in downlink
% fd_prime: Theoratical Doppler shift in uplink
% timestamps: Timestamps when real-world LoRa packet was received by TinyGS
% FP: Predicted Doppler shift values from TinyGS
% FE: Frequency Error (estimated Doppler shift) values from TinyGS 
% t: theoratical time instant
% fe: extrapolated Frequency Error (estimated Doppler shift) in downlink
% fe_prime: extrapolated Frequency Error (estimated Doppler shift) in uplink

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TinyGS real-world data
% Time stamps when LoRa packet was received by TinyGS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
timestamps= datetime({'Jun 11, 2024 02:23:59', 'Jun 11, 2024 02:23:29', ...
                         'Jun 11, 2024 02:23:14', 'Jun 11, 2024 02:22:44', ...
                         'Jun 11, 2024 02:22:29', 'Jun 11, 2024 02:22:14', ...
                         'Jun 11, 2024 02:21:59', 'Jun 11, 2024 02:21:44', ...
                         'Jun 11, 2024 02:21:14', 'Jun 11, 2024 02:20:59', ...
                         'Jun 11, 2024 02:20:44', 'Jun 11, 2024 02:20:29', ...
                         'Jun 11, 2024 02:20:14', 'Jun 11, 2024 02:19:59' ...
                         'Jun 11, 2024 02:19:44', 'Jun 11, 2024 02:19:29', ...
                         'Jun 11, 2024 02:19:14', 'Jun 11, 2024 02:18:59', ...
                         'Jun 11, 2024 02:18:44', 'Jun 11, 2024 02:18:29', ...
                         'Jun 11, 2024 02:18:14', 'Jun 11, 2024 02:17:59'});
% Predicted Doppler shift values from TinyGS
FP = [-9171.80, -9043.21, -8956.43, -8718.06, ...
                       -8554.57, -8350.22, -8092.89, -7766.38, ...
                       -6813.99, -6126.95, -5251.64, -4157.45, ...
                       -2836.52, -1324.63,288.65, 1878.65, 3329.12, 4569.41, ...
                       5581.61, 6384.19, 7011.43, 7499.47];
% Estimated Doppler shift values from TinyGS
FE = [8380.22, 8262.78, 8128.56, 7843.35, ...
                     7675.58, 7474.25, 7189.04, 6803.16, ...
                     5729.42, 5008.00, 4018.14, 2810.18, ...
                     1384.12, -276.82,-2088.76, -3800.04, -5393.88, -6736.05, ...
                     -7860.13, -8732.54, -9386.85, -9906.95];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Carrier frequencies
fc = 400.45e6;                                 % Uplink
fc_prime = 401.45e6;                           % Downlink
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Theoratical Doppler shift calculation and exrapolation
[fd t] = DopplerModelFunction (fc);            % Doppler shift
Fe = interp1(FP, FE, fd, 'linear', 'extrap');  % Extrapolation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Doppler shift pre compensation
f=(fc+Fe);                                     % this is only for visualization                  
f_prime=(fc_prime+Fe*(fc_prime/fc));            % f_prime in Equation (): pre-compensation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Add Doppler shift to pre-compensated signal
[fd_prime t]= DopplerModelFunction (f_prime);   % fd' Equation (11)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Extrapolation
% It is important to note that fd_prime in equation (11) is theoretical 
% and does not account for errors caused by transmitter and receiver oscillators deviations, 
% nor does it fully reflect empirical behavior. To better approximate the empirical behavior, 
% we extrapolate fd_prime using TinyGS's data on predicted Doppler shift FP and estimated Doppler shift FE.
% Let fe_prime be the  linear extrapolation of fd_prime. 
% Given this, the satellite receives the uplink signal at
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fe_prime = interp1(FP, FE, fd_prime, 'linear', 'extrap');
%% The satellite receives the uplink signal at fr_prime
fr_prime = f_prime - Fe_prime;                  % fr' Equation (12)
fd_actual = f_prime + fd_prime;                  % this only for visualization   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f1=figure(1); % new numbered figure 
set(gcf, 'Units', 'centimeters'); % set units 
LineWidth = 2;
axesFontSize = 18;
legendFontSize = 14;
% setting size & position
afFigurePosition = [2 7 19 11]; % [pos_x pos_y width_x width_y] 
set(gcf, 'Position', afFigurePosition,'PaperSize',[19 11],'PaperPositionMode','auto');
subplot(121)
plot(t,(fc/1e6)*ones(1,length(f)),'g-', 'LineWidth',LineWidth);
hold on
plot(t,f/1e6,'k-', 'LineWidth',LineWidth);
legend({'$f_\mathrm{c}$','$f_\mathrm{e}(t)$'}, ...
   'Location', 'north', 'NumColumns', 1, 'Interpreter', 'latex', 'FontSize', legendFontSize);
 xlabel('Time, $t$ [s]','Interpreter','latex','FontSize', axesFontSize)
ylabel('Center frequency (MHz)','Interpreter','Latex','FontSize', axesFontSize)
 title('Downlink (400.45 MHz)', 'Interpreter', 'latex', 'FontSize', axesFontSize)
 grid on
subplot(122)
yyaxis left
ax = gca;
ax.YColor = 'k';
ax.YLabel.Color = 'k';
h(1)=plot(t,(fc_prime/1e6)*ones(1,length(f_prime)),'g-', 'LineWidth',LineWidth);
hold on
h(2)=plot(t,f_prime/1e6,'k-', 'LineWidth',LineWidth); 
h(3)=plot(t,fr_prime/1e6,'b--', 'LineWidth',LineWidth);
yyaxis right
ax = gca;
ax.YColor = 'r';
ax.YLabel.Color = 'r';
h(4)=plot(t,fd_prime/1e3,'r-', 'LineWidth',2);
ylabel('Doppler shift (kHz)','Interpreter','Latex','FontSize', axesFontSize)
legend(h(1:4),{'$f''_\mathrm{c}$','$f''(t)$','$f''_\mathrm{r}(t)$','$f''_\mathrm{d}(t)$'}, ...
   'Location', 'north', 'NumColumns', 1, 'Interpreter', 'latex', 'FontSize', legendFontSize);
 xlabel('Time, $t$ [s]','Interpreter','latex','FontSize', axesFontSize)
title('Uplink (401.45 MHz)', 'Interpreter', 'latex', 'FontSize', axesFontSize)
grid on