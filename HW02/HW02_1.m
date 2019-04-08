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

%% energy specturm density;
fft_mySpeech = fft(mySpeech)/sqrt(N);
if(mod(N,2)==1)%����Ϊ����
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

%% ��ٷֱȴ���
[b90L,b90R]=percentBand(es_mySpeech,0.9);
b90L=freq(b90L);b90R=freq(b90R);
[b98L,b98R]=percentBand(es_mySpeech,0.98);
b98L=freq(b98L);b98R=freq(b98R);

%% ��������ͼ
[max_y,~]=max(es_mySpeech);%�����������ֵ�������ڻ�ͼ
max_y=1.1*max_y;%��ͼ�����굽����Ϊֹ

figure
plot(freq,es_mySpeech);%������
hold on
plot([b90L b90L],[0 max_y]);   hold on;    plot([b90R b90R],[0 max_y]);   hold on;
plot([b98L b98L],[0 max_y]);   hold on;    plot([b98R b98R],[0 max_y]);   hold on;
axis([1.1*b98L 1.1*b98R -inf inf]);
title('���������������ף�98%����Χ��90%����Χ')
xlabel('Hz');

mySpeech=idealLPFilter(mySpeech,Fs,b98R);%ȡ98%����
[DSB_LC,DSB_SC]=AMmodu(mySpeech,x_line,1.1*max(abs(mySpeech)),10000);%�ز�Ƶ��10000Hz
SSB=idealLPFilter(DSB_SC,Fs,10000);

figure
subplot(3,1,1);	plot(x_line,DSB_LC);   title('DSB-LCʱ����');   hold on;
subplot(3,1,2);	plot(x_line,DSB_SC);   title('DSB-SCʱ����');   hold on;
subplot(3,1,3);	plot(x_line,SSB);   title('SSBʱ����');   hold on;
figure
subplot(3,1,1);	[spec,freq]=freqSpec(DSB_LC,Fs);    plot(freq,spec);   title('DSB-LCƵ��');  hold on;
subplot(3,1,2);	[spec,freq]=freqSpec(DSB_SC,Fs);    plot(freq,spec);   title('DSB-SCƵ��');  hold on;
subplot(3,1,3);	[spec,freq]=freqSpec(SSB,Fs);    plot(freq,spec);   title('SSBƵ��');  hold on;
xlabel('Hz')


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

%% ��ٷֱȴ���ĺ���
function [left,right]=percentBand(es,percentage)%��������frequency����
%��������������es(��λ����dB������������Ϊfrequency)��percentage����
%����ֻ����spectrum��percentage����ʱfrequencyĬ��Ϊ����0�Գƣ���λΪHz������spectrum��20��ֵ����frequencyĬ��Ϊ-10��9Hz
if (percentage>=1 || percentage<=0)
    error('partialBand�ĵ�2������percentageӦС��1������0');
    left=0;
    right=0;
    return
end
%spectrum=abs(real(spectrum));
%if nargin==3
    %ֱ�ӿ�ʼ��ٷֱȴ���
    energy=sum(es);
    target=percentage*energy;%ϣ��ʣ����ô������
    currentEnergy=energy;
    left=1;
    right=length(es);
    while(left<right)
        currentEnergy=currentEnergy-es(left)-es(right);
        if currentEnergy<target
            mistake=currentEnergy-target;%������������ʱ����������
            mistakeLR=es(left)+es(right)+mistake;%������������ʱ����������
            mistakeL=es(left)+mistake;%ֻ�������
            mistakeR=es(right)+mistake;%ֻ�����Ҳ�
            [~,index]=min(abs([mistake,mistakeLR,mistakeL,mistakeR]));
            switch index
                case 1
                    left=left+1;
                    right=right-1;
                case 2
                    %ʲô������
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
%     %û����frequency.����frequency
%     halfLen=length(spectrum)/2;
%     if mod(halfLen,1)==0  %����������Ƶ�׳���Ϊż��
%         frequency=-halfLen:1:halfLen-1;
%     else	%Ƶ�׳���������
%         halfLen=floor(halfLen);
%         frequency=-halfLen:1:halfLen;
%     end
% else
%     error('partialBandӦ����2����3������','partialBand')
% end
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

%% AM���ƺ���
function [DSB_LC,DSB_SC]=AMmodu(tin,tx,tinBias,carrierFreq,carrierPhase)
%ʱ����tin����������tx�����벨�ε���ƫ����tinBias,�ز�Ƶ��carrierFreq(Hz)���ز���ʼ��λ(rad)��Ĭ��0��
%�ز�Ϊcos(carrierFreq*2*pi*t+carrierPhase)����������1��
%tinBias���Կ��ǲ���1.1*max(abs(tin))
if nargin<5
    carrierPhase=0;
end
carrier=cos(carrierFreq*2*pi*tx+carrierPhase);
DSB_SC=carrier.*tin;%�����ز�
DSB_LC=DSB_SC+tinBias*carrier;%���ز�
end