%%
clear

[x,y]=meshgrid(-4:0.1:4,-4:0.1:4);%��ͼ��Χ�Ͳ���
rho=0;
ux=0;sx=1;%��ֵ����
uy=0;sy=1;
z=exp((((x-ux)/sx).^2-2*rho*(x-ux)*(y-uy)/(sx*sy)+((y-uy)/sy).^2)/(-2*(1-rho^2)))...
    /(2*pi*sx*sy*sqrt(1-rho^2));
figure
surf(x,y,z);

%%
clear

[x,y]=meshgrid(-4:0.1:4,-4:0.1:4);%��ͼ��Χ�Ͳ���
rho=0;
ux=1;sx=2;%��ֵ����
uy=1;sy=2;
z=exp((((x-ux)/sx).^2-2*rho*(x-ux)*(y-uy)/(sx*sy)+((y-uy)/sy).^2)/(-2*(1-rho^2)))...
    /(2*pi*sx*sy*sqrt(1-rho^2));
figure
surf(x,y,z);

%%
clear

[x,y]=meshgrid(-4:0.1:4,-4:0.1:4);%��ͼ��Χ�Ͳ���
rho=0.9;
ux=0;sx=1;%��ֵ����
uy=0;sy=1;
z=exp((((x-ux)/sx).^2-2*rho.*(x-ux).*(y-uy)/(sx*sy)+((y-uy)/sy).^2)/(-2*(1-rho^2)))...
    /(2*pi*sx*sy*sqrt(1-rho^2));
figure
surf(x,y,z);
