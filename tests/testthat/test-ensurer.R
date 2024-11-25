test_that("ensurer initializes correctly with defaults", {
  withr::local_options(list(.ensure_fn = NULL, .ensure_args = NULL))

  expect_no_error(
    result <- ensurer()
  )
  expect_s3_class(result, "Chat")

  expect_equal(result$system_prompt, ensurer_prompt())
})

test_that("ensurer respects custom options", {
  withr::local_options(
    list(
      .ensure_fn = "chat_openai",
      .ensure_args = list(model = "gpt-4o-mini")
    )
  )

  result <- ensurer()
  expect_s3_class(result, "Chat")
  expect_equal(result$.__enclos_env__$private$provider@model, "gpt-4o-mini")
})

test_that("ensurer_prompt returns expected prompt", {
  res <- ensurer_prompt()
  expect_equal(length(res), 1)
  expect_type(res, "character")
})
