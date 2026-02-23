%问题2：利用窗函数法设计FIR低通滤波器
% 指标要求：通带截止频率0.24pi，阻带截止频率0.3pi，阻带衰减>60dB
wp = 0.24*pi;ws = 0.3*pi;
deltaw = ws-wp;                 % 计算过渡带宽
N0 = ceil(11*pi/deltaw);        % 根据布莱克曼窗的近似过渡带宽公式(11pi/N)估算阶数
N = N0+mod(N0+1,2);             % 确保N为奇数（保证是第一类线性相位FIR滤波器，关于中心偶对称）
windows = (blackman(N))';       % 生成布莱克曼窗（Blackman），旁瓣衰减可达74dB，满足60dB要求
wc = (ws+wp)/2;                 % 截止频率取通带和阻带的平均值
hd = ideal_lp(wc,N);            % 调用自定义函数计算理想低通滤波器的单位脉冲响应
b = hd.*windows;                % 时域相乘（加窗），获得实际FIR滤波器系数
[H,w] = freqz(b,1,1000,'whole');% 计算频率响应，H为复数频率响应，w为频率点
H = (H(1:501))';w = (w(1:501))';% 取0到pi的部分（对应0到fs/2）
mag = abs(H);                   % 计算幅频响应的模
db = 20*log10((mag+eps)/max(mag)); % 转换为分贝(dB)表示，归一化最大值为0dB
pha = angle(H);                 % 计算相频响应
n = 0:N-1;dw = 2*pi/1000;       % 定义频率分辨率
Rp = -(min(db(1:int32(wp/dw+1))));    % 计算通带最大波纹（校验指标）
As = -round(max(db(ws/dw+1:501)));    % 计算阻带最小衰减（校验指标）

% 绘图显示结果
figure('name','问题2');
subplot(221);stem(n,b);axis([0,N,1.1*min(b),1.1*max(b)]);title('实际脉冲响应');xlabel('n');ylabel('h(n)');
subplot(222);stem(n,windows);axis([0,N,0,1.1]);title('窗函数特性');xlabel('n');ylabel('wd(n)');
subplot(223);plot(w/pi,db);axis([0,1,-100,10]);title('幅度频率响应');xlabel('频率(\pi)');ylabel('H(e^{j\omega})');
set(gca,'XTickMode','manual','XTick',[0,wp/pi,ws/pi,1]); % 手动设置X轴刻度以便观察截止频率
set(gca,'YTickMode','manual','YTick',[-60,-20,-3,0]);grid on;
subplot(224);plot(w/pi,pha);axis([0,1,-4,4]);title('相位频率响应');xlabel('频率(\pi)');ylabel('\phi(\omega)');
set(gca,'XTickMode','manual','XTick',[0,wp/pi,ws/pi,1]);
set(gca,'YTickMode','manual','YTick',[-3.1416,0,3.1416,4]);grid on;

%%
%问题3：产生含噪信号
figure('name','问题3')
[xt,t] = xtg(1000); % 调用xtg函数产生单频调幅信号加高频噪声，并显示波形和频谱

%%
%问题4：利用设计好的滤波器对信号进行滤波
wp = 0.24*pi;ws = 0.3*pi;deltaw = ws-wp;N0 = ceil(11*pi/deltaw);
N = N0+mod(N0+1,2);
windows = (blackman(N))';wc = (ws+wp)/2;
hd = ideal_lp(wc,N);b = hd.*windows;
[xt,t] = xtg(1000);   % 重新生成信号
yt = fftfilt(b,xt);   % 使用重叠相加法/FFT卷积进行快速滤波
Hyk = abs(fft(yt));   % 计算滤波后信号的频谱幅度

figure(1);
figure('name','问题4')
subplot(211);plot(t,yt); % 绘制滤波后的时域波形（观察噪声是否被滤除）
subplot(212);stem(Hyk);  % 绘制滤波后的频域波形
axis([80,120,min(Hyk),max(Hyk)]); % 放大显示基波分量区域（100Hz载波附近）

%%
%问题5：音频信号的整数倍零值内插与镜像滤波
[xn,fs] = audioread('motherland.wav'); % 读取音频文件
%sound(xn,fs);          % 播放原声
%pause(length(xn)/fs);  % 暂停等待播放结束

I = 2;                  % 内插因子
% 执行整数倍零值内插（在每两个样本间插入一个0）
yn1 = zeros(1, I*length(xn)); % 预分配内存
for i=1:length(xn)
    yn1(I*i-1)=xn(i);
    yn1(I*i) = 0;
end
%sound(yn1,I*fs);       % 播放内插后的声音（会有高频镜像噪声）
%pause(length(yn1)/fs);

% ------------------- 修改部分开始 -------------------
% 设计镜像低通滤波器 (Anti-imaging Filter)
% 目标：截止频率 = 4000Hz。


wp = 0.45*pi;   % 通带截止 (约 3600Hz)
ws = 0.55*pi;   % 阻带截止 (约 4400Hz)
deltaw = ws-wp; 

% 估算阶数 (使用 Blackman 窗)
N0 = ceil(11*pi/deltaw);
N = N0+mod(N0+1,2); % 确保为奇数

% 生成滤波器系数
windows = (blackman(N))';
wc = (ws+wp)/2;     % 截止频率 = 0.5*pi (对应 4000Hz)
hd = ideal_lp(wc,N);
b = hd.*windows;
% ------------------- 修改部分结束 -------------------

N_fft = 2048;           % 设置FFT分析的点数 (变量名改为N_fft避免与阶数N冲突)
yn2 = filter(b,1,yn1);  % 对内插后的信号进行滤波

%sound(yn2,I*fs);       % 播放滤波后的声音（音质应恢复，且高频细节保留更好）
%pause(length(yn2)/fs);

% 计算频谱以便对比
Xn = 1/fs*fft(xn(8000:8199),N_fft);            % 原信号频谱
Yn1 = 1/(I*fs)*fft(yn1(16000:16399),N_fft);    % 内插后信号频谱
Yn2 = 1/(I*fs)*fft(yn2(16000:16399),N_fft);    % 滤波后信号频谱

figure('name','问题5 - 修正截止频率为4000Hz');
subplot(311);plot((0:N_fft/2-1)*fs/N_fft,abs(Xn(1:N_fft/2)));
xlabel('f(Hz)');title('原始信号模拟域幅度谱');

subplot(312);plot((0:N_fft/2-1)*I*fs/N_fft,abs(Yn1(1:N_fft/2)));
xlabel('f(Hz)');title('I=2内插处理后的信号模拟域幅度谱');

subplot(313);plot((0:N_fft/2-1)*I*fs/N_fft,abs(Yn2(1:N_fft/2)));
xlabel('f(Hz)');title('滤波后的信号模拟域幅度谱');

%%
%思考题：设计四种类型的FIR滤波器
% 低通滤波器设计
% 指标：As=24dB，选择Bartlett窗（旁瓣-25dB）
wp = 0.2*pi;ws = 0.3*pi;
deltaw = ws-wp;
N0 = ceil(6.1*pi/deltaw);       % Bartlett窗过渡带系数约为6.1pi
N = N0+mod(N0+1,2);
windows = bartlett(N);          % 生成三角窗
wc =(ws+wp)/2/pi;               % 归一化截止频率（fir1函数要求0-1之间，1对应Nyquist频率）
b = fir1(N-1,wc,windows);       % 使用fir1函数设计滤波器
[H,w] = freqz(b,1,1000,'whole');
H = (H(1:501))';w = (w(1:501))';
mag = abs(H);
db = 20*log10((mag+eps)/max(mag));
pha = angle(H);
n = 0:N-1;dw = 2*pi/1000;
Rp = -(min(db(1:wp/dw+1)));
As = -round(max(db(ws/dw+1:501)));
figure('name','低通')
subplot(221);stem(n,b);axis([0,N,1.1*min(b),1.1*max(b)]);title('实际脉冲响应');xlabel('n');ylabel('h(n)');
subplot(222);stem(n,windows);axis([0,N,0,1.1]);title('窗函数特性');xlabel('n');ylabel('wd(n)');
subplot(223);plot(w/pi,db);axis([0,1,-80,10]);title('幅度频率响应');xlabel('频率(\pi)');ylabel('H(e^{j\omega})');
set(gca,'XTickMode','manual','XTick',[0,wp/pi,ws/pi,1]);
set(gca,'YTickMode','manual','YTick',[-50,-24,-1,0]);grid on;
subplot(224);plot(w/pi,pha);axis([0,1,-4,4]);title('相位频率响应');xlabel('频率(\pi)');ylabel('\phi(\omega)');
set(gca,'XTickMode','manual','XTick',[0,wp/pi,ws/pi,1]);
set(gca,'YTickMode','manual','YTick',[-3.1416,0.3,3.1416,4]);grid on;

% 高通滤波器设计
% 指标：As=43dB，选择Hanning窗（阻带衰减约44dB）
wp = 0.4*pi;ws = 0.6*pi;
deltaw = ws-wp;                 % 注意：此处ws>wp计算的绝对带宽为负，但在阶数计算中只取大小
N0 = ceil(6.2*pi/deltaw);       % Hanning窗过渡带系数约为6.2pi
N = N0+mod(N0+1,2);
windows = hanning(N);           % 生成汉宁窗
wc =(ws+wp)/2/pi;
b = fir1(N-1,wc,'high',windows);% 'high'参数指定为高通
[H,w] = freqz(b,1,1000,'whole');
H = (H(1:501))';w = (w(1:501))';
mag = abs(H);
db = 20*log10((mag+eps)/max(mag));
pha = angle(H);
n = 0:N-1;dw = 2*pi/1000;
Rp = -(min(db(1:wp/dw+1)));
As = -round(max(db(ws/dw+1:501)));
figure('name','高通')
subplot(221);stem(n,b);axis([0,N,1.1*min(b),1.1*max(b)]);title('实际脉冲响应');xlabel('n');ylabel('h(n)');
subplot(222);stem(n,windows);axis([0,N,0,1.1]);title('窗函数特性');xlabel('n');ylabel('wd(n)');
subplot(223);plot(w/pi,db);axis([0,1,-80,10]);title('幅度频率响应');xlabel('频率(\pi)');ylabel('H(e^{j\omega})');
set(gca,'XTickMode','manual','XTick',[0,wp/pi,ws/pi,1]);
set(gca,'YTickMode','manual','YTick',[-50,-43,-0.2,0]);grid on;
subplot(224);plot(w/pi,pha);axis([0,1,-4,4]);title('相位频率响应');xlabel('频率(\pi)');ylabel('\phi(\omega)');
set(gca,'XTickMode','manual','XTick',[0,wp/pi,ws/pi,1]);
set(gca,'YTickMode','manual','YTick',[-3.1416,0.3,3.1416,4]);grid on;

% 带通滤波器设计
% 指标：As=50dB，选择Hamming窗（阻带衰减约53dB）
wlp = 0.2*pi; wup = 0.6*pi;     % 通带边缘
wls = 0.15*pi; wus = 0.65*pi;   % 阻带边缘
B = abs(wls-wlp);               % 过渡带宽度（假设两侧对称）
N0 = ceil(6.6*pi/B);            % Hamming窗过渡带系数约为6.6pi
N = N0+mod(N0+1,2);
windows = hamming(N);           % 生成哈明窗
wc = [(wlp+wls)/2/pi,(wup+wus)/2/pi]; % 截止频率向量[下截止, 上截止]
b = fir1(N-1,wc,'bandpass',windows);  % 'bandpass'指定带通
[H,w] = freqz(b,1,1000,'whole');
H = (H(1:501))';w = (w(1:501))';
mag = abs(H);
db = 20*log10((mag+eps)/max(mag));
pha = angle(H);
n = 0:N-1;dw = 2*pi/1000;
Rp = -(min(db(1:wp/dw+1)));
As = -round(max(db(ws/dw+1:501)));
figure('name','带通')
subplot(221);stem(n,b);axis([0,N,1.1*min(b),1.1*max(b)]);title('实际脉冲响应');xlabel('n');ylabel('h(n)');
subplot(222);stem(n,windows);axis([0,N,0,1.1]);title('窗函数特性');xlabel('n');ylabel('wd(n)');
subplot(223);plot(w/pi,db);axis([0,1,-80,10]);title('幅度频率响应');xlabel('频率(\pi)');ylabel('H(e^{j\omega})');
set(gca,'XTickMode','manual','XTick',[0,wls/pi,wlp/pi,wup/pi,wus/pi,1]);
set(gca,'YTickMode','manual','YTick',[-70,-50,-1,0]);grid on;
subplot(224);plot(w/pi,pha);axis([0,1,-4,4]);title('相位频率响应');xlabel('频率(\pi)');ylabel('\phi(\omega)');
set(gca,'XTickMode','manual','XTick',[0,wls/pi,wlp/pi,wup/pi,wus/pi,1]);
set(gca,'YTickMode','manual','YTick',[-3.1416,0.3,3.1416,4]);grid on;

% 带阻滤波器设计
% 指标：As=45dB，选择Hanning窗（近似满足）或Hamming窗
wlp = 0.2*pi; wup = 0.6*pi;
wls = 0.15*pi; wus = 0.65*pi;
B = abs(wls-wlp); 
N0 = ceil(6.6*pi/B);            % 此处使用6.6pi系数，暗示使用Hamming窗的特性，但下面代码用了hanning
N = N0+mod(N0+1,2);
windows = hanning(N);           % 生成汉宁窗
wc = [(wlp+wls)/2/pi,(wup+wus)/2/pi];
b = fir1(N-1,wc,'stop',windows);% 'stop'指定带阻
[H,w] = freqz(b,1,1000,'whole');
H = (H(1:501))';w = (w(1:501))';
mag = abs(H);
db = 20*log10((mag+eps)/max(mag));
pha = angle(H);
n = 0:N-1;dw = 2*pi/1000;
Rp = -(min(db(1:wp/dw+1)));
As = -round(max(db(ws/dw+1:501)));
figure('name','带阻')
subplot(221);stem(n,b);axis([0,N,1.1*min(b),1.1*max(b)]);title('实际脉冲响应');xlabel('n');ylabel('h(n)');
subplot(222);stem(n,windows);axis([0,N,0,1.1]);title('窗函数特性');xlabel('n');ylabel('wd(n)');
subplot(223);plot(w/pi,db);axis([0,1,-80,10]);title('幅度频率响应');xlabel('频率(\pi)');ylabel('H(e^{j\omega})');
set(gca,'XTickMode','manual','XTick',[0,wls/pi,wlp/pi,wup/pi,wus/pi,1]);
set(gca,'YTickMode','manual','YTick',[-50,-45,-1,0]);grid on;
subplot(224);plot(w/pi,pha);axis([0,1,-4,4]);title('相位频率响应');xlabel('频率(\pi)');ylabel('\phi(\omega)');
set(gca,'XTickMode','manual','XTick',[0,wls/pi,wlp/pi,wup/pi,wus/pi,1]);
set(gca,'YTickMode','manual','YTick',[-3.1416,0.3,3.1416,4]);grid on;