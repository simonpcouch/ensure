test_that("ensure_env works", {
  expect_identical(ensure_env(), .ensure_env)
  expect_type(ensure_env(), "environment")
})

test_that("retrieve_ensurer uses existing ensurer when available", {
  if (env_has(.ensure_env, "last_ensurer")) {
    old_ensurer <- env_get(.ensure_env, "last_ensurer")
    withr::defer(env_bind(.ensure_env, last_ensurer = old_ensurer))
  }
  env_bind(.ensure_env, last_ensurer = "boop")
  expect_equal(retrieve_ensurer(), "boop")
})

test_that("retrieve_ensurer creates a new ensurer when needed", {
  local_mocked_bindings(
    ensure_env = function() new_environment()
  )

  expect_equal(retrieve_ensurer(), ensurer())
  expect_true("last_ensurer" %in% names(.ensure_env))
})

test_that("check_source checks R file extensions and paths", {
  expect_true(check_source("R/example.R"))
  expect_true(check_source("R/example.r"))
  expect_true(check_source("R/path/to/file.R"))
  expect_true(check_source("R/deeply/nested/path/file.R"))

  expect_snapshot(error = TRUE, check_source("example.txt"))
  expect_snapshot(error = TRUE, check_source("inst/example.R"))
})
