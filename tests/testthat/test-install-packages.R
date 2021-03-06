context("install packages")

test_that("file://, all clear", {
  path <- tempfile()
  dir.create(path)

  url <- file_url(file.path(TEST_PATH, "base"))
  ans <- install_packages("R6", path, repos = url, type = "source",
                          pubkey = PUBKEY)
  expect_true(file.exists(file.path(path, "R6")))
})

test_that("file://, tampered index", {
  path <- tempfile()
  dir.create(path)
  url <- file_url(file.path(TEST_PATH, "index"))
  expect_error(install_packages("R6", path, repos = url, type = "source",
                                pubkey = PUBKEY),
               "Signature verification failed")
  expect_false(file.exists(file.path(path, "R6")))
})

test_that("file://, tampered file", {
  path <- tempfile()
  dir.create(path)
  url <- file_url(file.path(TEST_PATH, "file"))
  expect_error(install_packages("R6", path, repos = url, type = "source",
                                pubkey = PUBKEY),
               "WHOA THERE")
  expect_false(file.exists(file.path(path, "R6")))
})

test_that("https://, all clear", {
  path <- tempfile()
  dir.create(path)

  url <- file.path(TEST_URL, "base")
  ans <- install_packages("R6", path, repos = url, type = "source",
                          pubkey = PUBKEY)
  expect_true(file.exists(file.path(path, "R6")))
})

test_that("https://, tampered index", {
  path <- tempfile()
  dir.create(path)
  url <- file.path(TEST_URL, "index")
  expect_error(install_packages("R6", path, repos = url, type = "source",
                                pubkey = PUBKEY),
               "Signature verification failed")
  expect_false(file.exists(file.path(path, "R6")))
})

test_that("https://, tampered file", {
  path <- tempfile()
  dir.create(path)
  url <- file.path(TEST_URL, "file")
  expect_error(install_packages("R6", path, repos = url, type = "source",
                                pubkey = PUBKEY),
               "WHOA THERE")
  expect_false(file.exists(file.path(path, "R6")))
})
