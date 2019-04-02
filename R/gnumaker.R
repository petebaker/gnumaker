##' gnumaker: A package for GNU Makefile creation and plotting
##'
##' The gnumaker package has three important functions:
##' \code{create_makefile}, \code{write_makefile}, \code{plot}
##'
##' @section gnumaker functions:
##'
##' \code{GNU Make} is the defacto build system for many programs
##' including the \code{linux} operating system.  Standard GNU Make
##' pattern rules are available at
##' \url{https://github.com/petebaker/r-makefile-definitions} and also with
##' the \code{gnumaker} package.
##'
##' \code{link{create_makefile}} is used to create the text of a
##' \code{Makefile} and also the associated directed acyclic graph
##' (DAG). This object can be written to a \code{Makefile} using
##' \code{\link{write_makefile}} and the DAG may be plotted using
##' \code{\link{plot}}
##'
##' @docType package
##' @name gnumaker
NULL                        
