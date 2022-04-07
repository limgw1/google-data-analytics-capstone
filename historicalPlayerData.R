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
                password="INSERT PASSWORD HERE")

#Example: Getting historical TL data of player
playerHistorical = dbSendQuery(con, "SELECT * FROM tl_delta_table INNER JOIN tl_time_series_regression
	ON tl_delta_table.delta_date = tl_time_series_regression.currTime WHERE username='czsmall0402'")
playerTable = dbFetch(playerHistorical, n=100000)
relevantData = playerTable[,c("delta_date","raw_eff","adjusted_eff","pps","glicko")]
relevantData["expected_pps"] = playerTable['zero_order'] + playerTable['first_order'] * playerTable['glicko'] + playerTable['second_order'] * playerTable['glicko']^2 + playerTable['third_order'] * playerTable['glicko']^3
#Plot the graphs
plot1 = ggplot(data=relevantData, aes(x=delta_date, group = 1))+
        geom_line(aes(y=pps, color="PPS"), size=1)+
        geom_line(aes(y=expected_pps, color="Expected PPS"), size=1)+
        scale_color_manual(values=c("PPS"="Orange", "Expected PPS"="Purple"))+
        theme(axis.text.x=element_blank(),axis.title.y=element_blank(),legend.title=element_blank(),legend.position="top")

plot2 = ggplot(data=relevantData, aes(x=delta_date, group = 2), color=variable)+
        geom_line(aes(y=adjusted_eff, color="Adjusted Efficiency"), size=1)+
        geom_line(aes(y=raw_eff, color="Raw Efficiency"), size=1)+
        scale_color_manual(values=c("Adjusted Efficiency"="Red", "Raw Efficiency"="Green"))+
        theme(axis.title.x=element_blank(),axis.text.x=element_blank(),axis.title.y=element_blank(),legend.title=element_blank(),legend.position="top")

grid.arrange(plot1, plot2, layout_matrix=matrix(c(2,2,1), nrow=3))


