# This is a Shiny web application.
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# Basic UI
ui <- navbarPage(title = div(img(src = "http://www2.gov.bc.ca/assets/gov/home/gov3_bc_logo.png"),
                             "Grizzly Bear Conservation Status in British Columbia"),
                 tabPanel("Interactive Map"),
                 tabPanel("Data Explorer"),
                 mainPanel(leafletOutput(outputId = "grizzmap")),
                 navbarMenu("More",
                            tabPanel("About"),
                            tabPanel("Summary"))
)

# UI with custom CSS
ui <- function() {
  navbarPage(
    title = div(img(src = "http://www2.gov.bc.ca/assets/gov/home/gov3_bc_logo.png",
                    height = 30, style = "margin: 10 px 10 px"),
                "Grizzly Bear Conservation Status in British Columbia"),
    tabPanel("Interactive Map"),
    tabPanel("Data Explorer"),
    mainPanel(leafletOutput(outputId = "grizzmap")),
    navbarMenu("More",
               tabPanel("About"),
               tabPanel("Summary")),
    tags$style(type = 'text/css',
               '.navbar { background-color: #003366;}',
               '.navbar-default .navbar-brand {color: white;}',
               '.nav-tabs { background-color: #38598a;}',
               '.nav navbar-nav li.active:hover a, .nav navbar-nav li.active a {
               color: #fff !important;
               background-color: #5475a7 !important;
               }'
               )
  )
}
