library(shiny)
library(lubridate)
library(rmarkdown)
library(callr)

# Copy report.Rmd to temporary directory. Important when deploying the app,
# since working directory won't be writable
report_path <- tempfile(fileext = ".Rmd")
file.copy("report.Rmd", report_path, overwrite = TRUE)

render_report <- function(input, output, params) {
  rmarkdown::render(input,
                    output_file = output,
                    params = params,
                    envir = new.env(parent = globalenv())
  )
}

ui <- fluidPage(
  textInput("name", "What's your name?"),
  downloadButton("pdf_button", "Download PDF")
)

server <- function(input, output, session) {
  output$pdf_button <- downloadHandler(
    filename = paste0("report-", format(lubridate::now(), "%Y-%m-%dT%H_%M_%S%z"), ".pdf"),
    content = function(file) {
      params <- list(name = input$name)
      
      id <- showNotification(
        "Rendering Report...",
        duration = NULL,
        closeButton = FALSE
      )
      on.exit(removeNotification(id), add = TRUE)
      
      callr::r(
        render_report,
        list(input = report_path, output = file, params = params)
      )
    }
  )
}

options <- list()
if (!interactive()) {
  options$port = 3838
  options$launch.browser = FALSE
  options$host = "0.0.0.0"
  
}
shinyApp(ui, server, options=options)