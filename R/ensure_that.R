#' Write unit tests for selected code
#'
#' @description
#' This function queries an LLM to write unit tests for selected R code. To do
#' so, it:
#'
#' * Initializes a [ensurer()]: an ellmer [Chat()][ellmer::Chat()] that knows how
#'   to write testthat unit tests.
#' * Reads the contents of the active `.R` file as well as the current selection.
#' * Opens a corresponding test file (creating it if need be).
#' * Asks the LLM to write unit tests for the current selection, using the
#'   contents of the active `.R` file as context.
#' * Streams the response into the corresponding test file.
#'
#' @returns
#' `TRUE`, invisibly.
#'
#' @export
ensure_that <- function() {
  check_positron()

  context <- rstudioapi::getSourceEditorContext()

  check_source(context$path)

  ensurer <- retrieve_ensurer()

  test_lines <- retrieve_test(context$path)

  # retrieve_test() will navigate to the test file, so:
  test_context <- rstudioapi::getSourceEditorContext()
  navigate_to_last_line(test_context)

  turn <- assemble_turn(context, test_lines)

  tryCatch(
    streamy::stream(ensurer$stream(turn), interface = "suffix"),
    error = function(e) {
      rstudioapi::showDialog(
        "Error",
        paste("The ensurer ran into an issue: ", e$message)
      )
    }
  )

  invisible(TRUE)
}

assemble_turn <- function(context, test_lines) {
  selection <- rstudioapi::primary_selection(context)$text

  if (identical(selection, "")) {
    res <- c(
      "## Context and Selection",
      "",
      "The context and selection are the same; write tests for the whole file: ",
      "",
      context$contents
    )
  } else {
    res <-
      c(
        "## Context",
        "",
        context$contents,
        "",
        "Now, here's the selection you'll write tests for.",
        "",
        "## Selection",
        "",
        selection
      )
  }

  if (!is.null(test_lines)) {
    res <- c(
      res,
      "",
      "The current tests look like this:",
      "",
      test_lines,
      "",
      "Do your best to pattern-match how the existing tests create objects to test against.",
      ""
    )
  }

  res <- append_neighboring_files(context$path, res)

  res <- c(
    res,
    "Remember to reply with tests for _only_ the provided selection.",
    "Respond with only code; do not prefix the reply with any explanation.",
    "Do not prefix or suffix the code block with backticks."
  )

  paste0(res, collapse = "\n")
}

navigate_to_last_line <- function(context) {
  n_lines <- length(context$contents)

  # if there's no trailing newline, add one
  if (!identical(context$contents[length(context$contents)], "")) {
    last_line_start <- rstudioapi::document_position(n_lines, 1)
    last_line_end <- rstudioapi::document_position(n_lines, 100000)

    rstudioapi::modifyRange(
      rstudioapi::document_range(last_line_start, last_line_end),
      paste0(context$contents[n_lines], "\n"),
      id = context$id
    )

    n_lines <- n_lines + 1
  }

  new_loc <- rstudioapi::document_position(n_lines, 1)
  rstudioapi::setSelectionRanges(rstudioapi::document_range(new_loc, new_loc))

  invisible()
}
