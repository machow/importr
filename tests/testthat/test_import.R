library(importr)

test_that("imports from file", {
  mod <- import('../imports/import1.R')   # loads MASS package
  expect_that(is.numeric(mod$rnorm()), is_true())
})

test_that("imports from expression", {
  mod <- import({library(MASS); rnorm <- function() mvrnorm(1, 0, 1)})
  expect_that(is.numeric(mod$rnorm()), is_true())

})

test_that("imports don't leave packages on search path", {
  mod <- import(library(MASS))
  expect_that(exists('mvrnorm'), is_false())
})

test_that("importing does not allow access to libraries attached after importr", {
  library(MASS)
  mod <- import(x <- exists("mvrnorm"))
  detach(package:MASS) # should move this to a tear down function
  expect_that(mod$x, is_false())
})

test_that("can access packages attached before importr", {
  library(MASS, pos=match('package:importr', search()) + 1)   # puts MASS as parent of importr
  mod <- import(x <- mvrnorm(1,0,1))   # uses package:MASS
  detach(package:MASS)
  expect_is(mod$x, "numeric")
})
