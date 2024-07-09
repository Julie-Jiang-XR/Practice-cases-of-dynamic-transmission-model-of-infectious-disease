function [diffOut,incOut,deathOut]=diffCalculator(Xin,lambdaIn,pIn,omega0In,omegaIn,gammaIn,muIn) 
    %% 说明
    % 本文档用于定义微分方程函数

    %%% 符号说明：
    % Xin 当前时刻各仓室人数
    % diffOut（8*1） 该时刻各仓室人数变化情况
    % incOut（8*1） 该时刻进入各仓室的人数

    %%% 参数说明：
    % lambdaIn 传染力 λ
    % pIn 无症状感染者的比例 p
    % omega0In 无症状感染者的进展速度 ω0
    % omegaIn 有症状进展率和进展速度的综合参数 ω
    % muIn 死亡率 μ
    % gammaIn 考虑时长的治疗恢复率或自愈率 γ
    
    %%
    % 建立空向量——存放计算结果
    diffOut = zeros(8,1);
    incOut = zeros(8,1);

    % 该时刻各仓室人数变化量
    diffOut(1,1) = -lambdaIn(1,1)*Xin(1,1);  % S
    diffOut(2,1) = lambdaIn(1,1)*Xin(1,1)-omega0In(2,1)*pIn(2,1)*Xin(2,1)-(1-pIn(2,1))*omegaIn(2,1)*Xin(2,1); % E
    diffOut(3,1) = omega0In(2,1)*pIn(2,1)*Xin(2,1)-gammaIn(3,1)*Xin(3,1); % A
    diffOut(4,1) = (1-pIn(2,1))*omegaIn(2,1)*Xin(2,1)-omegaIn(4,1)*Xin(4,1)-gammaIn(4,1)*Xin(4,1); % L
    diffOut(5,1) = omegaIn(4,1)*Xin(4,1)-gammaIn(5,1)*Xin(5,1)-omegaIn(5,1)*Xin(5,1); % I
    diffOut(6,1) = omegaIn(5,1)*Xin(5,1)-gammaIn(6,1)*Xin(6,1)-omegaIn(6,1)*Xin(6,1); % H
    diffOut(7,1) = omegaIn(6,1)*Xin(6,1)-gammaIn(7,1)*Xin(7,1)-muIn(7,1)*Xin(7,1); % U
    diffOut(8,1) = gammaIn(3,1)*Xin(3,1)+gammaIn(4,1)*Xin(4,1)+gammaIn(5,1)*Xin(5,1)+gammaIn(6,1)*Xin(6,1)+gammaIn(7,1)*Xin(7,1); % R

    % 该时刻进入各仓室的人数
    incOut(1,1) = -diffOut(1,1);  % S
    incOut(2,1) = lambdaIn(1,1)*Xin(1,1); % E
    incOut(3,1) = omega0In(2,1)*pIn(2,1)*Xin(2,1); % A
    incOut(4,1) = (1-pIn(2,1))*omegaIn(2,1)*Xin(2,1); % L
    incOut(5,1) = omegaIn(4,1)*Xin(4,1); % I
    incOut(6,1) = omegaIn(5,1)*Xin(5,1); % H
    incOut(7,1) = omegaIn(6,1)*Xin(6,1); % U
    incOut(8,1) = diffOut(8,1); % R
    
    % 新增总死亡数
    deathOut = muIn(7,1)*Xin(7,1);
end