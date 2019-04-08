%数字低通滤波器自动设计:IIR，巴特沃斯，双线性变换
%阶数非常高时不保证效果
clear; 
close all; 

fp=500;fs=1700;%在fp处衰减3dB，在fs处衰减20dB
Fs=100000; %数字系统采样率(Hz)
rp=3;rs=20; %3dB和20dB;在fp和fs处的衰减

%后面不用管
wp=2*pi*fp/Fs;% 2Pi - Fs —> 100hz - 0.1Fs*2Pi=0.2Pi 
ws=2*pi*fs/Fs; 
Fs1=1; % let Fs=1 
% Firstly to finish frequency prewarping ; 
wap=tan(wp/2);was=tan(ws/2); %求Ωp，Ωs 
[n,wn]=buttord(wap,was,rp,rs,'s') %n:滤波器阶数, wn:buttord算出的自然截至频率，一般>wp 
% Note: 's'! 
[z,p,k]=buttap(n); %极点，零点，增益 

%a是分母，b是分子
[bp,ap]=zp2tf(z,p,k) %G(p)的分子，分母多项式系数 G(p)=1/p^2+√(n)*p+1 
[bs,as]=lp2lp(bp,ap,wap) %G(s)=G(p)|p=s/Ωp 
% Note: s=(2/Ts)(z-1)/(z+1);Ts=1,that is 2fs=1,fs=0.5; 
[bz,az]=bilinear(bs,as,Fs1/2) %H(z) = G(s)|s=z-1/z+1 
[h,w]=freqz(bz,az,Fs,Fs); 
plot(w,abs(h));grid on;
