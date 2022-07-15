# Load packages
library(shiny)

source("R/helpers.R")

dmeta <- read_tsv("data/metadata.tsv")

group_sample <- unique(dmeta$GROUP_name, incomparables = FALSE)

# Define UI ----
ui <- fluidPage(
  titlePanel("Test Plot_A"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("NAME_Sample"),
      selectInput("name", 
                  label = "Choose a name to display",
                  choices = c(dmeta$NAME_sample),
                  selected = dmeta$NAME_sample[1]),
      helpText("GROUP_name"),
      selectInput("group", 
                  label = "Choose a group to display",
                  choices = c(group_sample),
                  selected = group_sample[1])
    ),
    mainPanel(
      plotOutput("plot_a"),
      plotOutput("plot_hm")
    )
  )
  
)

# Define server logic ----
server <- function(input, output) {
  
  output$plot_a <- renderPlot({
    plot_a
  })
  
  output$plot_hm <- renderPlot({
    hm_phy
  })
  
}

# Run the app ----
shinyApp(ui = ui, server = server)