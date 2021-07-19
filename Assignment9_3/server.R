# Server logic of a Shiny web application
library(shiny)
library(AER)
library(dplyr)
library(intrval)
library(ggplot2)
data(HousePrices)
# Text variable yes/no to numeric conversion 
fToN <- function(x) {as.numeric(factor(x, levels = c("no","yes"),ordered=T))-1}
hp<-mutate(HousePrices, driveway=fToN(driveway), recreation=fToN(recreation),
           fullbase=fToN(fullbase), gasheat=fToN(gasheat),
           aircon=fToN(aircon), prefer=fToN(prefer))            
fit_line<-lm(price~.-1-bedrooms, data=hp)      #Fitting model

shinyServer(function(input, output) {          #Define server logic
    #Function for constructing min and max prediction dataframes
    #Xpoint is 1-st or 2-nd of slidebar, Level is min or max
    predicted_Range<-function(Xpoint, Level) {
        LevelVAL<-ifelse(Level=="min", 1, 2)     
        LevelFUN<-ifelse(Level=="min",         #Logic for RadioButtons
                     function(x) as.numeric(x==0), 
                     function(x) as.numeric(x!=1)) 
        data.frame(lotsize=input$binSize[Xpoint], 
               bedrooms=0,                #bedrooms excluded from linear model
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
    #Plotting data
    output$distPlot <- renderPlot({       
       hp2<-filter(hp,                    #filtering specified data
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
        # Calculating difference
        hp2<-mutate(hp2, PriceDiff=price-predict(fit_line, newdata=hp2))
        #Creating and plotting ggplot object
        p<-ggplot(hp2, aes(x=lotsize, y=price, color=PriceDiff))+
            scale_colour_gradient2(low = "blue", mid = "gray", high = "red")
        p<-p+geom_point(size=3, alpha=0.5)+
            labs(x="Lot size, square feet", y="House price, $")+
            theme_light()+
            geom_line(data=lineMin, aes(x=x,y=y), color="blue", lwd=1.5, alpha=0.5)+
            geom_line(data=lineMax, aes(x=x,y=y), color="red", lwd=1.5, alpha=0.5)
            if (input$checkShowPrice) {p<-p+geom_text(aes(lotsize, price, 
                                       label=paste(price, "$")), hjust=0, vjust=1, color="black")}
            if (input$checkShowDiffer) {p<-p+geom_text(aes(lotsize, price, 
                                       label=paste(round(PriceDiff), "$")), hjust=0, vjust=2, color="black")}
        p 
    })
    output$Linear_Model<-renderPrint(summary(fit_line))  #Printing model summary 
})
