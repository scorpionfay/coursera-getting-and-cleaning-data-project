filename <- "UCI_HAR_Datasets.zip"

if (!file.exists("filename")) {
  fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileurl, filename, method="curl")
}
if (!file.exists("UCI HAR Dataset")) {
  unzip(filename)
}

setwd("UCI HAR Dataset")
activityLabel <- read.table("activity_labels.txt")

# Filter and rename columns
featureNames <- read.table("features.txt")[,2]
colfilter <- grep("*mean*|*std*",featureNames)
finalcolname <- featureNames[colfilter]
finalcolname <- gsub("-mean\\(\\)", "Mean", finalcolname)
finalcolname <- gsub("-std\\(\\)", "Std", finalcolname)
finalcolname <- gsub("-meanFreq\\(\\)", "MeanFreq", finalcolname)

# Getting training data
trainraw <- read.table("train/X_train.txt")[,colfilter]
trainlabel <- read.table("train/y_train.txt")
trainsub <- read.table("train/subject_train.txt")
traindata <- cbind(trainsub,trainlabel,trainraw)

# Getting test data
testraw <- read.table("test/X_test.txt")[,colfilter]
testlabel <- read.table("test/y_test.txt")
testsub <- read.table("test/subject_test.txt")
testdata <- cbind(testsub, testlabel,testraw)

# Merge data and add labels
data <- rbind(testdata,traindata)
names(data) <- c("Subject","Activity",finalcolname)

# Tidy Data
library(tidyr); library(reshape2)
data$Activity <- factor(data$Activity, levels = activityLabel[,1], labels = activityLabel[,2])
output <- data[order(data$Subject,data$Activity),] %>% 
  melt(id=c("Subject","Activity")) %>% 
  dcast(Subject+Activity ~ variable, mean)

write.table(output, "tidy.txt",row.name=FALSE)
