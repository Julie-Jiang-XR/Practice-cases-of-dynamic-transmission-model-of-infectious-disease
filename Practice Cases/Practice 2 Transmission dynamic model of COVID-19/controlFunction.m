function [X_now,X_in,death_new,case_sum,severe_sum,lambdaIn]=controlFunction(nRun,Xin,betaIn,pIn,omega0In,omegaIn,gammaIn,muIn)
    %% 说明
    % 本文档用于定义传染力计算和结果计算规则
        
    %%% 符号说明：
    % Xin 当前时刻各仓室人数
    % diffOut（8*1） 该时刻各仓室人数变化情况
    % incOut（8*1） 该时刻进入各仓室的人数
    % new_serious 新增重症&危重症
    
    %%% 参数说明：
    % lambdaIn 传染力 λ
    % pIn 无症状感染者的比例 p
    % omega0In 无症状感染者的进展速度 ω0
    % omegaIn 有症状进展率和进展速度的综合参数 ω
    % muIn 死亡率 μ
    % gammaIn 考虑时长的治疗恢复率或自愈率 γ

    % nRun 微分方程运行次数——天数
    %%
    nRuns = nRun;
    % 建立空向量——存放计算结果
    X_now = zeros(8,nRuns);
    X_in = zeros(8,nRuns);
    case_new = zeros(1,nRuns);
    case_sum = zeros(1,nRuns);
    severe_sum = zeros(1,nRuns);
    death_new = zeros(1,nRuns);
    
    % 初始化
    X = Xin;
    X_now(:,1) = X;
    
    for i = 2:nRuns
        X = X_now(:,i-1);
        % 计算传染力
        kappa = [0.2 0.35 0.63];
        lambdaIn = betaIn(i)*(kappa(1)*X(2,1) + kappa(2)*X(3,1) + kappa(3)*X(4,1) + X(5,1))/10000000;
        % 更新各仓室人数
        [diffOut,incOut,deathOut] = diffCalculator(X,lambdaIn,pIn,omega0In,omegaIn,gammaIn,muIn);
        X_now(:,i) = X + diffOut; % 当前各仓室人数
        X_in(:,i) = incOut; % 当前进入各仓室的人数
        case_new(:,i) = incOut(3,:) + incOut(4,:); % 新增病例数
        case_sum(:,i) = case_new(:,i) + case_sum(:,i-1); % 当前累计病例数
        severe_sum(:,i) = incOut(6,:) + incOut(7,:)+ severe_sum(:,i-1); % 当前累计重症（重症&危重症）病例数
        death_new(:,i) = deathOut; % 新增总死亡数
    end
end