library(shiny)
library(httr)
library(stringr)
library(jsonlite)


model_list <- read.table(text = system("ollama list", intern = TRUE),
                         sep = "\t", row.names = NULL)
# tabs at the end of each model row adds an additional empty column
model_list$MODIFIED <- NULL
colnames(model_list) <- c("NAME", "ID", "SIZE", "MODIFIED")
model_list$NAME <- trimws(model_list$NAME)

ui <- fluidPage(
  div(
    titlePanel("ollama with Shiny"),
    style = "color: white; background-color: #3d3f4e"
  ),
  sidebarLayout(
    sidebarPanel(
      h3("Welcome to ollama!"),
      # p("This application allows you to chat with an OpenAI GPT model and explore its capabilities. Simply use your own API keys with adding below."),
      # textInput("api_key", "API Key", "sk-PLACEYOUROWNAPIKEYHERE"),
      # tags$p("Find your own OpenAI API:", 
      #        tags$a(href = "https://platform.openai.com/account/api-keys", target="_blank", "https://platform.openai.com/account/api-keys")
      # ),tags$hr(),
      selectInput("model_name", "Model Name",
                  choices = c("llama2:latest", "llama2-uncensored:latest",
                              "codellama:latest",
                              "medllama2:latest", "orca-mini:latest",
                              "mistral:latest", "samantha-mistral:latest",
                              "orca-mini:3b"), selected = "llama2:latest"),
      tags$hr(),
      sliderInput("temperature", "Temperature", min = 0.1, max = 1.0, value = 0.7, step = 0.1),
      sliderInput("max_length", "Maximum Length", min = 1, max = 2048, value = 512, step = 1),
      tags$hr(),
      textAreaInput(inputId = "sysprompt", label = "SYSTEM PROMPT", height = "200px", value = "You are a helpful assistant."),
      tags$hr(),
      tags$div(
        style="text-align:center; margin-top: 15px; color: white; background-color: #FFFFFF",
        a(href="https://github.com/TroyHernandez/shinychatgpt", target="_blank",
          img(src="https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png", height="30px"),
          "View source code on Github"
        )
      ),
      style = "background-color: #1a1b1f; color: white"
    )
    ,
    mainPanel(
      tags$style(type = "text/css", ".shiny-output-error {visibility: hidden;}"),
      tags$style(type = "text/css", ".shiny-output-error:before {content: ' Check your inputs or API key';}"),
      tags$style(type = "text/css", "label {font-weight: bold;}"),
      fluidRow(
        column(12,tags$h3("Chat History"),tags$hr(),uiOutput("chat_history"),tags$hr())
      ),
      fluidRow(
        column(11,textAreaInput(inputId = "user_message", placeholder = "Enter your message:", label="USER PROMPT", width = "100%")),
        column(1,actionButton("send_message", "Send",icon = icon("play"),height = "350px"))
      ),style = "background-color: #00A67E")
  ),style = "background-color: #3d3f4e")

server <- function(input, output, session) {
  chat_data <- reactiveVal(data.frame())
  
  # Download model if not present
  observeEvent(input$model_name, {
    if(!(input$model_name %in% model_list$NAME)){
      system(paste0("ollama pull ", input$model_name))
      # Update model list
      model_list <- read.table(text = system("ollama list", intern = TRUE),
                               sep = "\t", row.names = NULL)
      # tabs at the end of each model row adds an additional empty column
      model_list$MODIFIED <- NULL
      colnames(model_list) <- c("NAME", "ID", "SIZE", "MODIFIED")
      model_list$NAME <- trimws(model_list$NAME)
    }
  })
  
  observeEvent(input$send_message, {
    if (input$user_message != "") {
      new_data <- data.frame(source = "User", message = input$user_message, stringsAsFactors = FALSE)
      chat_data(rbind(chat_data(), new_data))
      
      gpt_res <- call_ollama_api(prompt = input$user_message,
                                 model_name = input$model_name,
                                 temperature = input$temperature,
                                 max_length = input$max_length,
                                 sysprompt = input$sysprompt)
      
      if (!is.null(gpt_res)) {
        gpt_data <- data.frame(source = "ollama", message = gpt_res, stringsAsFactors = FALSE)
        chat_data(rbind(chat_data(), gpt_data))
      }
      updateTextInput(session, "user_message", value = "")
    }
  })
  
  call_ollama_api <- function(prompt, model_name, temperature, max_length, sysprompt) {
    json_payload <- paste0('{"model": "', model_name,
                           '", "prompt": "', prompt,
                           '", "system": "', sysprompt,
                           '", "stream": false, "options": {"temperature": ', temperature,
                           ', "num_predict": ', max_length, '}}')
    
    response <- httr::POST(
      url = "http://localhost:11434/api/generate",
      body = json_payload,
      encode = "json"
    )
    return(str_trim(content(response)$response))
  }
  
  output$chat_history <- renderUI({
    chatBox <- lapply(1:nrow(chat_data()), function(i) {
      tags$div(class = ifelse(chat_data()[i, "source"] == "User", "alert alert-secondary", "alert alert-success"),
               HTML(paste0("<b>", chat_data()[i, "source"], ":</b> ", text = chat_data()[i, "message"])))
    })
    do.call(tagList, chatBox)
  })
  
  observeEvent(input$download_button, {
    if (nrow(chat_data()) > 0) {
      session$sendCustomMessage(type = "downloadData", message = "download_data")
    }
  })
}
shinyApp(ui = ui, server = server)
