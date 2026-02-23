clc;       
clearvars;  
close all;   
% --- 问题一：时域采样定理 ---
fs = 1024; fs1 = 1000;fs2 = 300;fs3 = 200;
Ts = 1/fs;
Ts1 = 1/fs1;Ts2 = 1/fs2;Ts3 = 1/fs3;
Tp = 0.064;
t = 0:Ts:0.05;
n = 0:1023;
N1 = round(Tp*fs1); 
N2 = round(Tp*fs2); 
N3 = round(Tp*fs3); 
n1 = 0:N1-1; n2 = 0:N2-1; n3 = 0:N3-1;
xn = 444.128.*exp(-50.*sqrt(2).*pi.*t).*sin(50.*sqrt(2).*pi.*t);
x1n = 444.128.*exp(-50.*sqrt(2).*pi.*n1.*Ts1).*sin(50.*sqrt(2).*pi.*n1.*Ts1);
x2n = 444.128.*exp(-50.*sqrt(2).*pi.*n2.*Ts2).*sin(50.*sqrt(2).*pi.*n2.*Ts2);
x3n = 444.128.*exp(-50.*sqrt(2).*pi.*n3.*Ts3).*sin(50.*sqrt(2).*pi.*n3.*Ts3);
Y = fft(xn,1024); y = Ts*Y; Ym = abs(y);

figure(1);
subplot(211);plot(t,xn);title('原信号');
subplot(212);plot(n(1:512)./(20*Tp),Ym(1:512));title('原信号幅频特性');xlabel('f(Hz)');ylabel('幅度');


Y1 = fft(x1n,N1); Y2 = fft(x2n,N2);Y3 = fft(x3n,N3);%计算抽样信号的DFT
y1 = Ts1.*Y1;     y2 = Ts2.*Y2;    y3 = Ts3.*Y3;

figure(2); 
sgtitle('时域采样及其频谱'); 

subplot(3, 2, 1);
stem(0:length(x1n)-1,x1n,'fill');title('fs=1000hz (时域)');
ylabel('幅度');

subplot(3, 2, 3);
stem(0:length(x2n)-1,x2n,'fill');title('fs=300hz (时域)');
ylabel('幅度');

subplot(3, 2, 5);
stem(0:length(x3n)-1,x3n,'fill');title('fs=200hz (时域)');
xlabel('n (采样点)');
ylabel('幅度');


subplot(3, 2, 2);
plot(n1./Tp,abs(y1));title('T*FT[xa(nt)],fs=1000hz (频域)');
xlabel('f(Hz)');ylabel('幅度');axis([0 1000 0 1]);

subplot(3, 2, 4);
plot(n2./Tp,abs(y2));title('T*FT[xa(nt)],fs=300hz (频域)');
xlabel('f(Hz)');ylabel('幅度');axis([0 300 0 1]);

subplot(3, 2, 6);
plot(n3./Tp,abs(y3));title('T*FT[xa(nt)],fs=200hz (频域)');
xlabel('f(Hz)');ylabel('幅度');axis([0 200 0 1]);
%原信号的带宽是无限的，因此无论进行多大频率的采样，其最后恢复的幅频特性曲线也会失真，特别是在折叠频率Fs/2的地方失真最严重，
% 也就是在500Hz、150Hz和100Hz的地方，而工程上总是在A/D转换之前加一个预滤波器，从而滤除掉折叠频率Fs/2的频率。

% --- 问题二：频域采样定理 ---
x = [1:14,13:-1:1];
DFTx = fft(x,512);  DFTx_16 = DFTx(1:512/16:512);  DFTx_32 = DFTx(1:512/32:512);
x_16 = ifft(DFTx_16);   x_32 = ifft(DFTx_32);

figure(3); 
subplot(321);plot(0:2*pi/511:2*pi,abs(DFTx));xlabel('\omega');ylabel('|X(e^{j\omega})|');title('FT[x(n)]');
subplot(322);stem(0:length(x)-1,x,'fill');xlabel('n'),ylabel('x(n)'),title('三角波序列x(n)')
subplot(323);stem(0:length(DFTx_16)-1,abs(DFTx_16),'fill');xlabel('k');ylabel('|X_{16}(k)|');title('16点频域采样');
subplot(324);stem(0:length(x_16)-1,x_16,'fill');xlabel('n');ylabel('|X_{16}(n)|');title('16点IDFT[X_{16}(k)]')
subplot(325);stem(0:length(DFTx_32)-1,abs(DFTx_32),'fill');xlabel('k');ylabel('|X_{32}(k)|');title('32点频域采样');
subplot(326);stem(0:length(x_32)-1,x_32,'fill');axis([0 32 0 20]);xlabel('n');ylabel('|X_{32}(n)|');title('32点IDFT[X_{32}(k)]');
%由于原信号长度为27，当进行16点DFT时即（N<M）不满足频域采样条件，因此此时IDFT恢复不出原信号的样子；
% 而如果进行32点DFT时是满足频域采样条件的，因此此时是可以恢复出原信号的样子，而且多余的位置需要进行补零处理。
% %16点频域采样时，小于序列原本的长度，因此得到的不是原本的序列。

% --- 问题三：音频处理 ---
[y,fs]=audioread('motherland.wav');
y1=y(1000:2999);
N=2048;
Yk=fft(y1,N);
x_axis=0:N-1; 
figure(4); 
subplot(211)
plot(2*x_axis/N,abs(Yk))
xlabel('\omega/\pi');title('2000 采样点幅频曲线');
y2=y1(1:2:end); 
Yk2=fft(y2,N);
subplot(212)
plot(2*x_axis/N,abs(Yk2))
xlabel('\omega/\pi');title('1000 采样点幅频曲线（时域抽取）');
%可以看到我们是对原信号分别进行2000采样点和1000采样点进行采样，采样点数减少为了原先的一半，造成频率混叠。

% 思考题
% 1.如果序列x(n)的长度为M，希望得到其频谱X(ejw)在[0,2π)上的N点等间隔采样，当N<M，如何使用一次最少点数的DFT得到该频谱采样？
% 需要对于原序列进行周期延拓后取主值序列。
% 首先对于x(n)按照周期为N进行周期延拓，原序列x（(n)左右平移N点后与原序列叠加。然后对于得到的延拓序列取主值序列，就是需要进行变换的N点长序列
% 然后对于得到的N点长混叠序列xn(n)做N点的DFT获得N点长的频谱采样X(K)


% 2.对采样后的语音信号，每2个样点抽取1点，语音信号会发生频谱混叠吗？如果会发生频谱混叠，原因是什么？以实验内容3.3为例进行说明。
% 答：会发生频谱混叠，因为此时的采样点数减少为原先的一半，也就是说采样频率fs也变为了原先的一半，从而不满足频率采样的条件，从而造成频谱混叠。
% 3.3中，我们选取了奇数项和偶数项，在进行FFT时，N也从原先的2000变成了1000，导致fs减小，从而产生混叠。