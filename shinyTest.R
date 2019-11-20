library(shiny)
library(data.table)

ui <- fluidPage(
  fileInput("file_in", "Choisir un fichier", accept = "text/csv"),
  tableOutput("file_out")
)

server <- function(input, output, session){
  var = c()
  observeEvent(input$file_in, {
  #   validate(
  #     need({grep("csv$",input$file_in$type)}, "error")
  #   )
  #   # browser()
  #   var = fread(input$file_in$datapath)
  #   var = head(var)
  #   output$file_out = renderTable(var)
  # })
  output$file_out <- renderTable({
    # browser()
    validate(
      need({grep("excel$|csv$", input$file_in$type)}, "Not a csv")
      
    )
    var = fread(input$file_in$datapath)
    head(var)
    })
  })
}

shinyApp(ui, server)
