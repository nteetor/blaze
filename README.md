# blaze

Navigate URL paths with shiny.

## Usage

The `blaze` package allows a shiny app to simulate the navigation behaviour of a
multi-page web application. Users can step back through your application's
states using the browser's back and forward buttons.

Include `pathLink()`s so users can browse to different URL paths within your
application. Then with `observePath()` the shiny server can detect changes to
the URL. This lets the server update tab sets or adjust other dynamic elements
depending on where the user browses to. If an application needs to redirect a
user to a new URL path `pushPath()` does exactly that.

_Please note, at this time Internet Explorer is not supported._

## Getting started

There are two functions required to use `blaze` with a shiny application.

`paths()` must be called before launching an application. This function creates
a series of redirects for the paths specified.

```R
blaze::paths(
  "home",
  "about",
  "explore"
)
```

The second function is `blaze()`, which must be called inside the UI of a shiny
application.

```R
ui <- fluidPage(
  blaze(),
  ". . ."
)
```

## Examples

This example highlights the `pathLink()` function. Using `pathLink()` users
navigate to new URL paths. Notice the application page does not fully refresh
when following the link. After clicking one of the links try clicking the
browser's back button.

```R
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
```

## Installation

The development version may be installed from GitHub.

```R
# install.packages("remotes")
remotes::install_github("nteetor/blaze")
```

## Other work

* [shiny.router](https://github.com/Appsilon/shiny.router) uses hash fragments
  to do similar paging, they may offer better IE support

