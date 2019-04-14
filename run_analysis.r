#Getting and Cleaning Coursera Data Course Project

#Julian Paolo S. Alejandro

#Loading the necessary R packages

library(data.table)
library(dplyr)


#Downloading the data files to be used and unzipping them

URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
Dataset <- "UCI HAR Dataset.zip"
if (!file.exists(Dataset)){
  download.file(URL, destfile = Dataset, mode='wb')
}
if (!file.exists("./UCI HAR Dataset")){
  unzip(Dataset)
}


#Settng the directory to the data set folder to start reading files

setwd("./UCI HAR Dataset")


#Reading the activity(y) files

ytest <- read.table("./test/y_test.txt", header = F)
ytrain <- read.table("./train/y_train.txt", header = F)


#Reading the features(x) files

xtest <- read.table("./test/X_test.txt", header = F)
xtrain <- read.table("./train/X_train.txt", header = F)


#Reading the subject(sub) files

subtest <- read.table("./test/subject_test.txt", header = F)
subtrain <- read.table("./train/subject_train.txt", header = F)


#Reading the activity labels and feature names files
ActLabels <- read.table("./activity_labels.txt", header = F)
Features <- read.table("./features.txt", header = F)


#Merging them into dataframes: Features Test and Train, Activity Test and Train, Subject Test and Train

ActivityData <- rbind(ytest, ytrain)
FeaturesData <- rbind(xtest, xtrain)
SubjectData <- rbind(subtest, subtrain)


#Renaming the colums of the dataframes

names(ActivityData) <- "ActivityN"
names(ActLabels) <- c("ActivityN", "Activity")
Activity <- left_join(ActivityData, ActLabels, "ActivityN")[, 2]
names(ActLabels) <- c("ActivityN", "Activity")
names(SubjectData) <- "Subject"
names(FeaturesData) <- Features$V2


#Creating one consolidated data frame

DataSet <- cbind(SubjectData, Activity)
DataSet <- cbind(DataSet, FeaturesData)
View(DataSet)


#Creating new datasets by extracting only the mean and standard deviation for each measurement

SubFeatures <- Features$V2[grep("mean\\(\\)|std\\(\\)", Features$V2)]
DataNames <- c("Subject", "Activity", as.character(SubFeatures))
DataSet2 <- subset(DataSet, select=DataNames)
View(DataSet2)


#Using more descriptive activity names to the columns of the large dataset

names(DataSet2)<-gsub("^t", "time", names(DataSet2))
names(DataSet2)<-gsub("^f", "frequency", names(DataSet2))
names(DataSet2)<-gsub("Acc", "Accelerometer", names(DataSet2))
names(DataSet2)<-gsub("Gyro", "Gyroscope", names(DataSet2))
names(DataSet2)<-gsub("Mag", "Magnitude", names(DataSet2))
names(DataSet2)<-gsub("BodyBody", "Body", names(DataSet2))
View(DataSet2)


#Creating an independent tidy data set with the average of each variable for each activity and each subject

TidyDataSet<-aggregate(. ~Subject + Activity, DataSet2, mean)
TidyDataSet<-TidyDataSet[order(TidyDataSet$Subject,TidyDataSet$Activity),]
View(TidyDataSet)


#Exporting the tidy dataset to a local file
write.table(TidyDataSet, file = "TidyData.txt",row.name=FALSE)