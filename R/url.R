#' Observe URL paths
#'
#' Observe a URL path and run a handler expression. `handler` is run when the
#' browser navigates to a URL path matching `path`.
#'
#' @param path A character string specifying a URL path, by default `path` is
#'   treated as a regular expression, passed `fixed = TRUE` to disable this
#'   behaviour.
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
#' @param ... Additional arguments passed to `grepl()`.
#'
#' @param domain A reactive context, defaults to
#'   [shiny::getDefaultReactiveDomain()].
#'
#' @export
observePath <- function(path, handler, env = parent.frame(), quoted = FALSE,
                        ..., domain = getDefaultReactiveDomain()) {
  # h_expr <- exprToFunction(handler, env = env, quoted = quoted)
  h_quo <- rlang::quo_set_env(rlang::enquo(handler), env)

  path <- as_route(path)

  o <- observe({
    url <- domain$clientData$url_state

    req(!is.null(url))

    is_match <- grepl(pattern = path, x = url, ..., perl = TRUE)

    req(is_match)

    mask <- mask_params(path, url)

    isolate(rlang::eval_tidy(h_quo, mask, env))
  }, domain = domain)

  invisible(o)
}

as_route <- function(x) {
  params <- re_match_all(x, "/:(?<param>[^/]*)")$param[[1]]

  if (length(params)) {
    stopifnot(
      all(grepl("^[a-zA-Z]+$", params)),
      !anyDuplicated(params)
    )

    x <- gsub("/:([^/]*)", "/(?<\\1>[^/]+)", x)
  }

  if (!grepl("^[\\^]", x)) {
    x <- paste0("^", x)
  }

  if (!grepl("[$]$", x)) {
    x <- paste0(x, "$")
  }

  x
}

mask_params <- function(path, url) {
  matches <- re_match(url, path)

  if (NCOL(matches) == 2) {
    return(NULL)
  }

  params <- as.list(matches[1, seq_len(NCOL(matches) - 2)])

  # not good
  list(param = function(x) {
    sym_x <- rlang::ensym(x)
    name_x <- rlang::as_name(sym_x)
    params[[name_x]]
  })
}

param <- function(x, params = peek_params()) {
  sym_x <- rlang::ensym(x)
  name_x <- rlang::as_name(sym_x)
  params[[name_x]]
}

peek_params <- function() {
  emptyenv()
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
