##' Write a GNU Makefile object to a Makefile
##'
##' Standard GNU Make pattern rules are available at
##' https://github.com/petebaker/r-makefile-definitions and also with
##' the \code{gnumaker} package. These rules provide a standard way to
##' produce target files given names of one or more dependency
##' files. If a dependency file changes then targets can be updated by
##' invoking \code{make}. Use this function to write a Makefile to the
##' current directory from a \code{gnu_makefile} object created using
##' \code{\link{create_makefile}}
##'
##' @param x object of class \code{gnu_makefile}
##' @param file the name of the file where GNU Make commands are
##'   written, Default: \code{Makefile}
##' @param preamble Text to write at top of file. Default: Filename,
##'   Date, message stating created by \code{gnumaker} package and
##'   version. Set to \dQuote{} to supress preamble
##' @param \\dots options passed to cat for writing \code{Makefile}
##'
##' @examples
##' # Create a Makfile for simple data analysis demo 
##' gm1 <-
##'   create_makefile(targets = list(read = c("read.R", "simple.csv"),
##'                   linmod = c("linmod.R", "read"),
##'                   rep1 = c("report1.Rmd", "linmod"),
##'                   rep2 = c("report2.Rmd", "linmod")),
##'                   target.all = c("rep1", "rep2"),
##'                   all.exts = list(rep1 = "pdf", rep2 = "docx"),
##'                   comments = list(linmod = "plots and analysis using 'linmod.R'"))
##' write_makefile(gm1)
##' 
##' @seealso \code{\link{create_makefile}} \code{\link{plot}}
##' @export
write_makefile <- function(x, file = "Makefile", preamble = NULL, ...){
    if (class(x) != "gnu_makefile")
      stop("'x' must be of class 'gnu_makefile'")

    if (length(preamble) == 0){
      preamble <- 
        c(paste("# File:", file),
          paste("# Created at:", date()), "",
          paste("# Produced by gnumaker: ", utils::packageVersion("gnumaker"), "on",
                base::R.version.string),
          "# Before running make, please check file and edit if necessary", "")
    } 
    
    fileConn <- file(file)
    writeLines(c(preamble, x$gnu_makefile), fileConn, ...)
    close(fileConn)

    cat("File:", file, "written at", date(), "\n")
}
