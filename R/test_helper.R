#' Initialize a test helper object
#'
#' @description
#' Test helpers are elmer [Chat()][elmer::Chat()]s that know how to write testthat
#' unit tests. This function creates test helpers, though [test_this()] will create
#' test helpers it needs on-the-fly.
#'
#' @param fn A `new_*()` function, likely from the elmer package. Defaults
#'   to [elmer::chat_claude()]. To set a persistent alternative default,
#'   set the `.assure_fn` option; see examples below.
#' @param .ns The package that the `new_*()` function is exported from.
#' @param ... Additional arguments to `fn`. The `system_prompt` argument will
#'   be ignored if supplied. To set persistent defaults,
#'   set the `.assure_args` option; see examples below.
#'
#' @details
#' If you have an Anthropic API key (or another API key and the `test_helper_*()`
#' options) set and this package installed, you are ready to using the addin
#' in any R session with no setup or library loading required; the addin knows
#' to look for your API credentials and will call needed functions by itself.
#'
#' @examplesIf FALSE
#' # to create a chat with claude:
#' test_helper()
#'
#' # or with OpenAI's 4o-mini:
#' test_helper(
#'   "chat_openai",
#'   model = "gpt-4o-mini"
#' )
#'
#' # to set OpenAI's 4o-mini as the default, for example, set the
#' # following options (possibly in your .Rprofile, if you'd like
#' # them to persist across sessions):
#' options(
#'   .assure_fn = "chat_openai",
#'   .assure_args = list(model = "gpt-4o-mini")
#' )
#' @export
test_helper <- function(
    fn = getOption(".assure_fn", default = "chat_claude"),
    ...,
    .ns = "elmer"
  ) {
  args <- list(...)
  default_args <- getOption(".assure_args", default = list())
  args <- modifyList(default_args, args)

  # TODO: just read this once
  args$system_prompt <- test_helper_prompt()

  test_helper <- rlang::eval_bare(rlang::call2(fn, !!!args, .ns = .ns))

  .stash_last_test_helper(test_helper)

  test_helper
}

test_helper_prompt <- function() {
  prompt <- readLines(system.file("system_prompt.md", package = "assure"))

  paste0(prompt, collapse = "\n")
}

.stash_last_test_helper <- function(x) {
  assure_env <- assure_env()
  assure_env[["last_test_helper"]] <- x
  invisible(NULL)
}
