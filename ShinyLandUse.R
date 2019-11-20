library(rgdal)
library(shiny)
library(data.table)
library(maptools)
library(sp)
library(raster)
library(tools)
library(utils)

ui <- fluidPage(
  fileInput("habitats", "Choisir le raster habitat"),
  fileInput("points", "Choisir le zipfile du fichier shape points"),
  textOutput("habitats_out"),
  textOutput("points_out")
  #plotOutput("preview")
  #plotOutput("mapPlot")
  
  # tableOutput("file_out")
)

server <- function(input, output, session){
  #options(shiny.maxRequestSize=1024*1024^2)
  # Hab <- c()
  # Points <- c()

  observeEvent(input$habitats, {
    
    output$habitats_out <- renderText({
      # validity check
      validate(
        need({grep("jpeg$|jpg$|tiff$|tif$", input$habitats$type)}, "Not an image")
        
      )
      
      # if passed
      # set Points reactive
      Hab <- reactive({
        raster::brick(input$habitats$datapath)
      })
      browser()
      # return message
      return("File loaded")
    })
  })
  
  observeEvent(input$points, {
    
    output$habitats_out <- renderText({
      # validity check
      #browser()
      validate(
        need({grep("application/x-zip-compressed$", input$points$type)}, "Not a zipfile")
      )
      # if passed
      # set Points reactive
      pts_unzip <- unzip(input$points$datapath, exdir = dirname(input$points$datapath))
      Points <- reactive({
        readOGR(dsn = dirname(pts_unzip)[1],layer = file_path_sans_ext(basename(pts_unzip))[1])
      })
      #browser()
      validate(
        need({grep("shp$", pts_unzip)}, "Not a shapefile")
      )
      #browser()
      #return message
      return("File loaded")
    })
  })
  
  # output$mapPlot<-renderPlot({
  #     plot(Hab())#;
  #     #plot(inShp(), add=TRUE)
  #   })
  # return("Raster loaded")

}

shinyApp(ui, server)
