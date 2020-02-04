# blaze

Observe changes to the URI and react to them.

## Usage

The `blaze` package allows a shiny app to simulate the multi-paging behaviour of
a typical web application. Using `blaze` you can walk users through a shiny app
and let them traverse with browsers' forward and back buttons.

Using path link elements (a variation of standard hyperlinks) users can browse
to different URL paths. A shiny application can detect these changes with
`observePath()` allowing you to update tab sets or other dynamic elements within
the application. `pushPath()` lets you redirect the user from the server.

Because of how shiny handles URL paths be sure to run the `paths()` function
before launching an application.

## Example

```R
# install.packages("remotes")
remotes::install_github("nteetor/blaze")
library(shiny)

options(shiny.launch.browser = TRUE)

blaze::paths(
  "hello/world"
)

shinyApp(
  ui = fluidPage(
    tags$head(
      tags$script(src = "blaze/js/blaze.js")
    ),
    blaze::pathLink(href = "/hello/world", "Hello, world!"),
    textOutput("msg")
  ),
  server = function(input, output, session) {
    state <- reactiveValues(msg = NULL)
    
    blaze::observePath(".*", {
      state$msg <- blaze::getPath()
    })
    
    output$msg <- renderText({
      state$msg
    })
  }
)

```

## Installation

I couldn't say if and when this package will be on CRAN. 

```R
# install.packages("remotes")
remotes::install_github("nteetor/blaze")
```

## Other work

* [`{shiny.router}`](https://github.com/Appsilon/shiny.router) seems
  to do something similar, I needed a simpler toolset
* `{shiny}` has its own tools for retrieving the uri hash and reacting to uri
  changes, you could get by without blaze
