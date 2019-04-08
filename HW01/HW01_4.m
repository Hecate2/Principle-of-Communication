clear
%Zadoff-Chu series

%(1)
%alpha=[1,20,1232,3,235,76323,23,243,123];
alpha=sin(0:0.1:2*pi);
N=length(alpha);
if(mod(N,2)==0) %N为偶数
    M=N-1;  %M只要与N互质
    k=0:1:N-1;
    a=exp(1i*M*pi*k.^2/N);
else %N为奇数
    M=N-1; %M只要与N互质
    k=0:1:N-1;
    kk=1:1:N; %作为k+1使用
    a=exp(1i*M*pi*(k.*kk)/N);
end

x=zeros(1,N);
x(1)=sum(a.*conj(a));
for j=1:1:N-1
    for k=0:1:N-j-1
        x(j+1)=x(j+1)+a(k+1)*conj(a(k+j+1));
    end
    for k=N-j:1:N-1
        x(j+1)=x(j+1)+a(k+1)*conj(a(k+j-N+1));
    end
end
figure
stem(abs(x));
title('序列的自相关和循环自相关');

%(2)
alpha=sin(0:0.1:2*pi);%sin(t)功率为pi
figure
stem(alpha);
title('加噪声前的正弦序列');
N=length(alpha);
SNR=5;  %信噪比，单位为dB
SNR=10^(SNR/10); %信噪比倍数
noise=(normrnd(0,1/2/SNR,[1 N])+1i*normrnd(0,1/2/SNR,[1 N]))*pi; %产生噪声
alpha=alpha+noise;
figure
stem(real(alpha));
title('加噪声后的正弦序列（仅实部）');

if(mod(N,2)==0) %N为偶数
    M=N-1;  %M只要与N互质
    k=0:1:N-1;
    a=exp(1i*M*pi*k.^2/N);
else %N为奇数
    M=N-1; %M只要与N互质
    k=0:1:N-1;
    kk=1:1:N; %作为k+1使用
    a=exp(1i*M*pi*(k.*kk)/N);
end

x=zeros(1,N);
x(1)=sum(a.*conj(a));
for j=1:1:N-1
    for k=0:1:N-j-1
        x(j+1)=x(j+1)+a(k+1)*conj(a(k+j+1));
    end
    for k=N-j:1:N-1
        x(j+1)=x(j+1)+a(k+1)*conj(a(k+j-N+1));
    end
end
figure
stem(abs(x));
title('加噪声后序列的自相关和循环自相关');
