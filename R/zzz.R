.onLoad <- function(pkg, lib) {
  shiny::addResourcePath("blaze", system.file("www", package = "blaze"))
}
