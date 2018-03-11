library(shiny)
library(ggplot2)
library(dplyr)
library(forcats)

Sdata<-read.csv("https://raw.githubusercontent.com/charleyferrari/CUNY_DATA_608/master/module3/data/cleaned-cdc-mortality-1999-2010-2.csv")
shinyServer(function(input, output){

 
  
  output$Plot <- renderPlot({
    
    SelectedData <-Sdata %>% 
    filter(Year == 2010) %>% 
    filter(ICD.Chapter == input$cause) %>% 
    select(c(ICD.Chapter,State,Crude.Rate)) 
    
    
    
    SelectedData %>%
    mutate(State = fct_reorder(State, Crude.Rate)) %>%
    ggplot( aes(x=State, y=Crude.Rate,width=.5)) +
    geom_bar(stat="identity",position="identity") +
    geom_text(size = 3, aes(label = Crude.Rate), position = position_dodge(width = 1),
              inherit.aes = TRUE,
              hjust = -0.5) +
    coord_flip()}, height = 950, width = 800)
}
)  
  
  
  
