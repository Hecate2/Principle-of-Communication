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
    error('����������ǰ0.2��ᱻ�г������ӳ�¼��ʱ��');
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
title('��������');
set(gca,'FontSize',16);

%% add White Gaussian Noise
%���������ź�ƽ������
power=avgPower(mySpeech,Fs);
%��ʼ������
SNRlist=[10,20,30,40,50];%��λdB
lenList=length(SNRlist);
noiseSpeech=zeros(lenList,N);
i=1;
figure
for SNR=SNRlist
    noiseSpeech(i,:)=awgn(mySpeech,SNR,power);
    subplot(lenList,1,i);
    plot(x_line,noiseSpeech(i,:));
    title(['���������',num2str(SNR),'dB�ĸ�˹��������Ĳ���'])
    hold on;
%     r=audioplayer(noiseSpeech(i,:), Fs);
%     play(r);
    i=i+1;
end

%% �Դ��а��������ź��˲�
i=2;
figure
plot(x_line,noiseSpeech(i,:));
hold on
filteredSpeech=idealLPFilter(noiseSpeech(i,:),Fs,3000);
plot(x_line,filteredSpeech);
title('�а�����ʱ���˲�ǰ��Ĳ���')
legend('�˲�ǰ','�˲���');
% r=audioplayer(filteredSpeech, Fs);
% play(r);


%% ������ʱ���źŵ�ƽ�����ʵĺ���
function power=avgPower(tin,Fs)
%����ʱ���źźͲ�����(Hz)�����ƽ������
power=sum(tin.^2)/length(tin)/Fs;
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

%% �����ͨ�˲�����
function tout=idealLPFilter(tin,Fs,cutFreq)
%����ʱ���Σ�ʱ���εĲ���Ƶ��(Hz)���˲����Ľ�ֹƵ��(Hz)��ֱ�ӽ�Ƶ�ʾ���ֵ����cutFreq��Ƶ��ɾ��Ϊ0��Ȼ������˲����ʱ����
len=length(tin);
tout=fft(tin);
cutFreq=ceil(cutFreq/Fs*len);%fft�������Ҫ��Ϊ0�ĵ�1������±�tin(Fs)
tout(cutFreq:len-cutFreq)=0;
tout=ifft(tout);
end
