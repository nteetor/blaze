#' Go to paths
#'
#' The `pathLink()` function creates a special `tags$a()` element. These links
#' let the user browse to different parts of your application without refreshing
#' the current page.
#'
#' @export
pathLink <- function(..., href) {
  if (missing(href)) {
    stop("please specify `href`")
  }

  htmltools::a(..., href = href, `data-blaze` = NA)
}
