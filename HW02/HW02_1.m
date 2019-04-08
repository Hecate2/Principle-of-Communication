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

%% energy specturm density;
fft_mySpeech = fft(mySpeech)/sqrt(N);
if(mod(N,2)==1)%点数为奇数
    fd_mySpeech=[fft_mySpeech((N+3)/2:N) fft_mySpeech(1:(N+1)/2)];
    freq=Fs/2;
    freq=-freq+Fs/N/2:Fs/N:freq;
else
    fd_mySpeech=[fft_mySpeech((N+2)/2:N) fft_mySpeech(1:N/2)];
    freq=Fs/2;
    freq=-freq:Fs/N:freq-Fs/N;
end
es_mySpeech=abs(fd_mySpeech).^2;
%plot(freq,es_mySpeech);

%% 求百分比带宽
[b90L,b90R]=percentBand(es_mySpeech,0.9);
b90L=freq(b90L);b90R=freq(b90R);
[b98L,b98R]=percentBand(es_mySpeech,0.98);
b98L=freq(b98L);b98R=freq(b98R);

%% 画能量谱图
[max_y,~]=max(es_mySpeech);%求能量谱最大值，辅助于画图
max_y=1.1*max_y;%画图纵坐标到这里为止

figure
plot(freq,es_mySpeech);%能量谱
hold on
plot([b90L b90L],[0 max_y]);   hold on;    plot([b90R b90R],[0 max_y]);   hold on;
plot([b98L b98L],[0 max_y]);   hold on;    plot([b98R b98R],[0 max_y]);   hold on;
axis([1.1*b98L 1.1*b98R -inf inf]);
title('输入语音的能量谱，98%带宽范围和90%带宽范围')
xlabel('Hz');

mySpeech=idealLPFilter(mySpeech,Fs,b98R);%取98%带宽
[DSB_LC,DSB_SC]=AMmodu(mySpeech,x_line,1.1*max(abs(mySpeech)),10000);%载波频率10000Hz
SSB=idealLPFilter(DSB_SC,Fs,10000);

figure
subplot(3,1,1);	plot(x_line,DSB_LC);   title('DSB-LC时域波形');   hold on;
subplot(3,1,2);	plot(x_line,DSB_SC);   title('DSB-SC时域波形');   hold on;
subplot(3,1,3);	plot(x_line,SSB);   title('SSB时域波形');   hold on;
figure
subplot(3,1,1);	[spec,freq]=freqSpec(DSB_LC,Fs);    plot(freq,spec);   title('DSB-LC频谱');  hold on;
subplot(3,1,2);	[spec,freq]=freqSpec(DSB_SC,Fs);    plot(freq,spec);   title('DSB-SC频谱');  hold on;
subplot(3,1,3);	[spec,freq]=freqSpec(SSB,Fs);    plot(freq,spec);   title('SSB频谱');  hold on;
xlabel('Hz')


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

%% 求百分比带宽的函数
function [left,right]=percentBand(es,percentage)%还可增加frequency输入
%计算能量谱数组es(单位不是dB，横坐标数组为frequency)的percentage带宽。
%可以只输入spectrum和percentage。此时frequency默认为关于0对称，单位为Hz。例如spectrum有20个值，则frequency默认为-10到9Hz
if (percentage>=1 || percentage<=0)
    error('partialBand的第2个参数percentage应小于1，大于0');
    left=0;
    right=0;
    return
end
%spectrum=abs(real(spectrum));
%if nargin==3
    %直接开始求百分比带宽
    energy=sum(es);
    target=percentage*energy;%希望剩下那么多能量
    currentEnergy=energy;
    left=1;
    right=length(es);
    while(left<right)
        currentEnergy=currentEnergy-es(left)-es(right);
        if currentEnergy<target
            mistake=currentEnergy-target;%不带左右两侧时的误差（负数）
            mistakeLR=es(left)+es(right)+mistake;%加上左右两侧时的误差（正数）
            mistakeL=es(left)+mistake;%只加上左侧
            mistakeR=es(right)+mistake;%只加上右侧
            [~,index]=min(abs([mistake,mistakeLR,mistakeL,mistakeR]));
            switch index
                case 1
                    left=left+1;
                    right=right-1;
                case 2
                    %什么都不做
                case 3
                    right=right-1;
                case 4
                    left=left+1;
            end
            return
        elseif currentEnergy==target
            left=left+1;
            right=right-1;
            return
        else
            left=left+1;
            right=right-1;
        end
    end
    return
% elseif nargin==2
%     %没输入frequency.先求frequency
%     halfLen=length(spectrum)/2;
%     if mod(halfLen,1)==0  %是整数，即频谱长度为偶数
%         frequency=-halfLen:1:halfLen-1;
%     else	%频谱长度是奇数
%         halfLen=floor(halfLen);
%         frequency=-halfLen:1:halfLen;
%     end
% else
%     error('partialBand应输入2个或3个参数','partialBand')
% end
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

%% AM调制函数
function [DSB_LC,DSB_SC]=AMmodu(tin,tx,tinBias,carrierFreq,carrierPhase)
%时域波形tin，横轴坐标tx，输入波形的正偏移量tinBias,载波频率carrierFreq(Hz)，载波初始相位(rad)（默认0）
%载波为cos(carrierFreq*2*pi*t+carrierPhase)。幅度总是1。
%tinBias可以考虑采用1.1*max(abs(tin))
if nargin<5
    carrierPhase=0;
end
carrier=cos(carrierFreq*2*pi*tx+carrierPhase);
DSB_SC=carrier.*tin;%不含载波
DSB_LC=DSB_SC+tinBias*carrier;%含载波
end