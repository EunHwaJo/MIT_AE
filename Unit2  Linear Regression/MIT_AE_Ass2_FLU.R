# Set working directory
setwd("C:/Users/Mike/Rspace/MIT_AE/Unit2")

library(dplyr)
library(lubridate)

## READING TEST SCORES

if(!file.exists("data")){
        dir.create("data")
}

# download train data if not yet already done so
if(!file.exists("./data/FluTrain.csv")){
        
        #download a data file as csv into the "data" dir
        
        fileURL<-"https://courses.edx.org/asset-v1:MITx+15.071x_2a+2T2015+type@asset+block/FluTrain.csv"
        download.file(fileURL,destfile="./data/FluTrain.csv")
        #include date of download
        
}
FluTrain<-read.csv("./data/FluTrain.csv")

# download train data if not yet already done so
if(!file.exists("./data/FluTest.csv")){
        
        #download a data file as csv into the "data" dir
        
        fileURL<-"https://courses.edx.org/asset-v1:MITx+15.071x_2a+2T2015+type@asset+block/FluTest.csv"
        download.file(fileURL,destfile="./data/FluTest.csv")
        #include date of download
        
}
FluTest<-read.csv("./data/FluTest.csv")

#1.1
head(arrange(FluTrain,-ILI))
head(arrange(FluTrain,-Queries))

#1.2
hist(FluTrain$ILI)

#1.3
#Plot the natural logarithm of ILI versus Queries.
#What does the plot suggest?.
plot(FluTrain$Queries,log(FluTrain$ILI))

#2.2
FluTrend1<-lm(log(ILI)~Queries,data=FluTrain)
summary(FluTrend1)

#3.1
PredTest1 = exp(predict(FluTrend1, newdata=FluTest))
index<-which(FluTest$Week=="2012-03-11 - 2012-03-17")
PredTest1[index]

#3.2
(FluTest$ILI[11] - PredTest1[11])/FluTest$ILI[11]

#3.3
SSE = sum((PredTest1-FluTest$ILI)^2)
RMSE = sqrt(SSE/nrow(FluTest))
RMSE

#4.1
library(zoo)
        
ILILag2 = lag(zoo(FluTrain$ILI), -2, na.pad=TRUE)
FluTrain$ILILag2 = coredata(ILILag2)

sum(is.na(ILILag2))

#4.2
plot(log(FluTrain$ILI),log(FluTrain$ILILag2))

#4.3
FluTrend2<-lm(log(ILI)~Queries+log(ILILag2),data=FluTrain)
summary(FluTrend2)

#5.1
ILILag2 = lag(zoo(FluTest$ILI), -2, na.pad=TRUE)
FluTest$ILILag2 = coredata(ILILag2)
sum(is.na(ILILag2))

#5.3
FluTest$ILILag2[1] = FluTrain$ILI[nrow(FluTrain)-1]
FluTest$ILILag2[1]
FluTest$ILILag2[2] = FluTrain$ILI[nrow(FluTrain)]
FluTest$ILILag2[2]

#5.4
PredTest2 = exp(predict(FluTrend2, newdata=FluTest))
SSE2 = sum((PredTest2-FluTest$ILI)^2)
RMSE2 = sqrt(SSE2/nrow(FluTest))
RMSE2