.globals <- new.env(parent = emptyenv())

paths_init <- function() {
  if (is.null(.globals$paths)) {
    .globals$paths <- list()
  }

  lapply(names(.globals$paths), paths_remove)

  invisible()
}

paths_add <-function(p, dir) {
  cat(sprintf("%s => %s", p, dir), "\n")
  shiny::addResourcePath(p, dir)
  .globals$paths[[p]] <- dir
}

paths_remove <- function(p) {
  cat(sprintf("%s => *", p), "\n")
  shiny::removeResourcePath(p)
  dir_delete(.globals$paths[[p]])
  .globals$paths[[p]] <- NULL
}

#' Declare Paths for Use with Shiny
#'
#' Declare path endpoints that will be available inside your Shiny app. This
#' function should be called before the call to [shiny::shinyApp()] in your
#' `app.R` file or inside your `server.R` script before the server function.
#' This function makes it possible for users to enter your app URL with a path,
#' e.g. `<myapp.com>/about`, and be directed to the `"about"` page within your
#' Shiny app.
#'
#' @examples
#' \dontrun{
#' library(shiny)
#' library(blaze)
#'
#' options(shiny.launch.browser = TRUE)
#'
#' blaze::paths(
#'   "home",
#'   "about",
#'   "explore"
#' )
#'
#' shinyApp(
#'   ui = fluidPage(
#'     blaze(),
#'     tags$nav(
#'       pathLink("/home", "Home"),
#'       pathLink("/about", "About"),
#'       pathLink("/explore", "Explore")
#'     ),
#'     uiOutput("page")
#'   ),
#'   server = function(input, output, session) {
#'     state <- reactiveValues(page = NULL)
#'
#'     observePath("/home", {
#'       state$page <- "Home is where the heart is."
#'     })
#'
#'     observePath("/about", {
#'       state$page <- "About this, about that."
#'     })
#'
#'     observePath("/explore", {
#'       state$page <- div(
#'         p("Curabitur blandit tempus porttitor."),
#'         p("Vivamus sagittis lacus augue rutrum dolor auctor.")
#'       )
#'     })
#'
#'     output$page <- renderUI(state$page)
#'   }
#' )
#' }
#'
#' @param ... Path names as character strings that will be valid entry points
#'   into your Shiny app.
#'
#' @param app_path The name of the sub-directory where your Shiny app is hosted,
#'  e.g. `host.com/<app_path>/`.
#'
#' @return Invisibly writes temporary HTML files to be hosted by Shiny to
#'   redirect users to the requested path within your Shiny app. The [paths()]
#'   function returns the temporary folder used by \pkg{blaze}.
#'
#' @export
paths <- function(..., app_path = NULL) {
  args <- lapply(list(...), as_paths)
  routes <- unique(unlist(args))
  tmp <- path(tempdir(check = TRUE), "blaze")

  paths_init()
  dir_create(tmp)

  old <- setwd(tmp)
  on.exit(setwd(old))

  .globals$app_path <- if (!is.null(app_path)) {
    app_path <- gsub("^/|/$", "", app_path)
    dir_create(app_path, recurse = TRUE)
    app_path
  }

  lapply(routes, function(route) {
    if (!is.null(app_path)) route <- path(app_path, route)
    dir_create(route)
  })

  app_dir <- if (is.null(app_path)) tmp else path(tmp, app_path)
  dirs <- dir_ls(app_dir, recurse = FALSE, type = "directory")
  prefixes <- path_file(dirs)

  Map(p = prefixes, dir = dirs, paths_add)

  dir_walk(app_dir, recurse = TRUE, type = "directory", fun = function(d) {
    index <- file_create(path(d, "index.html"))

    if (!grepl("^/", d)) {
      d <- paste0("/", d)
    }

    app_redirect <- if (is.null(app_path)) "" else paste0("/", app_path)

    cat(file = index, sprintf("
      <!DOCTYPE html>
      <html>
      <head><script>
      // blaze: redirect /<pathname> to Shiny app using URL search query
      let {origin, pathname, search, hash} = window.location
      search = (search ? search + '&' : '?') + `redirect=${pathname}`
      window.location.replace(origin + '%s' + search + hash)
      </script></head>
      <body>Redirecting</body>
      </html>", app_redirect
    ))
  })

  invisible(tmp)
}

as_paths <- function(x, ...) {
  UseMethod("as_paths", x)
}

#' @export
as_paths.character <- function(x, ...) {
  n <- names(x)

  vapply(seq_along(x), function(i) {
    path <- x[[i]]

    if (!is.null(n[[i]])) {
      base <- gsub("(?:\\d*$|\\.)", "/", n[[i]])
      path <- paste0(base, path)
    }

    path
  }, character(1))
}

#' @export
as_paths.list <- function(x, ...) {
  x <- unlist(x)

  if (!is.character(x)) {
    stop("expecting character strings in yml")
  }

  as_paths.character(x)
}

#' @export
as_paths.yml <- function(x, ...) {
  as_paths.list(unclass(x))
}


path_app <- function(path) {
  if (!grepl("^/", path)) {
    path <- paste0("/", path)
  }

  if (!is.null(.globals$app_path)) {
    path <- paste0("/", .globals$app_path, path)
  }

  path
}
