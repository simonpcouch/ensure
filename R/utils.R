.ensure_env <- new_environment()

ensure_env <- function() {
  .ensure_env
}

retrieve_test_helper <- function() {
  ensure_env <- ensure_env()

  if (env_has(ensure_env, "last_test_helper")) {
    return(env_get(ensure_env, "last_test_helper"))
  }

  test_helper()
}

retrieve_test <- function(path) {
  name <- basename(path)
  file <- file.path("tests", "testthat", paste0("test-", name))

  if (file.exists(file)) {
    lines <- readLines(file)
    if (identical(lines, "")) {
      lines <- NULL
    }
  } else {
    lines <- NULL
  }

  usethis::edit_file(file)

  lines
}

neighboring_files <- function(dir = "R/") {
  r_dir_info <- fs::dir_info(dir)
  r_dir_info <- r_dir_info[order(r_dir_info$modification_time, decreasing = TRUE),]
  as.character(r_dir_info$path)
}

append_neighboring_files <- function(path, res) {
  dir <- dirname(path)
  neighboring_files <- neighboring_files(dir)
  if (length(neighboring_files) == 0) {
    return(res)
  }

  neighboring_files <- neighboring_files[
    !basename(neighboring_files) %in% basename(path)
  ]

  # TODO: need some sort of toggle to determine how many recent files
  # should be appending, maybe based on n_tokens?
  for (file in neighboring_files[seq_len(min(length(neighboring_files), 3))]) {
    file_basename <- basename(file)
    if (identical(basename(file), basename(path))) next

    res <- c(
      res,
      "",
      paste0("## Some additional context from the file ", basename(file), ":"),
      "",
      "```",
      readLines(file),
      "```",
      ""
    )

    file_test <- file.path("tests", "testthat", paste0("test-", file_basename))

    if (file.exists(file_test)) {
      res <- c(
        res,
        "",
        paste0("## The tests for that file look like:"),
        "",
        "```",
        readLines(file_test),
        "```",
        ""
      )
    }
  }

  res
}

check_source <- function(path, call = caller_env()) {
  if (!grepl("\\.R$", path, ignore.case = TRUE)) {
    cli::cli_abort("Test helpers can only write tests for .R files.", call = call)
  }

  if (!grepl("/R$", dirname(path))) {
    cli::cli_abort(
      "The file being tested must be inside of a directory called {.code R/}.",
      call = call
    )
  }

  TRUE
}
