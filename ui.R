#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

######
### Shiny UI.R
### Resource map with DFSS agency data
### Code reference: https://github.com/atmajitg/bloodbanks/blob/master/ui.R
### Geocode reference: https://www.r-bloggers.com/4-tricks-for-working-with-r-leaflet-and-shiny/
### Data reference: https://data.cityofchicago.org/Health-Human-Services/Family-and-Support-Services-Delegate-Agencies/jmw7-ijg5/data
######

library(shiny)
library(leaflet)

navbarPage("Location of DFSS Agencies", id="main",
           tabPanel("Map", leafletOutput("dfss_map", height=1000)),
           tabPanel("Data", DT::dataTableOutput("data")))



