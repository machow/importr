#' Merge two environments
#'
#' Adapted from (http://stackoverflow.com/a/26694214/1144523)
mergeEnv = function(e1, e2) {
  listE1 = ls(e1)
  listE2 = ls(e2)
  for(v in listE2) {
    if(v %in% listE1) warning(sprintf("Variable %s is in e1, too!", v))
    e1[[v]] = e2[[v]]
  }
}

#' Creates the parent environment used by import
#'
#' This function makes importing possible by creating a chain of environments:
#' (1) the depends environment, which contains all objects attached via calls to
#' library or require.
#' (2) the import environment, this environment has functions to override calls to
#' the base library and require.
#' (3) the local environment, which will be returned by import.
#'
#' @param from a package on the search path that will be initial parent environment
#' @export
#' @examples
#' env <- new_env_chain('package:importr')
new_env_chain <- function(from) {
  sp <- search()
  depends <- new.env(parent=as.environment(match(from, sp)))
  imports <- new.env(parent=depends)
  imports$library <- function(package, ...){
    pkg_name = as.character(substitute(package))
    message(paste0('calling local library function for package: ', pkg_name))
    ns <- loadNamespace(pkg_name, ...)
    mergeEnv(depends, ns)
    assign(pkg_name, ns, envir=imports)
  }
  imports$require <- function(package, ...){
    pkg_name = as.character(substitute(package))
    message(paste0('calling local require function for package: ', pkg_name))
    ns <- requireNamespace(pkg_name, ...)
    mergeEnv(depends, ns)
    assign(pkg_name, ns, envir=imports)
  }
  imports
}

#' Import a script or evaluate expression without the Global Environment
#'
#' This function isolates R scripts and code, so they can attach libraries
#' and load namespaces without affecting other scripts or the Global Environment.
#' Importantly, this isolation makes the environment returned like an R package,
#' in that changes to the Global Environment will not affect it.
#'
#' @param file path to source file, or code to evalue. May also be a URL.
#' @param passed directly to source function.
#' @export
#' @return the environment in which the code was evaluated
#' @examples
#' module <- import({
#'  library(MASS)
#'  gen_data <- function() mvrnorm(10, 0, 1)
#' })
#' module$gen_data()                       # can use MASS::mvrnorm
#' stopifnot(exists("mvrnorm") == FALSE)   # MASS package not attached
#' mvrnorm <- NULL
#' module$gen_data()                       # still works
import <- function(file, chdir=TRUE) {
  env <- new.env(parent=new_env_chain('package:importr'))

  if (is.character(substitute(file)))
    source(file, local = env, chdir=chdir)
  else
    eval(substitute(file), env)

  env
}

.onAttach <- function(libname, pkgname) {
  packageStartupMessage("--- importr, python-like importing for R ---")
}
