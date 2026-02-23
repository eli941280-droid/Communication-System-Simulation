% --- Part 1: 绘制连续信号 ---

% 创建一个新的图形窗口
figure('Name', '连续信号');

% (1) 绘制 sa(t) = sin(t)/t, -10 <= t <= 10
subplot(3, 1, 1); % 创建一个3行1列的子图，并激活第1个
t1 = -10:0.01:10;
% 直接计算 sin(t)/t。对于 t=0 的点，其极限为1。
y1 = sin(t1) ./ t1;
% Matlab 在计算 0/0 时会得到 NaN，我们需要手动将其修正为 1
y1(t1 == 0) = 1; 
plot(t1, y1);
title('信号 (1): sa(t) = sin(t)/t');
xlabel('t');
ylabel('sa(t)');
grid on;

% (2) 绘制 g₂(t) (门函数)
% 定义一个标准的门函数，在 [-0.5, 0.5] 范围内为1，其余为0
subplot(3, 1, 2); % 激活第2个子图
t2 = -5:0.01:5;
y2 = (t2 >= -0.5 & t2 <= 0.5);
plot(t2, y2);
title('信号 (2): g₂(t) (门函数)');
xlabel('t');
ylabel('g₂(t)');
ylim([-0.2, 1.2]); % 调整y轴范围，使图形更清晰
grid on;

% (3) 绘制 5e^(0.5t)sin(2πt), 0 <= t <= 10
subplot(3, 1, 3); % 激活第3个子图
t3 = 0:0.01:10;
y3 = 5 .* exp(0.5 .* t3) .* sin(2 * pi .* t3);
plot(t3, y3);
title('信号 (3): 5e^{0.5t}sin(2\pi t)');
xlabel('t');
ylabel('y(t)');
grid on;



% --- Part 2: 绘制离散信号 ---

% 创建一个新的图形窗口
figure('Name', '离散信号');

% (1) 绘制 δ(k) (单位冲激序列)
subplot(3, 1, 1); % 创建一个3行1列的子图，并激活第1个
k1 = -10:1:10;
y1 = (k1 == 0); % 当 k=0 时为1，其余为0
stem(k1, y1, 'filled'); % 使用stem函数绘制离散序列
title('信号 (1): \delta(k) (单位冲激序列)');
xlabel('k');
ylabel('\delta(k)');
grid on;

% (2) 绘制 g₄(k) (长度为4的矩形序列)
subplot(3, 1, 2); % 激活第2个子图
k2 = -2:1:6;
y2 = (k2 >= 0 & k2 <= 3); % 在 [0, 3] 范围内为1，长度为4
stem(k2, y2, 'filled');
title('信号 (2): g₄(k) (长度为4的矩形序列)');
xlabel('k');
ylabel('g₄(k)');
ylim([-0.2, 1.2]); % 调整y轴范围
grid on;

% (3) 绘制 1.1^k * sin(0.05πk), 0 <= k <= 60
subplot(3, 1, 3); % 激活第3个子图
k3 = 0:1:60;
% 注意要使用点运算符 (.* .^) 进行元素级别的乘法和幂运算
y3 = (1.1).^k3 .* sin(0.05 * pi .* k3); 
stem(k3, y3, 'filled');
title('信号 (3): 1.1^k sin(0.05\pi k)');
xlabel('k');
ylabel('y(k)');
grid on;