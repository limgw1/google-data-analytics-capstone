#Load packages
library(RMySQL)#Required for accessing your MySQL DB as reading the created 1.2GB CSV file is too hard on my laptop
library(tidyverse)#Comes with all the basic data analytics packages
library(gridExtra)
#Connect to DB
con = dbConnect(RMySQL::MySQL(),
                dbname="tl_delta_db",
                host="localhost",
                port=3306,
                user="root",
                password="INSERT YOUR PASSWORD HERE")
#============INSERT PLAYER LIST HERE==============
playerList = c("firestorm","qmk")
#=================================================
#Plot for adjusted EFF
plot1 = ggplot()
#Plot for adjusted APP
plot2 = ggplot()
#Plot for PPS
plot3 = ggplot()
queryString = paste("SELECT * FROM tl_delta_table WHERE delta_date >= '2020-06-15 00:00:00' AND (username='", paste(playerList, collapse="' OR username='"), "')",sep="")
playerHistorical = dbSendQuery(con, queryString)
playerTable = dbFetch(playerHistorical, n=100000)
relevantData = playerTable[,c("username","delta_date","raw_eff","adjusted_eff","adjusted_app","pps","glicko")] %>% group_by('username')
plot1 = ggplot()+geom_line(data= relevantData, aes(x=delta_date, y=adjusted_eff, group=username, color=username), size=1)+
  theme(axis.text.x=element_blank(),axis.title.x=element_blank(),legend.title=element_blank(),legend.position="top")
plot2 = ggplot()+geom_line(data= relevantData, aes(x=delta_date, y=adjusted_app, group=username, color=username), size=1)+
  theme(axis.text.x=element_blank(),axis.title.x=element_blank(),legend.title=element_blank(),legend.position="top")
plot3 = ggplot()+geom_line(data= relevantData, aes(x=delta_date, y=pps, group=username, color=username), size=1)+
  theme(axis.text.x=element_blank(),legend.title=element_blank(),legend.position="top")
grid.arrange(plot1, plot2, plot3, layout_matrix=matrix(c(1,1,2,2,3), nrow=5))

