.testhelper_env <- new_environment()

testhelper_env <- function() {
  .testhelper_env
}

retrieve_test_helper <- function() {
  testhelper_env <- testhelper_env()

  if (env_has(testhelper_env, "last_test_helper")) {
    return(env_get(testhelper_env, "last_test_helper"))
  }

  test_helper()
}

open_test <- function(path) {
  name <- basename(path)
  res <- file.path("tests", "testthat", paste0("test-", name))
  usethis::edit_file(res)

  res
}
