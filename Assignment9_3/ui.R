# This is the user-interface definition of a Shiny web application.
library(shiny)
library(shinythemes)

My_RadioButton<-function(inputId, label) {          #Custom RadioButton creation
    radioButtons(inputId, label, choiceNames=c("Yes", "No", "Non-spec"), 
                 choiceValues=c(0, 1, 2), inline=T, selected=2)}

# Define UI for application
shinyUI(fluidPage(
    theme = shinytheme("slate"), 
    titlePanel("House Prices App"),
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
                                 h4("This app is based on", tags$a(href="https://www.rdocumentation.org/packages/AER/versions/1.2-9/topics/
                                    HousePrices", "HousePrices"), "dataset from AER R package. Data represent sales prices of houses sold in 
                                    the city of Windsor, Canada, during July, August and September, 1987."),
                                 h4("Find the house of your dreams for the best price!"),
                                 h3("How to use App:"),
                                 h4("1. Go to the Data Visualization Tab."),
                                 h4("2. Select desired ranges for numeric parameters on sliders."),
                                 h4("3. Specify desired factors on RadioButtons, Non-spec selects both cases."),
                                 h4("4. Scatterplot displays selected data points from original dataset. Red and blue lines represent 
                                 predictions for the most upper and the most lower of specified values and factors."),
                                 h4("5. If there are no plotted data points, there are no such houses for sale. Try other parameters,
                                    or you can just estimate price range by prediction lines."),
                                 h4("6. Use checkboxes under the plot to display actual pice and (actual - predicted) price difference. 
                                    Negative difference means, that real price is lower, than predicted."), 
                                 h4("7. Using text labels with many data points makes plot messy. 
                                    You can just evaluate actual-predicted price difference by color. Reds are expensive, blues are cheap."),
                                 h4("You can find some model description on \"Linear Model Info\" tab."),
                                 ),
                        tabPanel("Data Visualization", plotOutput("distPlot"),
                                 checkboxInput("checkShowPrice", "Show price label"),
                                 checkboxInput("checkShowDiffer", "Show difference between actual and predicted price"),
                                 ),
                        tabPanel("Linear Model Info", 
                                 h5("We used simple linear model for house price prediction algorithm. Interception and number of bedrooms 
                                 are excluded from model, due to non-significant variable coefficient p-values (>0.05). All model coefficients 
                                 are positive, that makes finding min and max range prediction lines very straightforward - we just need to 
                                 find set of all min-s and all max-es from variable ranges. App algorithm produces two parallel lines, which are 
                                 price-lotsize estimations for min and max sets of other model parameters in range of min and max lotsize from 
                                 appropriate slidebar. When all the parameters are strictly defined, two lines collapses into single prediction line."),
                                 verbatimTextOutput("Linear_Model"))))
    )
))
