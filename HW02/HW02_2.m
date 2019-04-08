clear
close all;

Fs = 44100;                                         % sample frequency;
r = audiorecorder(Fs, 16, 1);                       % please refer to the help in matlab for this function;

%% record the wave;
record(r);                                          % speak into microphone...
tmp = input('Recording. Press ENTER to stop');
stop(r);
% pause(2);                                           % wait for 2 second
% p = play(r);                                        % listen to complete recording
mySpeech_a = getaudiodata(r);                         % get data as 'double' array
% mySpeech = getaudiodata(r, 'int16');              % get data as int16 array
% mySpeech = getaudiodata(r, 'int8');               % get data as int8 array

t_start = round(0.2*Fs);
if t_start>=length(mySpeech_a)
    error('输入语音的前0.2秒会被切除。请延长录制时间');
end
mySpeech = mySpeech_a(t_start:end);                 % cut the first 0.2 second of record;

mySpeech=mySpeech';

%% plot the waveform in the time domain;
N = length(mySpeech);                               % the number of total sample points;
Ts = 1/Fs;                                          % sample period;
T = N*Ts;                                           % total duration of this waveform;
x_line = [0:Ts:(N-1)*Ts];                           % x_line in the figure;
plot(x_line, mySpeech);                             % plot the waveform;
% hold on;
xlabel('{\it{t}} seconds', 'FontSize', 16);
ylabel('{\it x(t)}', 'FontSize', 16);
title('输入语音');
set(gca,'FontSize',16);

%% add White Gaussian Noise
%先求输入信号平均功率
power=avgPower(mySpeech,Fs);
%开始加噪声
SNRlist=[10,20,30,40,50];%单位dB
lenList=length(SNRlist);
noiseSpeech=zeros(lenList,N);
i=1;
figure
for SNR=SNRlist
    noiseSpeech(i,:)=awgn(mySpeech,SNR,power);
    subplot(lenList,1,i);
    plot(x_line,noiseSpeech(i,:));
    title(['加上信噪比',num2str(SNR),'dB的高斯白噪声后的波形'])
    hold on;
%     r=audioplayer(noiseSpeech(i,:), Fs);
%     play(r);
    i=i+1;
end

%% 对带有白噪声的信号滤波
i=2;
figure
plot(x_line,noiseSpeech(i,:));
hold on
filteredSpeech=idealLPFilter(noiseSpeech(i,:),Fs,3000);
plot(x_line,filteredSpeech);
title('有白噪声时，滤波前后的波形')
legend('滤波前','滤波后');
% r=audioplayer(filteredSpeech, Fs);
% play(r);


%% 求有限时长信号的平均功率的函数
function power=avgPower(tin,Fs)
%输入时域信号和采样率(Hz)，输出平均功率
power=sum(tin.^2)/length(tin)/Fs;
end

%% 求频谱的函数
function [spec,freq]=freqSpec(tin,Fs)
%输入波形tin，采样频率Fs(Hz)
%输出频谱纵坐标spec，横坐标freq(Hz)
%可plot(freq,spec)
N=length(tin);
spec = fft(tin)/sqrt(N);
if(mod(N,2)==1)%点数为奇数
    spec=[spec((N+3)/2:N) spec(1:(N+1)/2)];
    freq=Fs/2;
    freq=-freq+Fs/N/2:Fs/N:freq;
else
    spec=[spec((N+2)/2:N) spec(1:N/2)];
    freq=Fs/2;
    freq=-freq:Fs/N:freq-Fs/N;
end
end

%% 理想低通滤波函数
function tout=idealLPFilter(tin,Fs,cutFreq)
%输入时域波形，时域波形的采样频率(Hz)和滤波器的截止频率(Hz)。直接将频率绝对值高于cutFreq的频谱删除为0，然后输出滤波后的时域波形
len=length(tin);
tout=fft(tin);
cutFreq=ceil(cutFreq/Fs*len);%fft结果中需要置为0的第1个点的下标tin(Fs)
tout(cutFreq:len-cutFreq)=0;
tout=ifft(tout);
end
