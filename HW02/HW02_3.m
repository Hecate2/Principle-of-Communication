clear
close all

Fs=10000000;    %采样（观测）频率
Ts=1/Fs;
tx=0:Ts:0.0005;
tin=cos(2*pi*1000*tx);

carrierFreq=1000000;
kfList=[50 100 200 500 1000];%不够大的话在时域波形上几乎看不出什么东西
for kf=kfList
    tout=FMmodu(tin,tx,kf,carrierFreq);%载波频率1MHz
    figure
    plot(tx,tout);
    hold on
    plot(tx,tin);
    title(['FM调制的时域波形,K_f=',num2str(kf)]);
    legend('调制结果','调制波形');
    figure
    [spec,freq]=freqSpec(tout,Fs);
    plot(freq,spec);
    title(['FM调制的频谱,K_f=',num2str(kf)]);
    hold on
    %求98%带宽
    [b98L,b98R]=percentBand(abs(spec).^2,0.98);
    b98L=freq(b98L);b98R=freq(b98R);
    max_y=1.1*max(spec);    min_y=1.1*min(spec);
    plot([b98L b98L],[min_y max_y]);   hold on;    plot([b98R b98R],[min_y max_y]);   hold on;
    %axis([1.1*b98L 1.1*b98R -inf inf]);
    legend('频谱','98%带宽范围');
    mf=kf*max(abs(tin))/carrierFreq;
    B_fm=2*(mf+1)*carrierFreq
end
disp('B_fm验证Carson公式')


%% FM调制函数
function tout=FMmodu(tin,tx,kf,carrierFreq,carrierPhase)
%输入时域波形，时域x轴，调频灵敏度kf，载波频率(Hz)，载波初始相位(rad)(默认0)
if nargin<5
    carrierPhase=0;
end
dt=diff(tx);
dt=[dt sum(dt)/length(dt)];
tin=kf*cumsum(tin.*dt);
tout=cos(2*pi*carrierFreq*tx+tin+carrierPhase);
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
