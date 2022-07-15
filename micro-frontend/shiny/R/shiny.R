library(shiny)
library(ggplot2)
#Create dummy dataset
k<-1000
set.seed(999)
data<-data.frame(id=1:k)
data$gest.age<-round(rnorm(k,34,.5),1)
data$gender<-factor(rbinom(k,1,.5),labels=c("female","male"))
z =  -1.5+((((data$gest.age-mean(data$gest.age)))/sd(data$gest.age))*-1.5)
pr = 1/(1+exp(-z))
data$mat.smoke = factor(rbinom(k,1,pr))
data$bwt<- round(-3+data$gest.age*0.15+
                   ((as.numeric(data$mat.smoke)-1)*-.1)+
                   ((as.numeric(data$mat.smoke)-1))*((data$gest.age*-0.12))+
                   (((as.numeric(data$mat.smoke)-1))*(4))+
                   ((as.numeric(data$gender)-1)*.2)+rnorm(k,0,0.1),3)
data$mat.bmi<-round((122+((data$bwt*10)+((data$bwt^8)*2))/200)+
                      rnorm(k,0,1.5)+(data$gest.age*-3),1)
rm(z, pr, k)
#Define UI
ui <- fluidPage(
  
  
  #1. Select 1 of 3 continuous variables as y-variable and x-variable
  selectInput("y_varb", label="Y-axis variable",choices=names(data)[c(-1,-3,-4)]),
  selectInput("x_varb", label="X-axis variable", choices=NULL), 
  #2. Colour points using categorical variable (1 of 4 options)
  selectInput("cat_colour", label="Select Categorical variable", choices=names(data)[c(-1,-2,-5,-6)]), 
  #3. Select sample size
  selectInput("sample_sz", label = "Select sample size", choices = c(1:1000)),
  #4. Three different types  of linear regression plots
  selectInput("formula", label="Formula", choices=c("y~x", "y~poly(x,2)", "y~log(x)")),
  #5. Reset plot output after each selection
  plotOutput("plot", dblclick = "plot_reset")
  
)
server <- function(input, output) {
 
  #1. Register the y-variable selected, the remaining variables are now options for x-variable
  remaining <- reactive({
    names(data)[c(-1,-3,-4,-match(input$y_varb,names(data)))]
  })
  
  observeEvent(remaining(),{
    choices <- remaining()
    updateSelectInput(session = getDefaultReactiveDomain(),inputId = "x_varb", choices = choices)
  })
  
  
  output$plot <- renderPlot({
    #Produce scatter plot
    subset_data<-data[1:input$sample_sz,]
    ggplot(subset_data, aes_string(input$x_varb, input$y_varb))+
      geom_point(aes_string(colour=input$cat_colour))+
      geom_smooth(method="lm",formula=input$formula)
}, res = 96)
}
# Run the application 
shinyApp(ui = ui, server = server)