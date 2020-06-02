#' @importFrom shiny
#'   getDefaultReactiveDomain exprToFunction observe isolate req
#' @importFrom fs
#'   path path_file path_rel path_package
#'   file_create
#'   dir_ls dir_exists dir_create dir_delete dir_walk
#' @importFrom rematch2
#'   re_match re_match_all
NULL

#' Observe and push URL paths
#'
#' @description
#'
#' The `blaze` package allows a shiny app to simulate the multi-paging
#' behaviour of a typical web application. Using `blaze` you can walk users
#' through a shiny app and let them traverse with browsers' forward and back
#' buttons.
#'
#' Using path link elements (a variation of standard hyperlinks) users can
#' browse to different URL paths. A shiny application can detect these changes
#' with `observePath()` allowing you to update tab sets or other dynamic
#' elements within the application. `pushPath()` lets you redirect the user from
#' the server.
#'
#' Because of how shiny handles URL paths be sure to run the
#' `paths()` function before launching an application.
#'
#' @name blaze
"_PACKAGE"

#' @section Including in a shiny app:
#'
#' To use blaze with a shiny application the `blaze()` function must be called
#' inside the application's UI.
#'
#' @rdname blaze
#' @export
blaze <- function() {
  htmltools::htmlDependency(
    name = "blaze",
    version = packageVersion("blaze"),
    src = c(
      file = path_package("blaze", "www", "js"),
      href = "blaze/js"
    ),
    script = "blaze.js"
  )
}
