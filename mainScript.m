clc;
close all;
clear all;

x = ones(5000, 1);
h = ones(3000, 1);

% [stereo_x, fsx] = audioread('122772.LOFI.mp3');
% [stereo_h, fsh] = audioread('94350.LOFI.mp3');
% 
% x = stereo_x(1 : 60 * fsx, 1);
% h = stereo_h(1 : 5 * fsh, 1);

y = myFastConvolution(x, h);
% y = myUniformConvolution(x, h);

y_ref = conv(x, h);

plot(y);
hold on;
plot(y_ref,':');

[m, mabs, stdev, time] = compareConv(x, h);
