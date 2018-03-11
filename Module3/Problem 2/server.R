
library(shiny)
library(ggplot2)
library(dplyr)
library(forcats)

Sdata<-read.csv("https://raw.githubusercontent.com/charleyferrari/CUNY_DATA_608/master/module3/data/cleaned-cdc-mortality-1999-2010-2.csv")
shinyServer(function(input, output){

 
  
  output$Plot <- renderPlot({
    
    SelectedData <-Sdata %>% 
    filter(ICD.Chapter == input$cause) %>% 
    group_by(Year) %>%
    mutate(weight=(Population/sum(Population))*Crude.Rate) %>%
    mutate(avg=sum(weight)) %>%
    filter(State == input$state)
    
    
    
    
    SelectedData %>%
    ggplot( aes(x=Year, y=Crude.Rate,width=.5)) +
    geom_bar(stat="identity",position="identity",fill="yellow") +
    geom_text(size = 3, aes(label = Crude.Rate), position = position_dodge(width = 1),
              inherit.aes = TRUE,
              hjust = 0.5, colour="blue") +
    geom_line(aes(x=Year, y=avg), colour="blue") +
    theme(axis.text=element_text(size=12),
    axis.title=element_text(size=14,face="bold"))}, height = 950, width = 800) 
    
}
)  
  
  
  
