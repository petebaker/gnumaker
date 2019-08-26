##' Displaya information about file extension names for GNU Make pattern rules
##'
##' \code{info_rules} displays target filename extensions for dependency files
##'
##' GNU Make pattern rules allow wildcarding so that generic rules may
##' be reused based on the filename extensions of the target file and
##' first dependecy file. \code{info_rules} aids construction of
##' Makefiles by displaying possible target file name extensions given
##' a dependency file name extension. Alternatively, it can list all
##' possible dependency file name extensions employed with the
##' \code{\link{gnumaker}} package.
##'
##' @param dependency.ext \code{string} specifying the filename
##'     extension to obtain a description of possible target file
##'     extensions. Default: \dQuote{R}
##' @param list.all \code{logical} indicating whether to list all
##'     possible dependency filename extensions. Default: FALSE
##'
##' @return Nothing is returned but instead information is printed
##'
##' @examples
##' info_rules(list.all = TRUE)
##' info_rules("Rmd")
##'
##' @seealso \code{\link{create_makefile}}
##' @export
info_rules <- function(dependency.ext = "R", list.all = FALSE){

  ## from file 'r-rules.mk' in r-makefile-rules Version 0.3 rc2
  make_rules_exts <- dep_targ_definitions$dep_targs
  all_default_exts <- dep_targ_defaults
  dep_exts <- names(dep_targ_definitions$extras$dep_targs_all)
  EX <- "example1"

  if (list.all) {
    cat("Dependency file name extensions:\n")
    print(dep_exts)
    return(NULL)
  }
  if (! dependency.ext %in% dep_exts)
    stop("Dependency file name extension not valid")
  if (length(dependency.ext)>1){
    warning("More than one file extension specified. Only first one described.")
  dependency.ext <- dependency.ext[1]
  }

  cat(paste0("Possible filename extensions for '", dependency.ext, "':\n"))
  print(dep_targ_definitions$extras$dep_targs_all[[dependency.ext]])
  cat(paste0("\nDefault: '", targext <- all_default_exts[[dependency.ext]],
             "'\n\n"))
  cat("Example rule:\n")
  cat(paste0(EX, ".", targext, ": ", EX, ".", dependency.ext,
             " dep_file2 dep_file3\n"))

  if (dependency.ext %in% c("Rmd", "rmd")){
    cat("\nOther options are available for R Markdown files, such as:\n\n")
    cat(paste0(EX, "_ioslides.html: ", EX, ".", dependency.ext,
             " dep_file2 dep_file3\n"))
    cat(paste0(EX, "_beamer.pdf: ", EX, ".", dependency.ext,
             " dep_file2 dep_file3\n\n"))
    cat("to produce ioslide and beamer presentation formats.\n")
  }

  if (dependency.ext %in% c("Rmd", "rmd", "Rnw", "rnw")){
    cat("\nAn R syntax file can be produced with\n")
    cat(paste0("  make ", EX, "-syntax.R\n"))
    cat("and a similar rule can be specified if necessary with\n")
    cat(paste0(EX, "-syntax.R: ", EX, ".", dependency.ext,
             " dep_file2 dep_file3\n"))
  }

  invisible()
}
