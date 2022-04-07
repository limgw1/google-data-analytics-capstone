#Single Timeframe Analysis
#Load packages
library(RMySQL)#Required for accessing your MySQL DB as reading the created 1.2GB CSV file is too hard on my laptop
library(tidyverse)#Comes with all the basic data analytics packages
library(jsonlite) #This one's fromJSON has flatten=TRUE which allows to read nested JSON
library(lubridate)
library(dplyr)
#Connect to DB
con = dbConnect(RMySQL::MySQL(),
                dbname="tl_delta_db",
                host="localhost",
                port=3306,
                user="root",
                password="Insert your password here")
#Identify files to read in
rootDir = "D:\\tetrio-stats"
globalStartTime = Sys.time()
foldersToProcess = list.files(path=rootDir) #For entire folder
readFileInside = function(folderName){
  if(file.info(paste(rootDir,folderName,"league.json",sep="\\"))$size>2000){
    startTime = Sys.time()
    tlData = fromJSON(txt = paste(rootDir,folderName,"league.json",sep="\\"))$users
    tlData = tlData %>%
      group_by(league$rank) %>%
      filter(!(abs(league$pps - median(league$pps)) > 6*sd(league$pps))) %>%
      filter(!league$glicko < 100)
    dataRegression = lm(league$pps ~ poly(league$glicko, degree=3, raw=TRUE), data=tlData)
    coefficients = unname(coef(dataRegression))
    variables=paste(coefficients[1],coefficients[2],coefficients[3],coefficients[4], sep = ",")
    query=paste("INSERT INTO tl_time_series_regression VALUES (\"", ymd_hms(folderName),"\",", variables, ")")
    a = dbSendQuery(con,query)
    endTime = Sys.time()
    print(endTime-startTime)
  }else{
    print(folderName)
    print("File size too small")
  }

}
lapply(X = foldersToProcess, FUN=readFileInside)
globalEndTime = Sys.time()
print(globalEndTime-globalStartTime)

#dataRegression = lm(league$pps ~ poly(league$glicko, degree=3, raw=TRUE), data=tlData)
#coefficients = unname(coef(dataRegression))
#variables=paste(coefficients[1],coefficients[2],coefficients[3],coefficients[4], sep = ",")

