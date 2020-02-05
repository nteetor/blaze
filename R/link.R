#' Go to paths
#'
#' The `pathLink()` function creates a special `tags$a()` element. These links
#' let the user browse to different parts of your application without refreshing
#' the current page.
#'
#' @param ... Arguments passed to `htmltools::a()`.
#'
#' @param href A character string specifying the URL path to navigate to.
#'
#' @export
pathLink <- function(href, ...) {
  stopifnot(is.character(href))

  htmltools::a(..., href = href, `data-blaze` = NA)
}
