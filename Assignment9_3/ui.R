# This is the user-interface definition of a Shiny web application.
library(shiny)
library(intrval)
library(shinythemes)

My_RadioButton<-function(inputId, label) {                              #Custom RadioButton creation
    radioButtons(inputId, label, choiceNames=c("Yes", "No", "Non-spec"), 
                 choiceValues=c(0, 1, 2), inline=T, selected=2)}

# Define UI for application
shinyUI(fluidPage(
    theme = shinytheme("slate"), 
    titlePanel("House Prices Data"),
    sidebarLayout(
        sidebarPanel(
            sliderInput("binSize", "Lot size in square feet",
                        min = 1500, max = 16500, value = c(1500, 16500), step=100),
            sliderInput("binBathrooms", "Number of bathrooms",
                        min = 1, max = 4, value = c(1,4), step=1),
            sliderInput("binGarage", "Number of garage places",
                        min = 0, max = 3, value = c(0,3), step=1),
            sliderInput("binStories", "Number of stories",
                        min = 1, max = 4, value = c(1,4), step=1),
            My_RadioButton("radioDriveway", "Has a driveway"),
            My_RadioButton("radioRecreat", "Has a recreational room"),
            My_RadioButton("radioBase", "Has a full finished basement"),
            My_RadioButton("radioGasheat", "Uses gas for hot water heating"),
            My_RadioButton("radioAircon", "Has central air conditioning"),
            My_RadioButton("radioPrefer", "Located in preferred neighborhood of the city"),
            ),
        
        mainPanel(                       # Main panel items
            tabsetPanel(type = "tabs",
                        tabPanel("Description", 
                                 h4("This app is based on HousePrices dataset from AER package. Data represent sales 
                                    prices of houses sold in the city of Windsor, Canada, during July, August and September, 1987."),
                                 h3("How to use App"),
                                 h4("Move the sliders and RadioButtons to find house of your dreams for the best price!"), 
                                 h4("Points on scatterplot represent houses from dataset with specified parameter ranges. Use checkboxes under the plot 
                                    to display actual house prices and difference between actual and predicted prices")
                                 ),
                        tabPanel("Data visualization", plotOutput("distPlot"),
                                 checkboxInput("checkShowPrice", "Show price label"),
                                 checkboxInput("checkShowDiffer", "Show difference between actual and predicted price"),
                                 ),
                        tabPanel("Linear model", verbatimTextOutput("Linear_Model"))))
    )
))
