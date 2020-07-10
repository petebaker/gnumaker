##' Information on available file extensions for GNU Make pattern rules
##'
##' \code{info_rules} displays filename extensions for target and dependency files
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
##' @param list.defaults \code{logical} list default target extensions for
##'     all dependency filename extensions? Default: FALSE
##' @param list.targets.all \code{logical} list all possible target extensions for
##'     all rules? Default: FALSE
##'
##' @return Nothing is returned but instead information is printed
##'
##' @examples
##' info_rules(list.all = TRUE)
##' info_rules("Rmd")
##'
##' @seealso \code{\link{create_makefile}}
##' @export
info_rules <- function(dependency.ext = "R", list.all = FALSE, list.defaults = FALSE,
                       list.targets.all = FALSE){

  ## from file 'r-rules.mk' in r-makefile-rules Version 0.3 rc2
  make_rules_exts <- dep_targ_definitions$dep_targs
  all_default_exts <- dep_targ_defaults
  dep_exts <- names(dep_targ_definitions$extras$dep_targs_all)
  EX <- "example1"

  ## list all dependency file extensions if TRUE ------------------------
  if (list.all) {
    cat("Dependency file name extensions:\n")
    print(dep_exts)
    cat("\n For information about possible targets for dependency \"DEPENDENCY EXTENSION\",\n   use 'info_rules(\"DEPENDENCY EXTENSION\")'\n")
    return(invisible())
  }

  ## list all default target file extensions if TRUE ------------------------
  if (list.defaults) {
    cat("Default target extensions for all dependency files:\n")
    print(unlist(all_default_exts))
    cat("\n For information about possible targets, use 'info_rules(\"DEPENDENCY EXTENSION\")'\n")
    return(invisible())
  }

  ## list all target file extensions if TRUE ------------------------
  if (list.targets.all) {
    targ_exts <- unique(unlist(dep_targ_definitions$dep_targs))
    targ_exts <- sort(targ_exts[-grep("\\$", targ_exts)])
    ord1 <- (substr(targ_exts, 1, 1) == "-" | substr(targ_exts, 1, 1) == "_")
    targ_exts <- c(targ_exts[!ord1], targ_exts[ord1]) # put -,_ at end
    cat("All target file name extensions:\n")
    print(targ_exts)
    return(invisible())
  }

  ## only provide info on first dependency file extension --------------------
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
  cat("Example rules:\n")
  ## do not use dot if _ is first character
  sep_char <- ifelse(substr(dependency.ext, 1, 1) == "_", "", ".")
  ##cat(paste0(EX, ".", targext, ": ", EX, ".", dependency.ext,
  ##           " dep_file2 dep_file3\n"))
  cat(paste0(EX, sep_char, targext, ": ", EX, sep_char, dependency.ext,
             " dep_file2 dep_file3\n or\n"))
  DEFAULT_DEP <- paste0("{@:", sep_char, targext,"=", sep_char, dependency.ext,"}")
  cat(paste0(EX, sep_char, targext, ": ", DEFAULT_DEP,
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
    cat("and a similar rule can be specified if required with\n")
    cat(paste0(EX, "-syntax.R: ", EX, ".", dependency.ext,
             " dep_file2 dep_file3\n"))
  }

  cat("\nNB: For further help on Makefile rules, type 'make help' in a terminal once\n    an appropriate 'Makefile' is present in the current directory\n")
  
  invisible()
}
