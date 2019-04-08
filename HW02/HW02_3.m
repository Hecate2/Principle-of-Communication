clear
close all

Fs=10000000;    %�������۲⣩Ƶ��
Ts=1/Fs;
tx=0:Ts:0.0005;
tin=cos(2*pi*1000*tx);

carrierFreq=1000000;
kfList=[50 100 200 500 1000];%������Ļ���ʱ�����ϼ���������ʲô����
for kf=kfList
    tout=FMmodu(tin,tx,kf,carrierFreq);%�ز�Ƶ��1MHz
    figure
    plot(tx,tout);
    hold on
    plot(tx,tin);
    title(['FM���Ƶ�ʱ����,K_f=',num2str(kf)]);
    legend('���ƽ��','���Ʋ���');
    figure
    [spec,freq]=freqSpec(tout,Fs);
    plot(freq,spec);
    title(['FM���Ƶ�Ƶ��,K_f=',num2str(kf)]);
    hold on
    %��98%����
    [b98L,b98R]=percentBand(abs(spec).^2,0.98);
    b98L=freq(b98L);b98R=freq(b98R);
    max_y=1.1*max(spec);    min_y=1.1*min(spec);
    plot([b98L b98L],[min_y max_y]);   hold on;    plot([b98R b98R],[min_y max_y]);   hold on;
    %axis([1.1*b98L 1.1*b98R -inf inf]);
    legend('Ƶ��','98%����Χ');
    mf=kf*max(abs(tin))/carrierFreq;
    B_fm=2*(mf+1)*carrierFreq
end
disp('B_fm��֤Carson��ʽ')


%% FM���ƺ���
function tout=FMmodu(tin,tx,kf,carrierFreq,carrierPhase)
%����ʱ���Σ�ʱ��x�ᣬ��Ƶ������kf���ز�Ƶ��(Hz)���ز���ʼ��λ(rad)(Ĭ��0)
if nargin<5
    carrierPhase=0;
end
dt=diff(tx);
dt=[dt sum(dt)/length(dt)];
tin=kf*cumsum(tin.*dt);
tout=cos(2*pi*carrierFreq*tx+tin+carrierPhase);
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
