library(shinydashboard)
library(shiny)
library(ggplot2)
library(dplyr)
library(tidyr)
data <- 'https://raw.githubusercontent.com/andrewlulyj/Data608/master/Module6/test.txt'
US_trade<-read.table(data,sep="\t",head=TRUE )
data2 <- 'https://raw.githubusercontent.com/andrewlulyj/Data608/master/Module6/test2.txt'

# split data set into import expoort and net
by_country<-read.table(data2,sep="\t",head=TRUE)
by_country_balance<-by_country[2:21,1:10]
by_country_export<-by_country[23:42,1:10]
by_country_import<-by_country[44:63,1:10]
US_trade$order<-1:26
country<-filter(by_country,Country.and.Area != "Balance",Country.and.Area != "Imports",Country.and.Area != "Exports")

# get data for China only and sort it according to time
China_Balance<-by_country_balance %>%
  filter(Country.and.Area == "China") %>%
  gather("Period",Balance,2:10) %>%
  filter(Period != "Year.to.Date.2017") %>%
  filter( Period != "Year.to.Date.2018" )
China_Balance$order <- c(7,6,1,2,3,4,5)

balance<-by_country_balance %>%
gather("Period",Balance,2:10) %>%
filter(Period != "Year.to.Date.2017") %>%
filter( Period != "Year.to.Date.2018" )
order<-China_Balance
balance<-left_join(balance,order, "Period") 
balance<-balance %>% arrange(order)

# create dashboard layout
dashboardPage(
  dashboardHeader(title = "US Trade Analysis"),
  dashboardSidebar(
    # set up menu 
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("Break Down", tabName = "breakdown", icon = icon("dashboard")),
      menuItem("Contribuction Analysis", tabName = "histgrom", icon = icon("dashboard")),
      menuItem("Summary", tabName = "summary", icon = icon("dashboard"))
    )
  ),
  dashboardBody(
    tabItems(
      # set up first page
      tabItem(tabName = "overview", 
    fluidRow(
      box(plotOutput("plot1"),width = 12),height = 800),
    fluidRow( 
    box(
      title = "Select Reporting Period",
      selectInput("from", "From:", 
                  choices=as.character(unique(US_trade$Period))),
      selectInput("to", "To", 
                  choices=as.character(unique(US_trade$Period)))
    ))), # tabItem 1
    
    # set up second page
    tabItem(tabName = "breakdown",h2("US Import Export Data Break Down"),
            fluidRow(box(plotOutput("plot2"),width = 12),height = 800),
            fluidRow(
                     box(title = "Select Reporting Period",
                         selectInput("from2", "From:", 
                                     choices=as.character(unique(balance$Period))),
                         selectInput("to2", "To", 
                                     choices=as.character(unique(balance$Period))),width = 4),
                     box(title = "Select Data Source",
                         selectInput("dataSource","Select", 
                                     choices=c('Import','Export','Net')),width = 4),
                     box(title = "Select Country",
                         selectInput("country", "Select:", 
                                     choices=as.character(unique(country$Country.and.Area)),multiple = TRUE),helpText("Mutiple selection allowed"),width = 4) 
                     )  ), #tabItem 2
    # set up third page
    tabItem(tabName = "histgrom",h2("US Trade Balance Contribuction By Country"),
            fluidRow(
            box(plotOutput("plot3"),width = 12),height = 800),
            fluidRow(
              box(title = "Select Data Source",
                  selectInput("dataSource2","Select", 
                              choices=c('Import','Export','Net')),width = 4),
              box(title = "Select Country",
                  selectInput("country2", "Select:", 
                              choices=as.character(unique(country$Country.and.Area)),multiple = TRUE),helpText("Mutiple selection allowed"),width = 4) 
            )  ),
    # set up summary page text
    tabItem(tabName = "summary",h2("Project Summary"),
            fluidRow(box(title = "Data Discription","The data source for this project is based on census
                         https://www.census.gov/foreign-trade/Press-Release/current_press_release/index.html. Among all data availabe on the website,
                         Exhibit 1- U.S. International Trade in Goods and Services and Exhibit 19- U.S. Trade in Goods by Selected Countries and Areas - Census Basis
                         are used for this project. The first data set include US total export, import and net trade balance from 2016 to March 2018. The data was splited
                         in to goods and service. The second data set is a breakdown view for first data set which listed US import and export and net trade balance from
                        2016 to 2018 splited by country. Different from first data set, the second datga set only include good instead of good and service.
                         
                         
               ",width = 12)),
            fluidRow(box(title = "Visiualiztion Summary","The project include three visiualiztions, the first dashboard is based on the first data set which is a
                         trend visiualiztions for US net trade balance for both good and service. The visualiztion allow user to pick specific time range.
                         From the plot, we can see that US is exports more service than imports all the time while imports more goods than service all the time and the net is always
                         negative which means US has trade deficit all the time. The second dashboard is a trend analysis for US import, export and net balance with different countries
                         The user can pick time range, and countries to see either import or expoert as well as net trend. From the plot we can see that US has an import drop from 
                         a lot of countries since 2018 and it may has thing to do with the tax pliocy change in 2018. The third plot is a proportion analysis for US trade data and it allow
                         user to see how each country contribuction to US import and export from time to time. As we can see from the histgram that China contribute to 
                         US net trade most for all the time, so as recent trade way between US and China, it may significantly influence the US international trade ",width = 12 )),
            fluidRow(box(title = "significance","Although the project is just a prtotype, the provide a meaningful way to for user to analyze trade data using R.The user can replace data set with similar 
                         data set, may be more recent data, to do analysis. Also because of the breakdown, user can compare the trends between countries to see if we over trade with some countres. In addition, if any event related to US trade happen, 
                         users can quickly pick the affacted countries to see the data. It will be more powerful if the dashboard is feeded with real time data",width = 12 ))
             )
  ) # tabItems
  ) 
)
