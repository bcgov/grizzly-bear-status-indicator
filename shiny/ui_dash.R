##
## SECOND UI WITH DASHBOARD PAGE ---------------
library(shinydashboard)

ui_dash <- dashboardPage(
  dashboardHeader(title = div(img(src = "http://www2.gov.bc.ca/assets/gov/home/gov3_bc_logo.png",
                                  height = 30, style = "padding: 1px 0px, width: '100%'"),
                              "Grizzly Bear Conservation Status in British Columbia")),

    dashboardSidebar(
    sidebarMenu(
      menuItem(
        "Interactive Map",
        tabName = "Map",
        icon = icon("globe"),
        menuSubItem("Population Density", tabName = "Density", icon = icon("bacon")),
        menuSubItem("Population Estimates", tabname = "Population", icon = icon("campground")),
        menuSubItem("Mortality", tabName = "Mortality", icon = icon("circle"))
        ),
      menuItem(
        "Data Explorer",
        tabName = "Data",
        icon = icon("bar-chart")
      )
    ),
    dashboardBody(
      tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
      leafletOutput(grizzmap)
      )
    )
  )


navbarPage(

    tabPanel("Interactive Map"),
    tabPanel("Data Explorer"),
    absolutePanel(leafletOutput(outputId = "grizzmap")),
    navbarMenu("More",
               tabPanel("About"),
               tabPanel("Summary")),
    tags$style(HTML(
      '.navbar { background-color: #003366;}', # navbar background
      '.navbar-default .navbar-brand {color: white; font.family: Arial}', # navbar text col
      '.navbar-default .navbar-nav > li > a {color:white}', # navbar text color
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

