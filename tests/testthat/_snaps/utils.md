# check_source checks R file extensions and paths

    Code
      check_source("example.txt")
    Condition
      Error:
      ! ensurers can only write tests for .R files.

---

    Code
      check_source("inst/example.R")
    Condition
      Error:
      ! The file being tested must be inside of a directory called `R/`.

