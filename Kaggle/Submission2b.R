## KAGGLE COMPETITION

## S2a - Logistic regression - significant variables only, nas removed only from these.

# biddable+startprice+condition+cellular+carrier+color+storage+productline

# train AUC - 0.8626658
# test AUC  - 0.83625

# accuracy - 0.8278228
rm(list=ls())
# Read in data
train = read.csv("./data/eBayiPadTrain.csv",stringsAsFactors=FALSE,na.strings=c("Unknown",""))
test = read.csv("./data/eBayiPadTest.csv", stringsAsFactors=FALSE,na.strings=c("Unknown",""))
attach(train)

str(train)
train=subset(train,!is.na(biddable))
str(train)
train=subset(train,!is.na(startprice))
str(train)
train=subset(train,!is.na(condition))
str(train)
train=subset(train,!is.na(storage))
str(train)
train=subset(train,!is.na(productline))
str(train)



# train=data.frame(biddable,startprice,condition,storage,productline,sold)
# train=na.omit(train)
# str(train)

mean(train$sold)  # is <0.5 - so most are not sol

## LOGISTIC REGRESSION MODEL

# keep only significant variables
modelLog<-glm(sold~biddable+startprice+condition+storage+productline,family=binomial,data=train)
summary(modelLog)


# 1.2 What is the accuracy of the model on the traintest set? 
# Use a threshold of 0.5. 
predictLog = predict(modelLog,newdata=train)
max(predictLog)
ct<-table(train$sold, predictLog >= 0.5)
ct
(sum(diag(ct)))/sum(ct)

# 1.3 What is the baseline accuracy for the testing set?
# = accuracy of the prediction always that iPad not sold.
sum(ct[1,])/sum(ct)

# What is the area-under-the-curve (AUC) for this model on the train set?
# ROC curve

library(ROCR)
predLog = prediction(predictLog, train$sold)
as.numeric(performance(predLog, "auc")@y.values)

perfLog = performance(predLog, "tpr", "fpr")
plot(perfLog)

# And then make predictions on the test set:
library(Hmisc)

test$productline<-as.character(with(test,impute(productline, "iPad 2")))
test$storage<-as.numeric(with(test,impute(storage, 16)))
PredTest = predict(modelLog, newdata=test, type="response")

# We can't compute the accuracy or AUC on the test set ourselves, since we don't have the dependent variable on the test set (you can compute it on the training set though!). 
# However, you can submit the file on Kaggle to see how well the model performs. You can make up to 5 submissions per day, so don't hesitate to just upload a solution to see how you did.

# Let's prepare a submission file for Kaggle (for more about this, see the "Evaluation" page on the competition site):

library(Hmisc)
MySubmission2b = data.frame(UniqueID = test$UniqueID, Probability1 = PredTest)
# MySubmission2b$Probability1 <- as.numeric(with(MySubmission2b, impute(Probability1, 0.5)))
write.csv(MySubmission2b, "./submissions/SubmissionSimpleLog2bimpute.csv", row.names=FALSE)

# You should upload the submission "SubmissionSimpleLog.csv" on the Kaggle website to use this as a submission to the competition

