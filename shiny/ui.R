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
    tags$style(HTML(
               '.navbar { background-color: #003366;}',
               '.navbar-default .navbar-brand {color: white;}',
               '.navbar { border-bottom: 2px solid #fcba19;}',
               '.navbar .nav-tabs { background-color: #5475a7;}',
               '.tabbable > .nav > li > a { background-color: #5475a7; color: #fff }',
               '.navbar-nav li a:hover, .navbar-nav > .active > a {
                 color: #fff !important;
                   background-color: #5475a7 !important;
                   background-image: none !important;
               }'
               ))
  )
}
