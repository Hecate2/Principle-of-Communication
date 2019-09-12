clear all;
close all;

%% ================
% an example of random process:
% X(t, \xi) = cos(2*fc*t + \xi);  where \xi is a random variable;
%%

%% 
N = 100;     % the number of loops;

fc = 1;      % the frequency fc;

T = 4;       % the time domain window size;
step = 0.01;     % the sampling step in the whole window;
t = [0: step : 1-step] * T;

h = figure;
MAX_xi = 2*pi;        % \xi is uniformly distributed in the range of (0, MAX_xi);

% generate the first sample function;
xi = rand(1)*MAX_xi;
y = cos(2*pi*fc*t + xi);
yE = y;
y1 = y(1);

for i = 1: N
    figure(h), subplot(3,1,1), plot(t, y);    % subfigure 1 shows the sample functions of this random process;
    hold on;
    xi = rand(1)*MAX_xi;
    y = cos(2*pi*fc*t + xi);
    yE = i/(i+1) * yE + 1/(i+1) * y;
    figure(h), subplot(3,1,2), plot(t, yE, 'r');   % subfigure 2 shows the expectation of this random process;
    text(-0.4,0, int2str(i));
    axis([t(1) t(end) -1 +1]);
    y1 = [y1 y(1)];
    figure(h), subplot(3,1,3), hist(y1, 20);  % subfigure 3 shows the distribution of the random variable at t=0;
%     pause(1);
end

