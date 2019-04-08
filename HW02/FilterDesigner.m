%���ֵ�ͨ�˲����Զ����:IIR��������˹��˫���Ա任
%�����ǳ���ʱ����֤Ч��
clear; 
close all; 

fp=500;fs=1700;%��fp��˥��3dB����fs��˥��20dB
Fs=100000; %����ϵͳ������(Hz)
rp=3;rs=20; %3dB��20dB;��fp��fs����˥��

%���治�ù�
wp=2*pi*fp/Fs;% 2Pi - Fs ��> 100hz - 0.1Fs*2Pi=0.2Pi 
ws=2*pi*fs/Fs; 
Fs1=1; % let Fs=1 
% Firstly to finish frequency prewarping ; 
wap=tan(wp/2);was=tan(ws/2); %��p����s 
[n,wn]=buttord(wap,was,rp,rs,'s') %n:�˲�������, wn:buttord�������Ȼ����Ƶ�ʣ�һ��>wp 
% Note: 's'! 
[z,p,k]=buttap(n); %���㣬��㣬���� 

%a�Ƿ�ĸ��b�Ƿ���
[bp,ap]=zp2tf(z,p,k) %G(p)�ķ��ӣ���ĸ����ʽϵ�� G(p)=1/p^2+��(n)*p+1 
[bs,as]=lp2lp(bp,ap,wap) %G(s)=G(p)|p=s/��p 
% Note: s=(2/Ts)(z-1)/(z+1);Ts=1,that is 2fs=1,fs=0.5; 
[bz,az]=bilinear(bs,as,Fs1/2) %H(z) = G(s)|s=z-1/z+1 
[h,w]=freqz(bz,az,Fs,Fs); 
plot(w,abs(h));grid on;
