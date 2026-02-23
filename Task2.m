%%1.离散时间系统的响应
a = [3 -4 2];
b = [1 2];
n = 0:30;
x = (1/2).^n;
y = filter(b,a,x);
figure(1);
stem(n,y,'filled'),grid on
xlabel('n'),title('系统响应y(n)');

%%2.离散时间系统的单位取样响应
a = [3 -4 2];
b = [1 2];
n = 0:30;
x = (n==0);
h = filter(b,a,x);
figure(2);
stem(n,h,'filled'),grid on
xlabel('n'),title('系统单位取样响应h(n)')



%%3.使用impz(b,a,N)求单位取样响应的方法
