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
#'   `shiny::getDefaultReactiveDomain()`.
#'
#' @param x A bare name specifying a URL
#'
#' @section `param()` and `query()`:
#'
#' You may want a handler expression to use information from or pieces of a URL.
#' Currently, two helper functions exist to extract information from the URL.
#'
#' With `param()` we can capture pieces of the URL path if `path` is a regular
#' expression. To capture a portion of the URL we need to use regular expression
#' named capture groups. Here is an example, `"/about/(?<subject>[a-z]+)"`. In
#' this example we have a param named subject. To get this value we can call
#' `param(subject)` in the handler expression.
#'
#' With `query()` we can check for values in the URL's query string. In the URL
#' `https://demo.org/?p=10&view=all` the query string contains `p` and `view`
#' with values `10` and `"all"`, respectively. To check for these values we can
#' call `query(p)` and `query(view)` inside our handler expression. If the values
#' are not present in the query string `NULL` is returned.
#'
#' @export
observePath <- function(path, handler, env = parent.frame(), quoted = FALSE,
                        ..., domain = getDefaultReactiveDomain()) {
  # h_expr <- exprToFunction(handler, env = env, quoted = quoted)
  h_quo <- rlang::quo_set_env(rlang::enquo(handler), env)

  path <- as_route(path)

  o <- observe({
    url <- domain$clientData$url_state
    search <- domain$clientData$url_search_object

    req(!is.null(url))

    is_match <- grepl(pattern = path, x = url, ..., perl = TRUE)

    req(is_match)

    mask <- url_mask(path, url, search)

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

url_mask <- function(path, url, search) {
  matches <- re_match(url, path)
  e <- rlang::new_environment()

  if (NCOL(matches) > 2) {
    params <- as.list(matches[1, seq_len(NCOL(matches) - 2)])

    param_local <- function(x) {
      sym_x <- rlang::ensym(x)
      name_x <- rlang::as_name(sym_x)
      params[[name_x]]
    }

    e$param <- param_local
  }

  if (length(search) > 0) {
    search <- as.list(search)

    query_local <- function(x) {
      sym_x <- rlang::ensym(x)
      name_x <- rlang::as_name(sym_x)
      search[[name_x]]
    }

    e$query <- query_local
  }

  rlang::new_data_mask(bottom = e)
}

#' @rdname observePath
#' @export
param <- function(x) {
  invisible()
}

#' @rdname observePath
#' @export
query <- function(x) {
  invisible()
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
