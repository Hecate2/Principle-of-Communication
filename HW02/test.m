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

% [DSB_LC,DSB_SC]=AMmodu(mySpeech,t,1.1*max(abs(mySpeech)),80000);%�ز�Ƶ��80000Hz
% SSB=idealLPFilter(DSB_SC,Fs,80000);
% figure
% subplot(3,1,1);	plot(t,DSB_LC);   title('DSB-LCʱ����');   hold on;
% subplot(3,1,2);	plot(t,DSB_SC);   title('DSB-SCʱ����');   hold on;
% subplot(3,1,3);	plot(t,SSB);   title('SSBʱ����');   hold on;
% figure
% subplot(3,1,1);	[spec,freq]=freqSpec(DSB_LC,Fs);    plot(freq,spec);   title('DSB-LCƵ��');  hold on;
% subplot(3,1,2);	[spec,freq]=freqSpec(DSB_SC,Fs);    plot(freq,spec);   title('DSB-SCƵ��');  hold on;
% subplot(3,1,3);	[spec,freq]=freqSpec(SSB,Fs);    plot(freq,spec);   title('SSBƵ��');  hold on;
% xlabel('Hz')

%% �����˲�����
function tout=idealLPFilter(tin,Fs,cutFreq)
%����ʱ���Σ�ʱ���εĲ���Ƶ��(Hz)���˲����Ľ�ֹƵ��(Hz)��ֱ�ӽ�Ƶ�ʾ���ֵ����cutFreq��Ƶ��ɾ��Ϊ0��Ȼ������˲����ʱ���Σ���ʵ����
len=length(tin);
tout=fft(tin);
cutFreq=ceil(cutFreq/Fs*len);%fft�������Ҫ��Ϊ0�ĵ�1������±�tin(Fs)
tout(cutFreq:len-cutFreq)=0;
tout=real(ifft(tout));
end
%% AM���ƺ���
function [DSB_LC,DSB_SC]=AMmodu(tin,tx,tinBias,carrierFreq,carrierPhase)
%ʱ����tin����������tx,�ز�Ƶ��carrierFreq(Hz)���ز���ʼ��λ(rad)��Ĭ��0�������벨�ε���ƫ����tinBias
%�ز�Ϊcos(carrierFreq*2*pi*t+carrierPhase)����������1��
%tinBias���Կ��ǲ���1.1*max(abs(tin))
if nargin<5
    carrierPhase=0;
end
carrier=cos(carrierFreq*2*pi*tx+carrierPhase);
DSB_SC=carrier.*tin;%�����ز�
DSB_LC=DSB_SC+tinBias*carrier;%���ز�
end
%% ��Ƶ�׵ĺ���
function [spec,freq]=freqSpec(tin,Fs)
%���벨��tin������Ƶ��Fs(Hz)
%���Ƶ��������spec��������freq(Hz)
%��plot(freq,spec)
N=length(tin);
spec = fft(tin)/sqrt(N);
if(mod(N,2)==1)%����Ϊ����
    spec=[spec((N+3)/2:N) spec(1:(N+1)/2)];
    freq=Fs/2;
    freq=-freq+Fs/N/2:Fs/N:freq;
else
    spec=[spec((N+2)/2:N) spec(1:N/2)];
    freq=Fs/2;
    freq=-freq:Fs/N:freq-Fs/N;
end
end