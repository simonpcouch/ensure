test_that("testhelper_env works", {
  expect_identical(testhelper_env(), .testhelper_env)
  expect_type(testhelper_env(), "environment")
})

test_that("retrieve_test_helper uses existing helper when available", {
  if (env_has(.testhelper_env, "last_test_helper")) {
    old_helper <- env_get(.testhelper_env, "last_test_helper")
    withr::defer(env_bind(.testhelper_env, last_test_helper = old_helper))
  }
  env_bind(.testhelper_env, last_test_helper = "boop")
  expect_equal(retrieve_test_helper(), "boop")
})

test_that("retrieve_test_helper creates a new helper when needed", {
  local_mocked_bindings(
    testhelper_env = function() new_environment()
  )

  expect_equal(retrieve_test_helper(), test_helper())
  expect_true("last_test_helper" %in% names(.testhelper_env))
})
