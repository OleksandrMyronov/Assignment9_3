
# This is the server logic of a Shiny web application. You can run the
library(shiny)
library(AER)
library(dplyr)
library(ggplot2)
data(HousePrices)
hp<-mutate(HousePrices, driveway=as.numeric(factor(driveway, levels = c("no","yes"),ordered=T))-1,
           recreation=as.numeric(factor(recreation, levels = c("no","yes"),ordered=T))-1,
           fullbase=as.numeric(factor(fullbase, levels = c("no","yes"),ordered=T))-1,
           gasheat=as.numeric(factor(gasheat, levels = c("no","yes"),ordered=T))-1,
           aircon=as.numeric(factor(aircon, levels = c("no","yes"),ordered=T))-1,
           prefer=as.numeric(factor(prefer, levels = c("no","yes"),ordered=T))-1)

fit_line<-lm(price~.-1-bedrooms, data=hp)   #Fitting model

#Two small functions, defined for converting range from RadioButtons
#RadioButton output is 0 for True, 1 for False and 2 for Non-specified
#output is equal inverted input for 0 or 1. When input is 2, output is 1 for max and 0 for min 
#min_Select<-function(x) as.numeric(x==0)
#max_Select<-function(x) as.numeric(x!=1)


# Define server logic required to draw a histogram
shinyServer(function(input, output) {

#Function for constructing min and max prediction dataframes
#Xpoint is 1 or 2 point of slidebar, Level is minimum or maximum
predicted_Range<-function(Xpoint, Level) {
    LevelVAL<-ifelse(Level=="min", 1, 2)
    LevelFUN<-ifelse(Level=="min", 
                     function(x) as.numeric(x==0), 
                     function(x) as.numeric(x!=1)) 
    
    data.frame(lotsize=input$binSize[Xpoint], 
               bedrooms=1,                   #Variable excluded from linear model
               bathrooms=input$binBathrooms[LevelVAL],
               stories=input$binStories[LevelVAL], 
               driveway=LevelFUN(input$radioDriveway),
               recreation=LevelFUN(input$radioRecreat), 
               fullbase=LevelFUN(input$radioBase),
               gasheat=LevelFUN(input$radioGasheat), 
               aircon=LevelFUN(input$radioAircon),
               garage=input$binGarage[LevelVAL], 
               prefer=LevelFUN(input$radioPrefer))    
    }    
    
    output$distPlot <- renderPlot({
        hp2<-filter(hp,                                   # filtering specified data
                    lotsize %[]% input$binSize,
                    bathrooms %[]% input$binBathrooms,
                    stories %[]% input$binStories,
                    garage %[]% input$binGarage,
                    driveway!=input$radioDriveway,
                    recreation!=input$radioRecreat,
                    fullbase!=input$radioBase,
                    gasheat!=input$radioGasheat,
                    aircon!=input$radioAircon,
                    prefer!=input$radioPrefer)
        #Constructing dataframes for plotting lines
        Ymin1<-predict(fit_line, newdata=predicted_Range(1, "min"))
        Ymin2<-predict(fit_line, newdata=predicted_Range(2, "min"))
        Ymax1<-predict(fit_line, newdata=predicted_Range(1, "max"))
        Ymax2<-predict(fit_line, newdata=predicted_Range(2, "max"))
        
        lineMin<-data.frame(x=c(input$binSize[1], input$binSize[2]), 
                            y=c(Ymin1, Ymin2))
        lineMax<-data.frame(x=c(input$binSize[1], input$binSize[2]), 
                            y=c(Ymax1, Ymax2))
        
        # plotting data
        p<-ggplot(hp2, aes(x=lotsize, y=price))
            p+geom_point(size=2, alpha=0.25)+
            labs(x="Lot size, square feet", y="House price, CAD")+
            geom_smooth(method="lm")+
            geom_line(data=lineMin, aes(x=x,y=y), color="red", lwd=2)+
            geom_line(data=lineMax, aes(x=x,y=y), color="red", lwd=2)+    
            theme_light()
    })

    output$Linear_Model<-renderPrint(summary(fit_line))
})
