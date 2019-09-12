%生成联合正态分布的概率密度函数
clear

syms x1 x2 x3
mu=[5;3;2];
x=[x1;x2;x3];
collect(collect((x-mu)*((x-mu)')))

C=[6 1 3;
    1 4 2;
    3 2 7];
det(C)
inv(C)*113
