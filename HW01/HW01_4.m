clear
%Zadoff-Chu series

%(1)
%alpha=[1,20,1232,3,235,76323,23,243,123];
alpha=sin(0:0.1:2*pi);
N=length(alpha);
if(mod(N,2)==0) %NΪż��
    M=N-1;  %MֻҪ��N����
    k=0:1:N-1;
    a=exp(1i*M*pi*k.^2/N);
else %NΪ����
    M=N-1; %MֻҪ��N����
    k=0:1:N-1;
    kk=1:1:N; %��Ϊk+1ʹ��
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
title('���е�����غ�ѭ�������');

%(2)
alpha=sin(0:0.1:2*pi);%sin(t)����Ϊpi
figure
stem(alpha);
title('������ǰ����������');
N=length(alpha);
SNR=5;  %����ȣ���λΪdB
SNR=10^(SNR/10); %����ȱ���
noise=(normrnd(0,1/2/SNR,[1 N])+1i*normrnd(0,1/2/SNR,[1 N]))*pi; %��������
alpha=alpha+noise;
figure
stem(real(alpha));
title('����������������У���ʵ����');

if(mod(N,2)==0) %NΪż��
    M=N-1;  %MֻҪ��N����
    k=0:1:N-1;
    a=exp(1i*M*pi*k.^2/N);
else %NΪ����
    M=N-1; %MֻҪ��N����
    k=0:1:N-1;
    kk=1:1:N; %��Ϊk+1ʹ��
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
title('�����������е�����غ�ѭ�������');
