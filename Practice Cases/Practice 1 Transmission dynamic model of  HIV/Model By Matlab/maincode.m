
% this is a similar SEIR model.
% we will seperate population in different scenarios.
% X(a,b,c) metrics will store the population,
% c=1: base model, 2: Methadone, 3: Needle Syringe Program, 4: enhanced ART
% step is 1 month.

clear X_init;
nRun=120;

X_init(:,:,1)=[94100 1475 1475;0 1475 1475];

%%%%%%%%%% set parameters %%%%%%%%%%%%%%     

%base model
beta2=0.0087;   %单次注射的传染性（HIV）
beta3=0.02;     %单次注射的传染性（AIDS）
beta4=0.00087;  %假设接受治疗后可以预防90%的感染（HIV）
beta5=0.002;    %假设接受治疗后可以预防90%的感染（AIDS） 

%死亡率
miub1=0.0016;   %基线的PWID背景死亡率
miu2=0.02;      %无症状期、未接受治疗的HIV死亡率
miu3=0.22;      %AIDS期、未接受治疗的HIV死亡率
miu4=0.02;      %无症状期、接受治疗的HIV死亡率
miu5=0.08;      %AIDS期、接受治疗的HIV死亡率

rho2=1/(7*12);   %未接受治疗者无症状期转为AIDS期的比例
rho4=1/(30*12);  %接受治疗者无症状期转为AIDS期的比例

psi2_1=0.5*0.37/12;  %无症状期接受治疗的比例
psi3_1=0.63*0.5/12;  %AIDS期接受治疗的比例

n_base=30;        %1 个月的注射次数
ps_base=0.65;     %假设 2/3 的人共用针头


%%%%%%%%%%% use control function to calculate related outcomes %%%%%%%%%%
%%%%%%%%%%%% 基础模型
[prev_baseMatTemp,dieHIV_baseTemp,incT_baseTemp,dieTot_baseTemp]=controlFunction(X_init,n_base,ps_base,beta2,beta3,beta4,beta5,miub1,miu2,miu3,miu4,miu5,psi2_1,psi3_1,rho2,rho4,nRun);

%%%%%%%%%%%% 美沙酮维持治疗
n_MMT=0.4*30;        %美沙酮维持治疗后注射次数减少了约 60%
miub2=(1-0.65)*16*1.2/12000;     %美沙酮维持治疗后的PWID背景死亡率

[prev_MatMeth_Temp,dieHIV_MethTemp,incT_MethTemp,dieTot_MethTemp]=controlFunction(X_init,n_MMT,ps_base,beta2,beta3,beta4,beta5,miub2,miu2,miu3,miu4,miu5,psi2_1,psi3_1,rho2,rho4,nRun);

%%%%%%%%%%%% 免费针头或注射器方案
ps_NSP=0.33*0.65;     %针头共用率降低了67%

[prev_needleTemp,dieHIV_needleTemp,incT_needleTemp,dieTot_needleTemp]=controlFunction(X_init,n_base,ps_NSP,beta2,beta3,beta4,beta5,miub1,miu2,miu3,miu4,miu5,psi2_1,psi3_1,rho2,rho4,nRun);

%%%%%%%%%%% 加强VCT和HIV治疗
psi2_4=1*0.67/12;    %扩大检测和治疗干预后，无症状期接受治疗的比例
psi3_4=0.67*1/12;    %扩大检测和治疗干预后，AIDS期接受治疗的比例

[prec_ARTTemp,dieHIV_ARTTemp,incT_ARTTemp,dieTot_ARTTemp]=controlFunction(X_init,n_base,ps_base,beta2,beta3,beta4,beta5,miub1,miu2,miu3,miu4,miu5,psi2_4,psi3_4,rho2,rho4,nRun);


%%%%%%% now plot the curve %%%%%%%
%Prevalence
figure()
plot(2:nRun,prev_baseMatTemp(1,2:nRun)*100,'b-.','LineWidth',1);
hold on;
plot(2:nRun,prev_MatMeth_Temp(1,2:nRun)*100,'r-.','LineWidth',1);
hold on;
plot(2:nRun,prev_needleTemp(1,2:nRun)*100,'g-.','LineWidth',1);
hold on;
plot(2:nRun,prec_ARTTemp(1,2:nRun)*100,'k--','LineWidth',1);
hold on;
h=legend('base','MMT','NSP','ART','location','best');
set(h,'Fontsize',14);
legend('boxoff');
xlabel('months','FontSize',14);
set(gca,'XTick',1:10:nRun+1);
ylabel('Prevalence,%','FontSize',14);
hold off;

%incidence
figure()
plot(2:nRun,incT_baseTemp(1,2:nRun)*100,'b-.','LineWidth',1);
hold on;
plot(2:nRun,incT_MethTemp(1,2:nRun)*100,'r-.','LineWidth',1);
hold on;
plot(2:nRun,incT_needleTemp(1,2:nRun)*100,'g-.','LineWidth',1);
hold on;
plot(2:nRun,incT_ARTTemp(1,2:nRun)*100,'k--','LineWidth',1);
hold on;
h=legend('base','MMT','NSP','ART','location','best');
set(h,'Fontsize',14);
legend('boxoff');
xlabel('months','FontSize',14);
set(gca,'XTick',1:10:nRun+1);
ylabel('Incidence,%','FontSize',14);
hold off;

%HIV Mortality
figure()
plot(2:nRun,dieHIV_baseTemp(1,2:nRun)*100,'b-.','LineWidth',1);
hold on;
plot(2:nRun,dieHIV_MethTemp(1,2:nRun)*100,'r-.','LineWidth',1);
hold on;
plot(2:nRun,dieHIV_needleTemp(1,2:nRun)*100,'g-.','LineWidth',1);
hold on;
plot(2:nRun,dieHIV_ARTTemp(1,2:nRun)*100,'k--','LineWidth',1);
hold on;
h=legend('base','MMT','NSP','ART','location','best');
set(h,'Fontsize',14);
legend('boxoff');
xlabel('months','FontSize',14);
set(gca,'XTick',1:10:nRun+1);
ylabel('HIV mortality count','FontSize',14);
hold off;

%Total Mortality
figure()
plot(2:nRun,dieTot_baseTemp(1,2:nRun)*100,'b-.','LineWidth',1);
hold on;
plot(2:nRun,dieTot_MethTemp(1,2:nRun)*100,'r-.','LineWidth',1);
hold on;
plot(2:nRun,dieTot_needleTemp(1,2:nRun)*100,'g-.','LineWidth',1);
hold on;
plot(2:nRun,dieTot_ARTTemp(1,2:nRun)*100,'k--','LineWidth',1);
hold on;
h=legend('base','MMT','NSP','ART','location','best');
set(h,'Fontsize',14);
legend('boxoff');
xlabel('months','FontSize',14);
set(gca,'XTick',1:10:nRun+1);
ylabel('Total mortality count','FontSize',14);
hold off;

