#Transcribe data from Silberzahn et al. 2018. Many Analysts, One Data Set: Making Transparent How Variations in Analytic Choices Affect Results. Advances in Methods and Practices in Psychological Science

#Odds Ratio Results
MeanOdds<-c(1.18,1.28,1.21,1.21,1.25,1.03,1.34,1.28,1.12,1.39,1.39,1.02,1.31,1.38,1.48,0.96,1.10,1.31,1.38,1.42,1.38,2.88,1.71,0.89,2.93,1.41,1.32,1.4,1.3)
Lower<-c(.95,.77,.97,1.20,1.05,1.01,1.1,1.04,0.88,1.1,1.17,1,1.09,1.10,1.20,.77,.98,1.1,1.11,1.19,1.12,1.03,1.7,.49,.11,1.13,1.06,1.15,1.08)
Upper<-c(1.41,2.13,1.46,1.21,1.49,1.05,1.63,1.57,1.43,1.75,1.65,1.03,1.57,1.75,1.84,1.18,1.27,1.56,1.72,1.71,1.71,11.47,1.72,1.60,78.66,1.75,1.63,1.71,1.56)
Team<-seq(1:29) #note that teams aren't in the order specified in Silberzahn
Silberzahn<-cbind.data.frame(M,Lower,Upper,Team)
write.csv(Silberzahn,"./Silberzahn_OR.csv")

#Investigate what the odds ratio data would look like without the two major outliers
SilberzahnNOutliers<-Silberzahn[-c(22,25),]
write.csv(SilberzahnNOutliers,"./Silberzahn_OR_nooutliers.csv")

#Analysis Variable Results
position<-c(1,1,1,0,0,1,0,0,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,0,1,1,1,1)
height<-c(1,1,0,1,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,1,1,1,0,0,1,1,0)
weight<-c(1,1,0,1,0,1,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,1,1,1,0,0,1,1,0)
PlayerCountry<-c(1,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,1,0,0,1,0,1,0,1,0)
PlayerAge<-c(1,0,0,0,0,1,0,0,0,0,1,0,0,1,0,1,0,0,0,1,0,0,0,1,0,0,0,0,0)
Goals<-c(0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,1,0,1,0,0,1,0)
Club<-c(1,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0)
RefCountry<-c(0,1,1,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)  
Ref<-c(1,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
Victories<-c(0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0)
PlayerCards<-c(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0)
Player<-c(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0)
RefCards<-c(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0)
Draws<-c(0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)

SilberVariables<-cbind.data.frame(position,height,weight,PlayerCountry,PlayerAge,Goals,Club,RefCountry,Ref,Victories,PlayerCards,Player,RefCards,Draws)
write.csv(SilberVariables,"./Silberzahn_Vused")


#Calculate mean dissimilarity of each team's variable selection using Sorensen's diversity index. Where variables are treated as species and teams are treated as sites
library(betapart)
sorensenmatrix<-as.matrix(beta.pair(SilberVariables, index.family="sorensen")$beta.sor) #creates the sorensen dissimilarity matrix
teamsimilarity<-colMeans(sorensenmatrix,na.rm=T) #takes the average dissimilarity for each column

