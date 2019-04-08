clear

%ϰ��2
%(1)
Tw=1;
fm=10;
Ts=0.001;
t=0:Ts:Tw;
x=cos(2*pi*fm*t);
figure;
plot(t,x);
axis([-0.5,Tw+0.5,-1.1,1.1]);
title('x_T_w(t)��ʱ����');

%(2)
X=fft(x);
f=0:1:length(X)-1;
figure;
plot(f,real(X));
hold on
plot(f,imag(X));
title(['x_T_w(t)��FFT���,Ts=',num2str(Ts)]);
legend('ʵ������','��������');
figure
plot(f,abs(X).^2);
title(['x_T_w(t)��������,Ts=',num2str(Ts)])

%(3)
Tw=1;
fm=10;
for Ts=[0.002,0.005,0.01,0.2]
    t=0:Ts:Tw;
    x=cos(2*pi*fm*t);
    X=fft(x);
    f=0:1:length(X)-1;
    figure;
    plot(f,real(X));
    hold on
    plot(f,imag(X));
    %hold on
    legend(['ʵ������,Ts=',num2str(Ts)],['��������,Ts=',num2str(Ts)]);
    title(['x_T_w(t)��FFT���,Ts=',num2str(Ts),',Tw=',num2str(Tw)]);
    figure
    plot(f,abs(X).^2);
    title(['x_T_w(t)��������,Ts=',num2str(Ts),',Tw=',num2str(Tw)])
end

%(4)
fm=10;
Ts=0.01;
for Tw=[2,5,10,20]
    t=0:Ts:Tw;
    x=cos(2*pi*fm*t);    
    X=fft(x);
    f=0:1:length(X)-1;
    figure;
    plot(f,real(X));
    hold on
    plot(f,imag(X));
    %hold on
    legend(['ʵ������,Ts=',num2str(Ts)],['��������,Ts=',num2str(Ts)]);
    title(['x_T_w(t)��FFT���,Ts=',num2str(Ts),',Tw=',num2str(Tw)]);
    figure
    plot(f,abs(X).^2);
    title(['x_T_w(t)��������,Ts=',num2str(Ts),',Tw=',num2str(Tw)])
end