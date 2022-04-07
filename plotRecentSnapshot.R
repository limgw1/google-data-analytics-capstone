#Load packages
library(tidyverse)#Comes with all the basic data analytics packages
library(jsonlite) #This one's fromJSON has flatten=TRUE which allows to read nested JSON

tlData = fromJSON("Choose your directory \\league.json")$data$users
tlData = tlData %>% 
  group_by(league$rank) %>%
  filter(!(abs(league$pps - median(league$pps)) > 6*sd(league$pps))) %>%
  filter(!(abs(league$apm - median(league$apm)) > 6*sd(league$apm))) %>%
  filter(!league$glicko < 100)
#Regression
dataRegression = lm(league$pps ~ poly(league$glicko, degree=3, raw=TRUE), data=tlData)
coefficients = unname(coef(dataRegression))
#Formulas for raw and adjusted versions of EFF,APP,DPP
tlData['raw_eff'] = ((tlData$league$vs)/tlData$league$pps)
tlData['adjusted_eff'] = (2/3)*((tlData$league$vs)/tlData$league$pps)+(1/3)*((tlData$league$pps)/(coefficients[1] + coefficients[2] * tlData$league$glicko +  coefficients[3] * tlData$league$glicko^2 +  coefficients[4] * tlData$league$glicko^3))
tlData['raw_app'] = (tlData$league$apm/(tlData$league$pps*60))
tlData['adjusted_app'] =  (2/3)*((tlData$league$apm)/(tlData$league$pps*60))+(1/3)*((tlData$league$pps)/(coefficients[1] + coefficients[2] * tlData$league$glicko +  coefficients[3] * tlData$league$glicko^2 +  coefficients[4] * tlData$league$glicko^3))
View(tlData)
#Plot the league$pps~glicko graph with a very loose regression eqn implemented
  ggplot(tlData, aes(x=league$pps, y=league$glicko)) + geom_point(mapping=aes(x=league$pps, y=league$glicko, color=league$rank))+scale_color_manual(values=c('x'= '#FF45FF','u'= '#FF3813','ss'= '#DB8B1F','s+'= '#D8AF0E','s'= '#E0A71B', 's-'= '#B2972B', 'a+'= '#1FA834','a'= '#46AD51','a-'= '#3BB687','b+'= '#4F99C0','b'= '#4F64C9','b-'= '#5650C7','c+'= '#552883','c'= '#733E8F','c-'= '#79558C','d+'= '#8E6091','d'= '#907591'))+ stat_smooth(method="lm", formula= y ~ poly(x, degree=3, raw=TRUE))
write.csv(tlData,"Choose your directory.csv", row.names = TRUE)
