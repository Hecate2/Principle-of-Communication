clear
close all;

Fs=44100;
Ts=1/Fs;
processSize=1000;
tries=10000;
rnd=zeros(tries,processSize);
%avg=zeros(tries,1);
mu=0;sigma=1;
rnd=normrnd(mu,sigma,tries,processSize);
% for i=1:tries
%     
%     %avg(i,1)=sum(rnd)/sizeProcess;
% end
ensembleAvg=mean(rnd,1);

figure
plot(ensembleAvg);
title(['��˹������������̵ļ�ƽ����\mu=',num2str(mu),'��\sigma=',num2str(sigma)]);

figure
enAvg=zeros(1,processSize);
avgTries=200;
for i=[1:1:avgTries]
    [spec,freq]=freqSpec(rnd(i,:),Fs);
    enAvg=enAvg+abs(spec).^2;
end
enAvg=enAvg./avgTries;
plot(freq,enAvg);
title(['��˹������������̵�ƽ�������ף�\mu=',num2str(mu),'��\sigma=',num2str(sigma)]);
xlabel('Hz');
[b98L,b98R]=percentBand(spec,0.98);
b98L=freq(b98L);b98R=freq(b98R);
axis([1.1*b98L 1.1*b98R -inf inf]);

figure
fp=14550;fs=15000;%3dB��20dB˥��Ƶ��(Hz)
[bz,az]=LPdesign(fp,fs,Fs);
filted=filter(bz,az,rnd(1,:));
plot(filted);
title(['�˲�����������ʱ���Σ�f_p=',num2str(fp),'Hz��f_s=',num2str(fs),'Hz']);

figure
[spec,freq]=freqSpec(filted,Fs);
plot(freq,abs(spec).^2);
title(['�˲����������������ף�f_p=',num2str(fp),'Hz��f_s=',num2str(fs),'Hz']);
xlabel('Hz');
% [b98L,b98R]=percentBand(spec,0.98);
% b98L=freq(b98L);b98R=freq(b98R);
axis([1.1*b98L 1.1*b98R -inf inf]);

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

%% �˲����Զ���ƺ���
function [bz,az]=LPdesign(fp,fs,Fs)
%���ֵ�ͨ�˲����Զ����:IIR��������˹��˫���Ա任
%fp:3dB˥��Ƶ��(Hz)  fs:20dB˥��Ƶ��(Hz)  Fs:��������ϵͳ�Ĳ�����
%���z�任�µ������ݺ����ķ���ϵ������bz�ͷ�ĸϵ������az��������filter����
%�����ǳ���ʱ����֤Ч��
rp=3;rs=20; %3dB��20dB;��fp��fs����˥��

%���治�ù�
wp=2*pi*fp/Fs;% 2Pi - Fs ��> 100hz - 0.1Fs*2Pi=0.2Pi 
ws=2*pi*fs/Fs; 
Fs1=1; % let Fs=1 
% Firstly to finish frequency prewarping ; 
wap=tan(wp/2);was=tan(ws/2); %��p����s 
[n,wn]=buttord(wap,was,rp,rs,'s'); %n:�˲�������, wn:buttord�������Ȼ����Ƶ�ʣ�һ��>wp 
disp(['��Ƶõ��˲�������:',num2str(n)]);
% Note: 's'! 
[z,p,k]=buttap(n); %���㣬��㣬���� 

%a�Ƿ�ĸ��b�Ƿ���
[bp,ap]=zp2tf(z,p,k); %G(p)�ķ��ӣ���ĸ����ʽϵ�� G(p)=1/p^2+��(n)*p+1 
[bs,as]=lp2lp(bp,ap,wap); %G(s)=G(p)|p=s/��p 
% Note: s=(2/Ts)(z-1)/(z+1);Ts=1,that is 2fs=1,fs=0.5; 
[bz,az]=bilinear(bs,as,Fs1/2); %H(z) = G(s)|s=z-1/z+1 
% [h,w]=freqz(bz,az,Fs,Fs); 
% plot(w,abs(h));grid on;
end