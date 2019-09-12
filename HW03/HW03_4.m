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
title(['高斯白噪声随机过程的集平均，\mu=',num2str(mu),'，\sigma=',num2str(sigma)]);

figure
enAvg=zeros(1,processSize);
avgTries=200;
for i=[1:1:avgTries]
    [spec,freq]=freqSpec(rnd(i,:),Fs);
    enAvg=enAvg+abs(spec).^2;
end
enAvg=enAvg./avgTries;
plot(freq,enAvg);
title(['高斯白噪声随机过程的平均能量谱，\mu=',num2str(mu),'，\sigma=',num2str(sigma)]);
xlabel('Hz');
[b98L,b98R]=percentBand(spec,0.98);
b98L=freq(b98L);b98R=freq(b98R);
axis([1.1*b98L 1.1*b98R -inf inf]);

figure
fp=14550;fs=15000;%3dB和20dB衰减频率(Hz)
[bz,az]=LPdesign(fp,fs,Fs);
filted=filter(bz,az,rnd(1,:));
plot(filted);
title(['滤波后的随机过程时域波形，f_p=',num2str(fp),'Hz，f_s=',num2str(fs),'Hz']);

figure
[spec,freq]=freqSpec(filted,Fs);
plot(freq,abs(spec).^2);
title(['滤波后的随机过程能量谱，f_p=',num2str(fp),'Hz，f_s=',num2str(fs),'Hz']);
xlabel('Hz');
% [b98L,b98R]=percentBand(spec,0.98);
% b98L=freq(b98L);b98R=freq(b98R);
axis([1.1*b98L 1.1*b98R -inf inf]);

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

%% 滤波器自动设计函数
function [bz,az]=LPdesign(fp,fs,Fs)
%数字低通滤波器自动设计:IIR，巴特沃斯，双线性变换
%fp:3dB衰减频率(Hz)  fs:20dB衰减频率(Hz)  Fs:整个数字系统的采样率
%输出z变换下的有理传递函数的分子系数数组bz和分母系数数组az，可用于filter函数
%阶数非常高时不保证效果
rp=3;rs=20; %3dB和20dB;在fp和fs处的衰减

%后面不用管
wp=2*pi*fp/Fs;% 2Pi - Fs —> 100hz - 0.1Fs*2Pi=0.2Pi 
ws=2*pi*fs/Fs; 
Fs1=1; % let Fs=1 
% Firstly to finish frequency prewarping ; 
wap=tan(wp/2);was=tan(ws/2); %求Ωp，Ωs 
[n,wn]=buttord(wap,was,rp,rs,'s'); %n:滤波器阶数, wn:buttord算出的自然截至频率，一般>wp 
disp(['设计得到滤波器阶数:',num2str(n)]);
% Note: 's'! 
[z,p,k]=buttap(n); %极点，零点，增益 

%a是分母，b是分子
[bp,ap]=zp2tf(z,p,k); %G(p)的分子，分母多项式系数 G(p)=1/p^2+√(n)*p+1 
[bs,as]=lp2lp(bp,ap,wap); %G(s)=G(p)|p=s/Ωp 
% Note: s=(2/Ts)(z-1)/(z+1);Ts=1,that is 2fs=1,fs=0.5; 
[bz,az]=bilinear(bs,as,Fs1/2); %H(z) = G(s)|s=z-1/z+1 
% [h,w]=freqz(bz,az,Fs,Fs); 
% plot(w,abs(h));grid on;
end