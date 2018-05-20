library(shinydashboard)
library(shiny)
library(ggplot2)
library(dplyr)

data <- 'https://raw.githubusercontent.com/andrewlulyj/Data608/master/Module6/test.txt'
US_trade<-read.table(data,sep="\t",head=TRUE )
data2 <- 'C:/Users/andre/Downloads/test2.txt'

# split data into import export and net
by_country<-read.table(data2,sep="\t",head=TRUE)
by_country_balance<-by_country[2:21,1:10]
by_country_export<-by_country[23:42,1:10]
by_country_import<-by_country[44:63,1:10]
US_trade$order<-1:26
country<-filter(by_country,Country.and.Area != "Balance",Country.and.Area != "Imports",Country.and.Area != "Exports")

# get data for China only
China_Balance<-by_country_balance %>%
filter(Country.and.Area == "China") %>%
gather("Period",Balance,2:10) %>%
filter(Period != "Year.to.Date.2017") %>%
filter( Period != "Year.to.Date.2018" )
China_Balance$order <- c(7,6,1,2,3,4,5)

# get data for China only
China_import<-by_country_import %>%
  filter(Country.and.Area == "China") %>%
  gather("Period",Import,2:10) %>%
  filter(Period != "Year.to.Date.2017") %>%
  filter( Period != "Year.to.Date.2018" )
China_import$order <- c(7,6,1,2,3,4,5)

# get data for China only
China_export<-by_country_export %>%
  filter(Country.and.Area == "China") %>%
  gather("Period",Export,2:10) %>%
  filter(Period != "Year.to.Date.2017") %>%
  filter( Period != "Year.to.Date.2018" )
China_export$order <- c(7,6,1,2,3,4,5)

China_Balance$Import <- China_import$Import
China_Balance$Export <- China_export$Export

# get balance data by country and sorted by time
balance<-by_country_balance %>%
gather("Period",Balance,2:10) %>%
filter(Period != "Year.to.Date.2017") %>%
filter( Period != "Year.to.Date.2018" )
order<-China_Balance 
balance<-left_join(balance,order, "Period")

# get export data by country and sorted by time
export<-by_country_export %>%
gather("Period",Export,2:10) %>%
filter(Period != "Year.to.Date.2017") %>%
filter( Period != "Year.to.Date.2018" )
export<-left_join(export,order, "Period")

# get import data by country and sorted by time
import<-by_country_import %>%
gather("Period",Import,2:10) %>%
filter(Period != "Year.to.Date.2017") %>%
filter( Period != "Year.to.Date.2018" )
import<-left_join(import,order, "Period")


# calculate proportion of balance for each country  
balance_con<-balance %>%
  dplyr::group_by(Period) %>%
  dplyr::summarise(Total = sum(Balance.x)) 
balance_rat<-right_join(balance_con,balance,"Period")%>%
  mutate(ratio = Balance.x/Total)

# calculate proportion of import for each country 
import_con<-import %>%
  dplyr::group_by(Period) %>%
  dplyr::summarise(Total = sum(Import.x)) 
import_rat<-right_join(import_con,import,"Period")%>%
  mutate(ratio = Import.x/Total)

# calculate proportion of export for each country 
export_con<-export %>%
  dplyr::group_by(Period) %>%
  dplyr::summarise(Total = sum(Export.x)) 
export_rat<-right_join(export_con,export,"Period")%>%
  mutate(ratio = Export.x/Total)

shinyServer(function(input, output){
  
  
  # setup visualization for dash board 1 
  output$plot1 <- renderPlot({
    from <- filter(US_trade,Period== input$from )$order
    to <- filter(US_trade,Period== input$to )$order
    selectData<-filter(US_trade,order >= from, order <= to )
    p<-ggplot(selectData, aes(x=reorder(Period, order), y=Balance.Total,group=1)) + geom_line(aes( colour = "Total")) + geom_point() + theme(axis.text.x = element_text(angle = 90, hjust = 1))
    
    p<-p+geom_line(aes(y = Balance.Services, colour = "Service")) + geom_point(aes(y = Balance.Services, colour = "Service")) 
    p<-p+geom_line(aes(y = Balance.Goods, colour = "Good")) + geom_point(aes(y = Balance.Goods, colour = "Good"))
    p<-p + ylab("Balance")+xlab("Period") + ggtitle("US Trade Balance, Good VS Service") + scale_colour_manual(values=c("red","green","blue"))
    p})
  
  # setup visualization for dash board 2
  output$plot2 <- renderPlot({
    from2 <- filter(balance,Period== input$from2 )$order
    to2 <- filter(balance,Period== input$to2 )$order
    bal<-filter(balance,order >= from2, order <= to2, 
                
                Country.and.Area.x %in% input$country )
    
    ex <- filter(export,order >= from2, order <= to2, 
                 
                 Country.and.Area.x %in% input$country )
    
    imp <- filter(import,order >= from2, order <= to2, 
                 
                 Country.and.Area.x %in% input$country )
    
   
    if  (input$dataSource == 'Import')
    {ggplot(imp, aes(x=reorder(Period, order), y=Import.x ,group=
                      Country.and.Area.x)) + geom_line(aes( colour = 
                                                              Country.and.Area.x),linetype="dashed") +  theme(axis.text.x = element_text(angle = 90, hjust = 1)) + ylab("Import")+xlab("Period") + ggtitle("US Trade Import Balance By Country")}
    else if  (input$dataSource == 'Export')
    {ggplot(ex, aes(x=reorder(Period, order), y=Export.x ,group=
                       Country.and.Area.x)) + geom_line(aes( colour = 
                                                               Country.and.Area.x),linetype="dashed") +  theme(axis.text.x = element_text(angle = 90, hjust = 1)) + ylab("Export")+xlab("Period") + ggtitle("US Trade Export Balance By Country")}
    else  
    {ggplot(bal, aes(x=reorder(Period, order), y=Balance.x ,group=
                       Country.and.Area.x)) + geom_line(aes( colour = 
                                                               Country.and.Area.x),linetype="dashed") +  theme(axis.text.x = element_text(angle = 90, hjust = 1)) + ylab("Net")+xlab("Period") + ggtitle("US Trade Net Balance By Country")}
  })
  
  # setup visualization for dash board 1
  output$plot3 <- renderPlot({

    bal_con<-filter(balance_rat, Country.and.Area.x %in% input$country2 )
    
    ex_con <- filter(export_rat,Country.and.Area.x %in% input$country2 )
    
    imp_con <- filter(import_rat,Country.and.Area.x %in% input$country2 )
    
    
    if  (input$dataSource2 == 'Import')
    {ggplot(imp_con, aes(fill=Period, y=ratio, x=Country.and.Area.x)) + 
        geom_bar(position="dodge", stat="identity") + theme(axis.text.x = element_text(angle = 90, hjust = 1)) + ggtitle("US Import Balance Contirbution By Country") }
    else if  (input$dataSource2 == 'Export')
    {ggplot(ex_con, aes(fill=Period, y=ratio, x=Country.and.Area.x)) + 
        geom_bar(position="dodge", stat="identity") + theme(axis.text.x = element_text(angle = 90, hjust = 1)) + ggtitle("US Export Balance Contirbution By Country") }
    else  
    {ggplot(bal_con, aes(fill=Period, y=ratio, x=Country.and.Area.x)) + 
        geom_bar(position="dodge", stat="identity") + theme(axis.text.x = element_text(angle = 90, hjust = 1)) + ggtitle("US Net Trade Balance Contirbution By Country")}
  })
}
)  



