% EE405C<Network of Smart Systems> Final Project - Wed 1(Acoustic GPS)
% startGPS.m
% Copyright 2017 by KIM Kwanwoo and PARK Jongeui
% First written: 2017-05-26

global X
global Y
global init
fs = 44100;     % sampling rate
delta = 0.05;   % pulse period
width = 50;     % pulse width
xlimits = [0 89.1];
ylimits = [0 42];
init = true;
X = [0 0.891 0 0.891];
Y = [0 0 0.42 0.42];
transmitter;    % start transmitter
receiver;       % start receiver