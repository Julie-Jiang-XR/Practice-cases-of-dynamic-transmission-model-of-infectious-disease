# 工作空间设置
setwd("...") 

# install.packages("R0")
library(R0)

# entire period
nation<-read.csv("cases01.csv")$National
names(nation) = c("2020-01-10","2020-01-11","2020-01-12","2020-01-13","2020-01-14",
                  "2020-01-15", "2020-01-16","2020-01-17","2020-01-18","2020-01-19",
                  "2020-01-20","2020-01-21","2020-01-22","2020-01-23","2020-01-24",
                  "2020-01-25","2020-01-26","2020-01-27","2020-01-28","2020-01-29",
                  "2020-01-30","2020-01-31","2020-02-01","2020-02-02","2020-02-03",
                  "2020-02-04","2020-02-05")



############## Test 1 ###############
# 给定代际时间的分布
nation.flu <- generation.time("gamma",c(3,1.5))

# 基于指数增长的方法
EG<-est.R0.EG(nation, nation.flu)
EG$R
# 1.525895
EG$conf.int
# 1.494984 1.557779

# 基于最大似然的方法
ML<-est.R0.ML(nation, nation.flu)
ML$R
# 1.383996
ML$conf.int
# 1.309545 1.461203

# 多种算法同时使用
#res.R <- estimate.R(nation, GT=nation.flu, methods=c("EG","ML"))

# 两类方法的结果比较（均方根误差百分比、绝对误差百分比、Loss函数等方法都可以）
# 这里仅展示基于Loss函数进行比较
EG_pred<-EG$pred
ML_pred<-ML$pred

# loss.func<-sum(pred)- sum(data$cases*log(pred)) 取值越小，估计越优
loss.func.EG<-sum(EG_pred)-sum(nation*log(EG_pred))
# -10092.64
loss.func.ML<-sum(ML_pred)-sum(nation*log(ML_pred))
# -10098.38



#################### Test 2 ################
# 给定代际时间的分布
nation.flu <- generation.time("gamma",c(3,1.5))

# 基于序列贝叶斯的方法
SB<-est.R0.SB(nation, nation.flu)
SB$R
SB$conf.int

# 基于时依再生系数的方法
TD<-est.R0.TD(nation, nation.flu)
TD$R
TD$conf.int

# 多种算法同时使用
#res.R <- estimate.R(nation, GT=nation.flu, methods=c("SB","TD"))

# 两类方法的结果比较（均方根误差百分比、绝对误差百分比、Loss函数等方法都可以）
# 这里仅展示基于Loss函数进行比较
SB_pred<-SB$pred
TD_pred<-TD$pred

# loss.func<-sum(pred)- sum(data$cases*log(pred)) 取值越小，估计越优
loss.func.SB<-sum(SB_pred)-sum(nation*log(SB_pred))
# -9744.193
loss.func.TD<-sum(TD_pred)-sum(nation*log(TD_pred))
# -10122



