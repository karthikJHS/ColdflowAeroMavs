%SIMULATION OF THROTTLE ON COMBUSTION
% 
% Purpose:  
%       reads and plots orbit from the CSV file
%       then files is inputted into simulink for the simulation.
%       the code will then recieve data that will be converted into a graph
%       and then outputted into a csv file for us to use elsewhere. 
% Date: 12/05/25
% Author: Karthik
% Affiliation: UTA
% ============================================================

clear; clc; close all;


%% === READ CSV output from C++ ===
filename = 'orbit_results';
% M will be 1 x 20 (one data row, 20 columns), skipping the header
M = readmatrix(filename, 'NumHeaderLines', 1);