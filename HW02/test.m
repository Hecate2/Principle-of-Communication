clear

Fs=10000;
Ts=1/Fs;
t=0:Ts:10;
%mySpeech=cos(2*pi*300*t);
%mySpeech=wgn(1,length(t),10);
%mySpeech=(sin(2*pi*50*t).*sin(2*pi*1000*t)+sin(2*pi*100*t).*cos(2*pi*1000*t)).*cos(2*pi*1002*t);
mySpeech=exp(-abs(t-1)).*cos(10000*t);
[spec,freq]=freqSpec(mySpeech,Fs);
figure
plot(freq,spec);
mySpeech=idealLPFilter(abs(mySpeech),Fs,20000);
% figure
% [spec,freq]=freqSpec(mySpeech,Fs);
% plot(freq,spec)

% [DSB_LC,DSB_SC]=AMmodu(mySpeech,t,1.1*max(abs(mySpeech)),80000);%载波频率80000Hz
% SSB=idealLPFilter(DSB_SC,Fs,80000);
% figure
% subplot(3,1,1);	plot(t,DSB_LC);   title('DSB-LC时域波形');   hold on;
% subplot(3,1,2);	plot(t,DSB_SC);   title('DSB-SC时域波形');   hold on;
% subplot(3,1,3);	plot(t,SSB);   title('SSB时域波形');   hold on;
% figure
% subplot(3,1,1);	[spec,freq]=freqSpec(DSB_LC,Fs);    plot(freq,spec);   title('DSB-LC频谱');  hold on;
% subplot(3,1,2);	[spec,freq]=freqSpec(DSB_SC,Fs);    plot(freq,spec);   title('DSB-SC频谱');  hold on;
% subplot(3,1,3);	[spec,freq]=freqSpec(SSB,Fs);    plot(freq,spec);   title('SSB频谱');  hold on;
% xlabel('Hz')

%% 理想滤波函数
function tout=idealLPFilter(tin,Fs,cutFreq)
%输入时域波形，时域波形的采样频率(Hz)和滤波器的截止频率(Hz)。直接将频率绝对值高于cutFreq的频谱删除为0，然后输出滤波后的时域波形（仅实部）
len=length(tin);
tout=fft(tin);
cutFreq=ceil(cutFreq/Fs*len);%fft结果中需要置为0的第1个点的下标tin(Fs)
tout(cutFreq:len-cutFreq)=0;
tout=real(ifft(tout));
end
%% AM调制函数
function [DSB_LC,DSB_SC]=AMmodu(tin,tx,tinBias,carrierFreq,carrierPhase)
%时域波形tin，横轴坐标tx,载波频率carrierFreq(Hz)，载波初始相位(rad)（默认0），输入波形的正偏移量tinBias
%载波为cos(carrierFreq*2*pi*t+carrierPhase)。幅度总是1。
%tinBias可以考虑采用1.1*max(abs(tin))
if nargin<5
    carrierPhase=0;
end
carrier=cos(carrierFreq*2*pi*tx+carrierPhase);
DSB_SC=carrier.*tin;%不含载波
DSB_LC=DSB_SC+tinBias*carrier;%含载波
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