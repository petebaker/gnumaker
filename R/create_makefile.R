##' Creates a GNU Makefile assuming standard pattern rules
##'
##' Standard GNU Make pattern rules are available at
##' https://github.com/petebaker/r-makefile-definitions and also with
##' the \code{gnumaker} package. These rules provide a standard way to
##' produce target files given names of one or more dependency
##' files. If a dependency file changes then targets can be updated by
##' invoking \code{make}. For instance, for an R syntax file, a target
##' could be an Rout, html or pdf file. \code{create_makefile} will
##' produce a \code{Makefile} and also check that the relationships
##' specified are a directed acyclic graph (DAG)
##' 
##' @param targets targets specified as a list where the component
##'   names are the targets and the components are a character vector
##'   of dependency file names
##' @param phony .PHONY targets specified as a list where the
##'   component names are the .PHONY targets and the list follows the
##'   same format as \code{targets}
##' @param comments a list of comments to precede each target. By
##'   default, a suitable comment is constructed from target and
##'   dependency file names
##' @param file.exts a list specifying which target file extension
##'   should be used. (Default: Rout for R files, html for Rmd files
##'   and so on. See \code{\link{show_extensions}} for more.)
##'
##' @examples
##' # Create a Makfile for simple data analysis demo 
##' create_makefile(targets = list(read = c("read.R", "simple.csv"),
##'                 linmod = c("linmod.R", "read"),
##'                 rep1 = c("report1.Rmd", "linmod"),
##'                 rep2 = c("report2.Rmd", "linmod")),
##'                 phony = list(all = c("rep1", "rep2")),
##'             comments = list(linmod = "plots and analysis using 'linmod.R'")
##'                 file.exts = list(Rmd = list(rep1 = "pdf", rep2 = "docx")))
##' write_makefile(gm1)
##' plot_makefile(gm1)

create_makefile  <-  function(targets, phony = NULL, comments = NULL,
                              file.exts = NULL){
  
}
