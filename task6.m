%问题一：用双线性变换法设计巴特沃斯数字低通滤波器
figure(1);
% 确定数字滤波器设计指标
wp = 0.2*pi; Rp = 1;      % 通带截止频率和通带最大衰减(dB)
ws = 0.35*pi; As = 15;    % 阻带截止频率和阻带最小衰减(dB)
Fs = 10; T = 1/Fs;        % 采样频率和采样间隔
ripple = 10^(-Rp/20);     % 通带衰减对应的幅度值
Attn = 10^(-As/20);       % 阻带衰减对应的幅度值


% 双线性变换公式：Omega = (2/T) * tan(omega/2)
Omgp = (2/T)*tan(wp/2);   % 模拟通带截止频率
Omgs = (2/T)*tan(ws/2);   % 模拟阻带截止频率


% 计算巴特沃斯滤波器的阶数 N 和 3dB 截止频率 Omgc
[n,Omgc] = buttord(Omgp,Omgs,Rp,As,'s');

% 设计归一化巴特沃斯模拟低通原型滤波器
[z0,p0,k0] = buttap(n);   % 获取零点、极点和增益
ba1 = k0*real(poly(z0));  % 求原型滤波器分子系数
aa1 = real(poly(p0));     % 求原型滤波器分母系数

% 模拟域频率变换
% 将归一化低通原型去归一化，转换为实际截止频率的模拟低通滤波器
[ba,aa] = lp2lp(ba1,aa1,Omgc);

% 双线性变换
% 将模拟滤波器系统函数转换成数字滤波器系统函数 H(z)
[bd,ad] = bilinear(ba,aa,Fs);

%结果分析与绘图
[H,w] = freqz(bd,ad);     % 求数字系统的频率特性
dbH = 20*log10((abs(H)+eps)/max(abs(H))); % 计算幅度响应(dB)

subplot(221);plot(w/pi,abs(H));
ylabel('|H|');title('幅度响应');axis([0,1,0,1.1]);
set(gca,'XTickMode','manual','XTick',[0,0.2,0.35,1]);
set(gca,'YTickMode','manual','YTick',[0,Attn,ripple,1]);grid on;

subplot(222);plot(w/pi,angle(H)/pi);
ylabel('\phi');title('相位响应');axis([0,1,-1,1]);
set(gca,'XTickMode','manual','XTick',[0,0.2,0.35,1]);
set(gca,'YTickMode','manual','YTick',[-1,0,1]);grid on;

subplot(223);plot(w/pi,dbH);title('幅度响应（dB）');
ylabel('dB');xlabel('频率（\pi）');axis([0,1,-40,5]);
set(gca,'XTickMode','manual','XTick',[0,0.2,0.35,1]);
set(gca,'YTickMode','manual','YTick',[-50,-15,-1,0]);grid on;

subplot(224);zplane(bd,ad); % 绘制零极点图判断稳定性
axis([-1.1,1.1,-1.1,1.1]);title('零极图');

%问题二：对实际心电图信号进行滤波处理
% 定义心电图采样序列 (输入信号)
xn=[-4,-2,0,-4,-6,-4,-2,-4-6-6,-4,-4,-6,-6,-2,6,12,8,...
    0,-16,-38,-60,-84,-90,-66,-32,-4,-2,-4,8,12,12,10,6,6,6,...
	4,0,0,0,0,0,-2,-4,0,0,0,-2,-2,0,0,-2,-2,-2,-2,0];

% 使用问题一设计好的滤波器系数 [bd, ad] 对 xn 进行滤波
yn = filter(bd,ad,xn);

% 计算滤波前后的频谱
[Hx,wx] = freqz(xn,1,256,'whole');
[Hy,wy] = freqz(yn,1,256,'whole');

figure(2);
subplot(221);stem(0:length(xn)-1,xn,'.');grid on;title('滤波前');axis([0,60,-100,50]);
subplot(222);plot(wx/pi,abs(Hx));grid on;title('滤波前幅频特性');
subplot(223);stem(0:length(yn)-1,yn,'.');grid on;title('滤波后');axis([0,60,-100,50]);
subplot(224);plot(wy/pi,abs(Hy));grid on;title('滤波后幅频特性');

%问题三：信号的整数倍抽取与抗混叠滤波
[xn,fs] = audioread('motherland.wav'); % 读取音频信号


% --- 直接抽取 (未进行抗混叠滤波) ---
D = 2; % 抽取因子
yn1 = xn(1:D:length(xn));% 每隔D-1个点抽取一次，D = 2
% sound(yn1,fs/D);
% pause(length(yn1)/fs);	

% --- 设计抗混叠低通滤波器 ---
% 截止频率应约为 pi/D，此处 D=2，故截止频率设在 0.5*pi 附近
wp = 0.45*pi; Rp = 1; ws = 0.55*pi; 
As = 30; Fs = 10; T = 1/Fs;
ripple = 10^(-Rp/20);
Attn = 10^(-As/20);

% 频率预畸变
Omgp = (2/T)*tan(wp/2);
Omgs = (2/T)*tan(ws/2);

% 计算模拟原型并转换为数字滤波器
[n,Omgc] = buttord(Omgp,Omgs,Rp,As,'s');
[z0,p0,k0] = buttap(n);
ba1 = k0*real(poly(z0));
aa1 = real(poly(p0));
[ba,aa] = lp2lp(ba1,aa1,Omgc); % 模拟低通变换
[bd,ad] = bilinear(ba,aa,Fs);  % 双线性变换

% --- 抗混叠处理后抽取 ---
yn2 = filter(bd,ad,xn);        % 先低通滤波
yn2 = yn2(1:D:length(yn2));    % 再进行抽取

% --- 频谱分析对比 ---
N = 2048; % FFT点数
Xn = 1/fs*fft(xn(8000:8199),N);       % 原始信号频谱片段
Yn1 = D/fs*fft(yn1(4000:4099),N);     % 直接抽取后的频谱片段
Yn2 = D/fs*fft(yn2(4000:4099),N);     % 抗混叠滤波后抽取的频谱片段
% sound(yn2,fs/D);
% pause(length(yn2)/fs);

figure(3);
subplot(311);plot((0:N/2-1)*fs/N,abs(Xn(1:N/2)));xlabel('f(Hz)');title('信号模拟域幅度谱');
subplot(312);plot((0:N/2-1)*fs/(N*D),abs(Yn1(1:N/2)));xlabel('f(Hz)');title('D=2抽取后的信号模拟域幅度谱');
subplot(313);plot((0:N/2-1)*fs/(N*D),abs(Yn2(1:N/2)));xlabel('f(Hz)');title('抗混叠处理后D=2抽取的信号模拟域幅度谱');
ylim([0,4*10^(-4)]);

%思考题：设计四种选频数字滤波器
% --- 1. 低通滤波器 ---
figure('name','低通滤波器');
% 设定低通指标
wp = 0.2*pi; Rp = 1; ws = 0.3*pi; 
As = 20; Fs = 10; T = 1/Fs;
ripple = 10^(-Rp/20);
Attn = 10^(-As/20);
% 预畸变
Omgp = (2/T)*tan(wp/2);
Omgs = (2/T)*tan(ws/2);
% 计算模拟原型参数并变换
[n,Omgc] = buttord(Omgp,Omgs,Rp,As,'s');
[z0,p0,k0] = buttap(n);
ba1 = k0*real(poly(z0));
aa1 = real(poly(p0));
[ba,aa] = lp2lp(ba1,aa1,Omgc); % 模拟低通 -> 模拟低通
[bd,ad] = bilinear(ba,aa,Fs);  % 双线性变换 -> 数字低通
% 绘图
[H,w] = freqz(bd,ad);
dbH = 20*log10((abs(H)+eps)/max(abs(H)));
subplot(221);plot(w/pi,abs(H));
ylabel('|H|');title('幅度响应');axis([0,1,0,1.1]);
set(gca,'XTickMode','manual','XTick',[0,0.2,0.3,1]);
set(gca,'YTickMode','manual','YTick',[0,Attn,ripple,1]);grid on;
subplot(222);plot(w/pi,angle(H)/pi);
ylabel('\phi');title('相位响应');axis([0,1,-1,1]);
set(gca,'XTickMode','manual','XTick',[0,0.2,0.3,1]);
set(gca,'YTickMode','manual','YTick',[-1,0,1]);grid on;
subplot(223);plot(w/pi,dbH);title('幅度响应（dB）');
ylabel('dB');xlabel('频率（\pi）');axis([0,1,-40,5]);
set(gca,'XTickMode','manual','XTick',[0,0.2,0.3,1]);
set(gca,'YTickMode','manual','YTick',[-50,-20,-1,0]);grid on;
subplot(224);zplane(bd,ad);
axis([-1.1,1.1,-1.1,1.1]);title('零极图')

% --- 2. 高通滤波器 ---
figure('name','高通滤波器');
% 设定高通指标
wp = 0.6*pi; Rp = 2; ws = 0.4*pi; 
As = 30; Fs = 10; T = 1/Fs;
ripple = 10^(-Rp/20);
Attn = 10^(-As/20);
% 预畸变
Omgp = (2/T)*tan(wp/2);
Omgs = (2/T)*tan(ws/2);
% 计算模拟原型参数
[n,Omgc] = buttord(Omgp,Omgs,Rp,As,'s');
% 直接设计模拟高通滤波器 (模拟低通 -> 模拟高通)
[ba,aa] = butter(n,Omgc,'high','s');
[bd,ad] = bilinear(ba,aa,Fs); % 双线性变换 -> 数字高通
% 绘图
[H,w] = freqz(bd,ad);
dbH = 20*log10((abs(H)+eps)/max(abs(H)));
subplot(221);plot(w/pi,abs(H));
ylabel('|H|');title('幅度响应');axis([0,1,0,1.1]);
set(gca,'XTickMode','manual','XTick',[0,0.4,0.6,1]);
set(gca,'YTickMode','manual','YTick',[0,Attn,ripple,1]);grid on;
subplot(222);plot(w/pi,angle(H)/pi);
ylabel('\phi');title('相位响应');axis([0,1,-1,1]);
set(gca,'XTickMode','manual','XTick',[0,0.4,0.6,1]);
set(gca,'YTickMode','manual','YTick',[-1,0,1]);grid on;
subplot(223);plot(w/pi,dbH);title('幅度响应（dB）');
ylabel('dB');xlabel('频率（\pi）');axis([0,1,-40,5]);
set(gca,'XTickMode','manual','XTick',[0,0.4,0.6,1]);
set(gca,'YTickMode','manual','YTick',[-50,-30,-2,0]);grid on;
subplot(224);zplane(bd,ad);
axis([-1.1,1.1,-1.1,1.1]);title('零极图')

% --- 3. 带通滤波器 ---
figure('name','带通滤波器');
% 设定带通指标 (wp, ws 为向量)
wp = [0.2*pi,0.6*pi]; Rp = 1; ws = [0.15*pi,0.65*pi]; 
As = 45; Fs = 10; T = 1/Fs;
ripple = 10^(-Rp/20);
Attn = 10^(-As/20);
% 预畸变
Omgp = (2/T)*tan(wp/2);
Omgs = (2/T)*tan(ws/2);
% 计算模拟原型参数
[n,Omgc] = buttord(Omgp,Omgs,Rp,As,'s');
% 直接设计模拟带通滤波器 (模拟低通 -> 模拟带通)
[ba,aa] = butter(n,Omgc,'bandpass','s');
[bd,ad] = bilinear(ba,aa,Fs); % 双线性变换 -> 数字带通
% 绘图
[H,w] = freqz(bd,ad);
dbH = 20*log10((abs(H)+eps)/max(abs(H)));
subplot(221);plot(w/pi,abs(H));
ylabel('|H|');title('幅度响应');axis([0,1,0,1.1]);
set(gca,'XTickMode','manual','XTick',[0,0.15,0.2,0.6,0.65,1]);
set(gca,'YTickMode','manual','YTick',[0,Attn,ripple,1]);grid on;
subplot(222);plot(w/pi,angle(H)/pi);
ylabel('\phi');title('相位响应');axis([0,1,-1,1]);
set(gca,'XTickMode','manual','XTick',[0,0.15,0.2,0.6,0.65,1]);
set(gca,'YTickMode','manual','YTick',[-1,0,1]);grid on;
subplot(223);plot(w/pi,dbH);title('幅度响应（dB）');
ylabel('dB');xlabel('频率（\pi）');axis([0,1,-50,5]);
set(gca,'XTickMode','manual','XTick',[0,0.15,0.2,0.6,0.65,1]);
set(gca,'YTickMode','manual','YTick',[-50,-45,-1,0]);grid on;
subplot(224);zplane(bd,ad);
axis([-1.1,1.1,-1.1,1.1]);title('零极图')

% --- 4. 带阻滤波器 ---
figure('name','带阻滤波器');
% 设定带阻指标
wp = [0.15*pi,0.65*pi]; Rp = 1; ws = [0.2*pi,0.6*pi]; 
As = 45; Fs = 10; T = 1/Fs;
ripple = 10^(-Rp/20);
Attn = 10^(-As/20);
% 预畸变
Omgp = (2/T)*tan(wp/2);
Omgs = (2/T)*tan(ws/2);
% 计算模拟原型参数
[n,Omgc] = buttord(Omgp,Omgs,Rp,As,'s');
% 直接设计模拟带阻滤波器 (模拟低通 -> 模拟带阻)
[ba,aa] = butter(n,Omgc,'stop','s');
[bd,ad] = bilinear(ba,aa,Fs); % 双线性变换 -> 数字带阻
% 绘图
[H,w] = freqz(bd,ad);
dbH = 20*log10((abs(H)+eps)/max(abs(H)));
subplot(221);plot(w/pi,abs(H));
ylabel('|H|');title('幅度响应');axis([0,1,0,1.1]);
set(gca,'XTickMode','manual','XTick',[0,0.15,0.2,0.6,0.65,1]);
set(gca,'YTickMode','manual','YTick',[0,Attn,ripple,1]);grid on;
subplot(222);plot(w/pi,angle(H)/pi);
ylabel('\phi');title('相位响应');axis([0,1,-1,1]);
set(gca,'XTickMode','manual','XTick',[0,0.15,0.2,0.6,0.65,1]);
set(gca,'YTickMode','manual','YTick',[-1,0,1]);grid on;
subplot(223);plot(w/pi,dbH);title('幅度响应（dB）');
ylabel('dB');xlabel('频率（\pi）');axis([0,1,-50,5]);
set(gca,'XTickMode','manual','XTick',[0,0.15,0.2,0.6,0.65,1]);
set(gca,'YTickMode','manual','YTick',[-50,-45,-1,0]);grid on;
subplot(224);zplane(bd,ad);
axis([-1.1,1.1,-1.1,1.1]);title('零极图');