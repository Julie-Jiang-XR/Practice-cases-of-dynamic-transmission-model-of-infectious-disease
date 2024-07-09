###### 工作目录 ######
setwd("...")

######  读入问卷数据  #######
library("openxlsx")

df_sc <- openxlsx::read.xlsx("contact-sc.xlsx") 

## ----------------------------------------------------------------------------------
######  1 数据整理  ######
## 将年龄组标识改为编号
library(dplyr) # %>%
library(forcats) # fct_relevel
library(stringr)
recode_my_df <- function(df){
  df_recode <- df %>%
    mutate(
      res_age = case_when(res_age == "15-19" ~ 4,  # "[15,20)"
                          res_age == "20-24" ~ 5,  # "[20,25)"
                          res_age == "25-29" ~ 6,  # "[25,30)"
                          res_age == "30-34" ~ 7,  # "[30,35)"
                          res_age == "35-39" ~ 8,  # "[35,40)"
                          res_age == "40-44" ~ 9,  # "[40,45)"
                          res_age == "45-49" ~ 10,  # "[45,50)"
                          res_age == "50-51" ~ 11,  # "[50,55)"
                          res_age == "55-59" ~ 12,  # "[55,60)"
                          res_age == "60-64" ~ 13,  # "[60,65)"
                          res_age == "≥65" ~ 14),  # "[65,100]"
      
      cont_age = case_when(cont_age == "0-4" ~ 1,     # "[0,5)"
                           cont_age == "5-9" ~ 2,     # "[5,10)" 
                           cont_age == "10-14" ~ 3,   # "[10,15)"
                           cont_age == "15-19" ~ 4,   # "[15,20)"
                           cont_age == "20-24" ~ 5,   # "[20,25)"
                           cont_age == "25-29" ~ 6,   # "[25,30)"
                           cont_age == "30-34" ~ 7,   # "[30,35)"
                           cont_age == "35-39" ~ 8,   # "[35,40)"
                           cont_age == "40-44" ~ 9,   # "[40,45)"
                           cont_age == "45-49" ~ 10,  # "[45,50)"
                           cont_age == "50-54" ~ 11,  # "[50,55)"
                           cont_age == "55-59" ~ 12,  # "[55,60)"
                           cont_age == "60-64" ~ 13,  # "[60,65)"
                           cont_age == "≥65" ~ 14)  # "[65,100]"
    )
  return(df_recode)
}

df_recode_sc <- recode_my_df(df_sc)



## ----------------------------------------------------------------------------------
######  2 计算矩阵A(the Contact Data Matrix)  ######
##### 2.1 计算矩阵A #####
## 矩阵说明
# contactDataMatrix(i,j)：由i组个体报告的与j组成员的日均接触数
# INPUT:
# num_res_i : m*1 cell array of caseCount in each groups
# [caseAge, contactAge] : m*2 matrix of n-th (caseAge, contactAge) pairs
# agePartition : (n+1) * 1 vector, partitioned population by n age groups

# OUTPUT: 
# the Contact Data Matrix —— A


## 数据矩阵建立
computeContactDataMatrix <- function(df_recode){
  ## 预设年龄组数为14
  groupCount <- 14
  
  ## 创建空矩阵（初始化）
  A <- matrix(0,groupCount,groupCount)
  
  ## 计算出每一个年龄组的受访者人数
  # 建立一个无重复的简单数据框
  uniqueID <- unique(df_recode$ID)
  idxID <- c()
  for(i in 1:length(uniqueID)){
    idxID <- c(idxID,which(df_recode$ID == uniqueID[i])[1])
  }
  df_unique <- df_recode[idxID,c("ID","w_res","res_age")]
  
  num_res_i <- aggregate(df_unique$w_res, 
                         by = list(type=df_unique$res_age),
                         sum)
  
  ## 计算出i组受访者与j组被接触者总数
  num_contact_ij <- aggregate(df_recode$w_cont*df_recode$w_res, 
                              by = list(df_recode$res_age, df_recode$cont_age),
                              sum)
  
  ## 按行添加数据对(caseAge, contactAge)至contactDataMatrix——A
  for (i in 4:groupCount){
    for (j in 1:groupCount){
      if((i %in% num_contact_ij$Group.1) & (j %in% num_contact_ij$Group.2[which(i == num_contact_ij$Group.1)])){
        A[i,j] <- num_contact_ij$x[(num_contact_ij$Group.1 == i) & (num_contact_ij$Group.2 == j)] / num_res_i$x[num_res_i$type == i]
        # A[j,i] <- num_contact_ij$x[(num_contact_ij$Group.1 == i) & (num_contact_ij$Group.2 == j)] / num_res_i$x[num_res_i$type == i]
        
      }
    }
  }
  
  # 无1~3组受访者
  A[1:3,] = NA
  
  return(A)
}

A_sc <- computeContactDataMatrix(df_recode_sc)

## 保存数据集
# write.xlsx(data.frame(A_sc),"ContactDataMatrix_A_sc.xlsx")



##### 2.2 绘制热图FUN #####
## 基础设置
ageLabels <- c("[0,5)"  ,"[5,10)" ,"[10,15)","[15,20)","[20,25)",
               "[25,30)","[30,35)","[35,40)","[40,45)","[45,50)",
               "[50,55)","[55,60)","[60,65)","[65,100]")
ylabel <- "受访者年龄组"
xlabel <- "接触对象年龄组"


## 加载包
library(reshape2)   #生成绘制热图所需的数据形式
library(ggplot2)   #绘图


## 热图绘制函数
matrixplot <- function(matrix,ageLabels,mytitle,mysubtitle) {
  # matrix[is.na(matrix)] <- 0
  melted_contactDataMatrix <- melt(matrix)
  for (i in 1:length(ageLabels)) { 
    for (j in 1:2){
      melted_contactDataMatrix[which(melted_contactDataMatrix[,j] == i),j] = ageLabels[i]
    }}
  names(melted_contactDataMatrix) <- c("agegroupi", "agegroupj", "ContactCount")
  
  orderAge <- factor(1:length(ageLabels), labels = ageLabels)
  melted_contactDataMatrix$agegroupi <- factor( melted_contactDataMatrix$agegroupi,
                                                levels = levels(orderAge))
  melted_contactDataMatrix$agegroupj <- factor( melted_contactDataMatrix$agegroupj,
                                                levels = levels(orderAge))
  maxContact <- ceiling(max(matrix))
  
  ## 绘制热图  注意区分标签
  heatplot <- ggplot(data = melted_contactDataMatrix, aes(agegroupi, y=agegroupj, fill=ContactCount)) + 
    geom_tile() +
    theme_classic(base_size = 8) +
    theme(axis.text.x=element_text(angle=90,hjust=1, vjust=.5)) +
    coord_equal() +
    xlab(xlabel) +
    ylab(ylabel) +
    labs(
      title = mytitle,
      subtitle = mysubtitle
    ) + 
    viridis::scale_fill_viridis(option = "viridis",name="平均接触数", limits=c(0,maxContact), na.value = "white")
  
  return(heatplot)
}


##### 2.3 绘制热图——A矩阵 #####
##  绘制Matrix A的图片
A_scHeatmap <- matrixplot(t(A_sc),ageLabels,"ContactDataMatrix A","   -- (social contact)")

## 输出图片
A_scHeatmap

## 保存图片
ggsave(A_scHeatmap, 
       file = "ContactDataMatrix A（social）.png", 
       width = 10, height = 9, units = "cm", dpi = 1000)




## ----------------------------------------------------------------------------------
######  3 计算矩阵C(the Contact Matrix)  ######
##### 3.1 M1: 计算矩阵C——简单平均 #####
## 读入人口数据
agePopulation <- openxlsx::read.xlsx("AgePopulation.xlsx", sheet=1)


#### 3.1.1 M1: 简单平均计算 ####
estimateCM_Average <- function(A,N){
  # A: contactDataMatrix
  # N: agePopulation
  
  groupCount <- nrow(A)   # 14组
  C <- A  #初始化
  
  for (i in 4:(groupCount-1)) {
    for (j in (i+1):groupCount) {
      C[i,j] <- (A[i,j] * N[i] + N[j] * A[j,i]) / (2* N[i])
      C[j,i] <- N[i] / N[j] * C[i,j]
    }
  }
  
  for (i in 1:3) {
    for (j in (i+1):groupCount) {
      C[i,j] <- N[j] * A[j,i] / N[i]
    }
  }
  
  return(C)
}



#### 3.1.2 绘制热图——C矩阵 ####
C_Average_sc <- estimateCM_Average(A_sc,agePopulation$num)
C_Average_scHeatmap <- matrixplot(t(C_Average_sc),ageLabels,"ContactMatrix C_Average","   -- (social contact)")


## 输出图片
C_Average_scHeatmap


## 保存图片
ggsave(C_Average_scHeatmap, 
       file = "ContactMatrix C_Average（social）.png", 
       width = 10, height = 9, units = "cm", dpi = 1000)

## 保存数据集
# write.xlsx(data.frame(C_Average_sc),"ContactMatrix_C_Average_sc.xlsx")




##### 3.2  M2:计算矩阵C——LSE #####
#### 3.2.1 M2: LSE计算 ####
#获得C_LSE，绘制LSE估计的热图
##使用LSE计算矩阵
estimateCM_LSE <- function(A, N){
  # A: contactDataMatrix
  # N: agePopulation
  groupCount <- nrow(A)
  C_LSE <- A
  
  for (i in 1:(groupCount-1)) {
    for (j in (i+1):groupCount) {
      C_LSE[i,j] <- (A[i,j] + N[i]/N[j] * A[j,i]) / (1 + N[i]^2 / N[j]^2)
      C_LSE[j,i] <- N[i] / N[j] *  C_LSE[i,j]
    }
  }
  return(C_LSE)
}


#### 3.2.2 绘制热图——C矩阵 ####
## 获得C_LSE，绘制热图
C_LSE_sc <- estimateCM_LSE(A_sc,agePopulation$num)
C_LSE_scHeatmap <- matrixplot(t(C_LSE_sc),ageLabels,"ContactMatrix C_LSE","   -- (social contact)")


## 输出图片
C_LSE_scHeatmap

## 保存图片
ggsave(C_LSE_scHeatmap, 
       file = "ContactMatrix C_LSE（social）.png", 
       width = 10, height = 9, units = "cm", dpi = 1000)

## 保存数据集
# write.xlsx(data.frame(C_LSE_sc),"ContactMatrix_C_LSE_sc.xlsx")




