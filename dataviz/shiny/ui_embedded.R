library(DT)


ui_embedded <- shinyUI(fluidPage(
    titlePanel("Grizzly Bear Conservation Status in British Columbia"),
    tabsetPanel(
      tabPanel("Interactive Map",
               icon = icon("globe"),
               fluidRow(column(6,
                               div(class = "plot-container",
                                   tags$img(src = "spinner.gif",
                                            class = "loading-spinner"),
                                   leafletOutput("grizzmap", height = 600))))
               ),
      tabPanel("Data Explorer",
               icon = icon("bar-chart"),
               mainPanel(DT::datatable(threat_calc, width = 800)),
               fluidRow(column(6)))
    ))
)

