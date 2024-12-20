#' Initialize an ensurer object
#'
#' @description
#' ensurers are ellmer [Chat()][ellmer::Chat()]s that know how to write testthat
#' unit tests. This function creates ensurers, though [ensure_that()] will create
#' ensurers it needs on-the-fly.
#'
#' @param fn A `new_*()` function, likely from the ellmer package. Defaults
#'   to [ellmer::chat_claude()]. To set a persistent alternative default,
#'   set the `.ensure_fn` option; see examples below.
#' @param .ns The package that the `new_*()` function is exported from.
#' @param ... Additional arguments to `fn`. The `system_prompt` argument will
#'   be ignored if supplied. To set persistent defaults,
#'   set the `.ensure_args` option; see examples below.
#'
#' @details
#' If you have an Anthropic API key (or another API key and the `ensure_*()`
#' options) set and this package installed, you are ready to using the addin
#' in any R session with no setup or library loading required; the addin knows
#' to look for your API credentials and will call needed functions by itself.
#'
#' @examplesIf FALSE
#' # to create a chat with claude:
#' ensurer()
#'
#' # or with OpenAI's 4o-mini:
#' ensurer(
#'   "chat_openai",
#'   model = "gpt-4o-mini"
#' )
#'
#' # to set OpenAI's 4o-mini as the default, for example, set the
#' # following options (possibly in your .Rprofile, if you'd like
#' # them to persist across sessions):
#' options(
#'   .ensure_fn = "chat_openai",
#'   .ensure_args = list(model = "gpt-4o-mini")
#' )
#' @export
ensurer <- function(
    fn = getOption(".ensure_fn", default = "chat_claude"),
    ...,
    .ns = "ellmer"
  ) {
  args <- list(...)
  default_args <- getOption(".ensure_args", default = list())
  args <- modifyList(default_args, args)

  ensurer <- rlang::eval_bare(rlang::call2(fn, !!!args, .ns = .ns))
  ensurer$set_system_prompt(ensurer_prompt())

  .stash_last_ensurer(ensurer)

  ensurer
}

ensurer_prompt <- function() {
  prompt <- readLines(system.file("system_prompt.md", package = "ensure"))

  paste0(prompt, collapse = "\n")
}

.stash_last_ensurer <- function(x) {
  ensure_env <- ensure_env()
  ensure_env[["last_ensurer"]] <- x
  invisible(NULL)
}
