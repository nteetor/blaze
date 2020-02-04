#' Observe URL paths
#'
#' Observe a URL path and run a handler expression. `handler` is run when the
#' browser navigates to a URL path matching or exactly `path`, see `regex`.
#'
#' @param path A character string specifying a URL path, by default `path` is
#'   treated as a regular expression, see `regex`.
#'
#' @param handler An expression or function to call when the URL path matches
#'   `path`.
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
observePath <- function(path, handler, env = parent.frame(), quoted = FALSE,
                        regex = TRUE, domain = getDefaultReactiveDomain()) {
  h_expr <- exprToFunction(handler, env = env, quoted = quoted)

  o <- observe({
    req(
      nzchar(domain$clientData$url_state)
    )

    uri <- domain$clientData$url_state

    print(uri)

    is_match <- grepl(path, uri, fixed = !regex)

    req(is_match)

    h_expr()
  }, domain = domain)

  invisible(o)
}

#' Path utilities
#'
#' Push a new URL path or get the current path.
#'
#' @param path A character string specifying a new URL path
#'
#' @param session A reactive context, defaults to
#'   `shiny::getDefaultReactiveDomain()`.
#'
#' @export
pushPath <- function(path, session = getDefaultReactiveDomain()) {
  if (!grepl("^/", path)) {
    path <- paste0("/", path)
  }

  path <- utils::URLencode(path)

  session$sendCustomMessage("blaze:pushstate", list(
    path = path
  ))
}

#' @rdname pushPath
#' @export
getPath <- function(session = getDefaultReactiveDomain()) {
  session$clientData$url_state
}
