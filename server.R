#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

#######
### Shiny Server.R
### Resource map with DFSS agency data
### Code reference: https://github.com/atmajitg/bloodbanks/blob/master/ui.R
### Geocode reference: https://www.r-bloggers.com/4-tricks-for-working-with-r-leaflet-and-shiny/
### Data reference: https://data.cityofchicago.org/Health-Human-Services/Family-and-Support-Services-Delegate-Agencies/jmw7-ijg5/data
######


### Load Packages

library(shiny)
library(RCurl)
library(dplyr)
library(leaflet)
library(DT)
library(ggmap)
library(shinyjs)


### Geocoding

# Register

register_google("AIzaSyCe0njdz6PmWDGB0apebkX2M5Hm1Us5Mv8")

### Function allowing geolocalisation

jsCode <- '
shinyjs.geoloc = function() {
navigator.geolocation.getCurrentPosition(onSuccess, onError);
function onError (err) {
Shiny.onInputChange("geolocation", false);
}
function onSuccess (position) {
setTimeout(function () {
var coords = position.coords;
console.log(coords.latitude + ", " + coords.longitude);
Shiny.onInputChange("geolocation", true);
Shiny.onInputChange("lat", coords.latitude);
Shiny.onInputChange("long", coords.longitude);
}, 5)
}
};
'

### Load Data w/ Github

x<-getURL("https://raw.githubusercontent.com/dkro23/COVID19-Resource-Map/master/Family_and_Support_Services_Delegate_Agencies.csv")
dfss_data<-read.csv(text=x)
head(dfss_data)
names(dfss_data)

### Shiny Server

shinyServer(function(input, output) {
  # Import Data and clean it
  
  dfss_data <- data.frame(dfss_data)
  dfss_data <- subset(dfss_data,dfss_data$Division=="Youth Services") # Isolate of Youth Services
  dfss_data$Latitude <-  as.numeric(as.character(dfss_data$Latitude))
  dfss_data$Longitude <-  as.numeric(as.character(dfss_data$Longitude))
  dfss_data=filter(dfss_data, dfss_data$Latitude != "NA") # removing NA values
  
  # new column for the popup label
  
  dfss_data <- mutate(dfss_data, cntnt=paste0('<strong>Agency Name: </strong>',Agency,
                                              '<br><strong>Site Name:</strong> ', Site.Name,
                                              '<br><strong>Address:</strong> ', Address,
                                              '<br><strong>Address Line 2:</strong> ', Address.Line.2,
                                              '<br><strong>City:</strong> ', City,
                                              '<br><strong>Zip:</strong> ',ZIP,
                                              '<br><strong>Phone Number:</strong> ',Phone.Number,
                                              '<br><strong> Community Area:</strong> ', Community.Area)) 
  
  # create a color paletter for category type in the data file
  
  #pal <- colorFactor(pal = c("#1b9e77", "#d95f02", "#7570b3"), domain = c("Charity", "Government", "Private"))
  
  # create the leaflet map  
  output$dfss_map <- renderLeaflet({
    leaflet(dfss_data) %>% 
      addCircles(lng = ~Longitude, lat = ~Latitude) %>% 
      addTiles() %>%
      addCircleMarkers(data = dfss_data, lat =  ~Latitude, lng =~Longitude, 
                       radius = 3, popup = ~as.character(cntnt), 
                       
                       stroke = FALSE, fillOpacity = 0.8)%>%
      
      addEasyButton(easyButton(
        icon="fa-crosshairs", title="ME",
        onClick=JS("function(btn, map){ map.locate({setView: true}); }")))
  })
  
  # create a data object to display data
  
  output$data <-DT::renderDataTable(datatable(
    dfss_data[,c(1:5,10:14,16:17)],filter = 'top',
    colnames = c("Agency","Program Model","Division","Site Name","Address","Address Line 2","City","State","Zip","Phone",
                 "Ward","Community Area")
  ))
  
  # Find geolocalisation coordinates when user clicks
  observeEvent(input$geoloc, {
    js$geoloc()
  })
  
  
  # zoom on the corresponding area
  observe({
    if(!is.null(input$lat)){
      map <- leafletProxy("map")
      dist <- 0.2
      lat <- input$lat
      lng <- input$long
      map %>% fitBounds(lng - dist, lat - dist, lng + dist, lat + dist)
    }
  })
  
  
})


