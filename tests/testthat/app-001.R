library(shiny)
library(blaze)

options(shiny.launch.browser = TRUE)

blaze::paths(
  "home",
  "about",
  "explore"
)

shinyApp(
  ui = fluidPage(
    blaze(),
    tags$nav(
      pathLink("/home", "Home"),
      pathLink("/about", "About"),
      pathLink("/explore", "Explore")
    ),
    uiOutput("page")
  ),
  server = function(input, output, session) {
    state <- reactiveValues(page = NULL)

    observePath("/home", {
      state$page <- "Home is where the heart is."
    })

    observePath("/about", {
      state$page <- "About this, about that."
    })

    observePath("/explore", {
      state$page <- div(
        p("Curabitur blandit tempus porttitor."),
        p("Vivamus sagittis lacus augue rutrum dolor auctor.")
      )
    })

    output$page <- renderUI(state$page)
  }
)
