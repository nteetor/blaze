library(shiny)
# library(blaze)

options(shiny.launch.browser = TRUE)

blaze::paths(
  "explore"
)

shinyApp(
  ui = fluidPage(
    blaze(),
    tags$nav(
      pathLink("/explore", "Explore")
    ),
    uiOutput("explore")
  ),
  server = function(input, output, session) {
    state <- reactiveValues(explore = NULL)

    observePath("/explore", {
      state$explore <- div(
        h5("Explore"),
        pathLink("/explore/fish", "Fish"),
        pathLink("/explore/birds", "Birds")
        # pathLink(sprintf("/explore/%s", input$other), "Other"),
        # textInput("other", "Other animal")
      )
    })

    observePath("/explore/:animal", {
      state$explore <- div(
        h5("Explore", blaze:::param("animal"))
      )
    })

    # observePath("/explore/:animal/:species", {
    #   state$page <- div(
    #     pathLink()
    #   )
    # })

    output$explore <- renderUI(state$explore)
  }
)
