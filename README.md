# shiny_ollama - Chat with ollama using Shiny

### An ollama playground - ChatGPT Clone using ollama built using the R programming language and the Shiny framework. 

The purpose of this application is to allow users to chat with the open-source AI LLM framework, [ollama](https://ollama.ai/), and explore its capabilities. The user can interact with the AI assistant in a chat-like interface, and the assistant will provide responses based on the selected GPT model.

# Download & Install

At this time, ollama is only available for Linux & macOS (Requires macOS 11 Big Sur or later), Windows is coming soon.

Downloading and installing ollama on Linux is one command:

`curl https://ollama.ai/install.sh | sh`

For macOS, go to [https://ollama.ai/download/mac](https://ollama.ai/download/mac).

# Model

I've included a limited number of the available models in the dropdown. If you haven't pulled the model, the shiny app will do this for you.

Alternatively you could pull the model yourself using:

`ollama pull llama2`

# Interface

![](https://raw.githubusercontent.com/TroyHernandez/shiny_ollama/main/uiexample.png)

# Features

* Model selection: Users can select from different models, such as "llama2", "mistral", "orca-mini", and "codellama". Each model has different capabilities and response times.

# Try it locally! 🚀

Serve on your local network (unsecured) and access it at 192.168.1.xxx:3838 (where 192.168.1.xxx is replaced with your actual ip address):

You need to have R installed and the packages at the top of `shiny_ollama.R` installed, then fire up an R console from your terminal:

`R`

then start up the shiny server:

`shiny::shinyAppFile(appFile = "shiny_ollama.R", options = list(host = "192.168.1.xxx", port = 3838))`

*To find your ip address, open your terminal and type ifconfig. Look for the inet address under your active network connection (often en0 or en1).

Currently working on my Ubuntu with Firefox, but not Chrome ¯\_(ツ)_/¯*

**Thanks to @tolgakurtuluss for building the initial chatGPT Shiny app.**
