%% 说明
% 包含8个仓室: 易感者(S)1; 潜伏期(E)2; 无症状感染者(A)3;
%  轻症(L)4; 普通型(I)5; 重症(H)6; 危重症(U)7;恢复(R)8

%% 定义模型参数
clear all;
clc;
nRun = 180;


% 读取数据
% your work dictionary 
 filename = '.../coefficient.xlsx'; 

% 初始人口
[N] = xlsread(filename, 1, 'C11');

% X_init 初始时刻各仓室人数
[X_init] = xlsread(filename, 1, 'C2:C9');

% omega0In 无症状感染者的进展速度 ω0
omega0In = zeros(8,1);
[omega0In(2,1)] = xlsread(filename, 1, 'D3');

% omegaIn 有症状进展率和进展速度的综合参数 ω
[omegaIn] = xlsread(filename, 1, 'E2:E9');	

% gammaIn 考虑时长的治疗恢复率或自愈率 γ
[gammaIn] = xlsread(filename, 1, 'F2:F9');

% pIn 无症状感染者的比例 p
pIn=zeros(8,1);
[pIn(2,1)] = xlsread(filename, 2, 'B1');

% muIn 死亡率 μ
muIn=zeros(8,1);
[muIn(7,1)] = xlsread(filename, 3, 'B1');

% betaIn
betaIn = ones(1,nRun)*0.64285713;

%% 调用函数，计算并保存结果
[X_now,X_in,death_new,case_sum,severe_sum,lambdaIn] = controlFunction(nRun,X_init,betaIn,pIn,omega0In,omegaIn,gammaIn,muIn);

lambda = lambdaIn; % 传染力

% 各时刻各仓室人数(现存感染人数)
csvwrite("final_total.csv",X_now);

% 各时刻进入各仓室的人数(新增感染人数)
csvwrite("final_new.csv",X_in);

% 各时刻累计病例数
csvwrite("cases_sum.csv",case_sum);

% 各时刻累计重症（重症&危重症）病例数
csvwrite("severe_sum.csv",severe_sum);

% 每日新增死亡数
csvwrite("death.csv",death_new);

