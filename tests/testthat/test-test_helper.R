test_that("test_helper initializes correctly with defaults", {
  withr::local_options(list(.assure_fn = NULL, .assure_args = NULL))

  expect_no_error(
    result <- test_helper()
  )
  expect_s3_class(result, "Chat")

  expect_equal(result$system_prompt, test_helper_prompt())
})

test_that("test_helper respects custom options", {
  withr::local_options(
    list(
      .assure_fn = "chat_openai",
      .assure_args = list(model = "gpt-4o-mini")
    )
  )

  result <- test_helper()
  expect_s3_class(result, "Chat")
  expect_equal(result$.__enclos_env__$private$provider@model, "gpt-4o-mini")
})

test_that("test_helper_prompt returns expected prompt", {
  res <- test_helper_prompt()
  expect_equal(length(res), 1)
  expect_type(res, "character")
})
