moduleUi <- function(id){
  ns <- NS(id)
  numericInput(ns("buffer"))
}

module <- function(input, output, session){
  var <- reactive()
}