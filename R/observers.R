#' Observe routes
#'
#' Observe a route path and run a handler expression. When the route specified
#' by `path` is browsed to `handler` will be run.
#'
#' @param path A character string specifying a route path, by default `path` is
#'   treated as a regular expression, see `regex`.
#'
#' @param handler An expression or function to call when the uri matches `path`.
#'
#' @param env The parent environment of `handler`, defaults to the calling
#'   environment.
#'
#' @param quoted One of `TRUE` or `FALSE` specifying if `handler` is a quoted
#'   expression. If `TRUE`, the expression must be quoted with `quote()`.
#'
#' @param regex One of `TRUE` or `FALSE` specifying if `path` is treated as a
#'   regular expression, defaults to `TRUE`.
#'
#' @param domain A reactive context, defaults to
#'   `shiny::getDefaultReactiveDomain()`.
#'
#' @export
observeRoute <- function(path, handler, env = parent.frame(), quoted = FALSE,
                         regex = TRUE,
                         domain = getDefaultReactiveDomain()) {
  h_expr <- shiny::exprToFunction(handler, env = env, quoted = quoted)

  o <- observe({
    req(
      nzchar(domain$clientData$url_hash)
    )

    url <- sub("^#", "", domain$clientData$url_hash)

    is_match <- grepl(path, url, fixed = !regex)

    req(is_match)

    h_expr()
  }, domain = domain)

  invisible(o)
}
