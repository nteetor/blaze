.globals <- new.env(parent = emptyenv())

paths_init <- function() {
  if (is.null(.globals$paths)) {
    .globals$paths <- list()
  }

  lapply(names(.globals$paths), paths_remove)
}

paths_add <-function(p, dir) {
  cat(sprintf("%s => %s", p, dir))
  shiny::addResourcePath(p, dir)
  .globals$paths[[p]] <- dir
}

paths_remove <- function(p) {
  cat(sprintf("%s => *", p))
  shiny::removeResourcePath(p)
  .globals$paths[[p]] <- NULL
}

paths <- function(...) {
  args <- lapply(list(...), as_paths)
  routes <- unique(unlist(args))
  tmp <- path(tempdir(check = TRUE), "blaze")

  paths_init()
  dir_create(tmp)

  old <- setwd(tmp)
  on.exit(setwd(old))

  lapply(routes, function(route) {
    dir_create(route)
  })

  dirs <- dir_ls(tmp, recurse = FALSE, type = "directory")
  prefixes <- path_file(dirs)

  Map(p = prefixes, dir = dirs, paths_add)

  dir_walk(recurse = TRUE, type = "directory", fun = function(d) {
    index <- file_create(path(d, "index.html"))

    cat(file = index, sprintf("
      <!DOCTYPE html>
      <html>
      <head><script>window.location.replace(\"/?redirect=%s\")</script></head>
      <body>Redirect to /</body>
      </html>", d
    ))
  })

  invisible(tmp)
}

as_paths <- function(x, ...) {
  UseMethod("as_paths", x)
}

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

as_paths.list <- function(x, ...) {
  x <- unlist(x)

  if (!is.character(x)) {
    stop("expecting character strings in yml")
  }

  as_paths.character(x)
}

as_paths.yml <- function(x, ...) {
  as_paths.list(unclass(x))
}

as_paths.fs_path <- function(x, ...) {
  if (!dir_exists(x)) {
    stop("expecting directory path")
  }

  dirs <- dir_ls(path = x, recurse = TRUE, type = "directory")

  as.character(path_rel(dirs, x))
}
