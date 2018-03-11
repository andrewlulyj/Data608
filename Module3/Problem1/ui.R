library(shiny)

data<-read.csv("https://raw.githubusercontent.com/charleyferrari/CUNY_DATA_608/master/module3/data/cleaned-cdc-mortality-1999-2010-2.csv")

shinyUI(
  fluidPage(    
    
    # Give the page a title
    titlePanel("Crude Rate by State"),
    
    # Generate a row with a sidebar
    sidebarLayout(      
      
      # Define the sidebar with one input
      sidebarPanel(
        selectInput("cause", "Select a Cause:", 
                    choices=as.character(unique(data$ICD.Chapter))),
        hr(),
        helpText("Data only include 2010")
      ),
      
      # Create a spot for the barplot
      mainPanel(
        plotOutput("Plot")  
      )
      
    )
  )
)