#' Route utilities
#'
#' Push a route or get the current application route.
#'
#' @param path A character string specifying a new route.
#'
#' @param session A reactive context, defaults to
#'   `shiny::getDefaultReactiveDomain()`.
#'
#' @export
pushRoute <- function(path, session = getDefaultReactiveDomain()) {
  if (!grepl("^/", path)) {
    path <- paste0("/", path)
  }

  hash <- paste0("#", path)

  session$sendCustomMessage("blaze:push", list(
    hash = hash
  ))
}

#' @rdname pushRoute
#' @export
getRoute <- function(session = getDefaultReactiveDomain()) {
  hash <- shiny::isolate(session$clientData$url_hash)

  sub("^#", "", hash)
}
