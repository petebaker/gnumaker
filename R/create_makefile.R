##' Creates a GNU Makefile assuming standard pattern rules
##'
##' Standard GNU Make pattern rules are available at
##' https://github.com/petebaker/r-makefile-definitions and also with
##' the \code{gnumaker} package. These rules provide a standard way to
##' produce target files given names of one or more dependency
##' files. If a dependency file changes then targets can be updated by
##' invoking \code{make}. For instance, for an R syntax file, a target
##' could be an Rout, html or pdf file. \code{create_makefile} will
##' produce a \code{Makefile} object which can be written to file,
##' plotted and also checked to test that the relationships specified
##' are a directed acyclic graph (DAG)
##'
##' @param targets targets specified as a list where the component
##'   names are the targets and the components are a character vector
##'   of dependency file names
##' @param target.all a character vector containing file names that
##'   will be specified as a phony target at top of file and so will
##'   always be made when make is run. Default: automatically
##'   determined from the input of \code{targets} using the DAG of
##'   Makefile
##' @param phony \code{.PHONY} targets specified as a list where the
##'   component names are the \code{.PHONY} targets and the list
##'   follows the same format as \code{targets}. This is often used
##'   for target 'clean' or 'cleanall' for removing output and
##'   intermediate files. Will be placed at bottom of
##'   Makefile. Default: \code{cleanall} with rule that can be easily
##'   modified.
##' @param comments a list of comments to precede each target. By
##'   default, a suitable comment is constructed from target and
##'   dependency file names
##' @param default.exts a list specifying which target file extension
##'   should be used. (Default: Rout for R files, html for Rmd files
##'   and so on). NB: See \code{show_extensions} is under construction
##'   to obtain all file extensions from \code{r-rules.mk}
##' @param file.exts a list specifying which target file extension
##'   should be used for each specific target speciofied in
##'   \code{target.all}. (Default: Rout for R files, html for Rmd
##'   files and so on. See \code{show_extensions} (under development)
##'   when implemented.)
##' @param auto.variables logical to produce automatic variables for
##'   the first dependency. This may prove helpful if Makefile is to
##'   be modified manually. Default: FALSE
##' @param rules.mk location of GNU Make rules to be
##'   included. Default: \code{~/lib/r-rules.mk}
##'
##' @return Object of class \code{gnu_makefile} which contains a
##'   character vector of the GNU Makefile and a directed acyclic
##'   graph (DAG) of the Makefile
##'
##' @examples
##' # Create a Makfile for simple data analysis demo
##' gm1 <-
##'   create_makefile(targets = list(read = c("read.R", "simple.csv"),
##'                   linmod = c("linmod.R", "read"),
##'                   rep1 = c("report1.Rmd", "linmod"),
##'                   rep2 = c("report2.Rmd", "linmod")),
##'                   comments = list(linmod = "plots and analysis using 'linmod.R'"),
##'                   file.exts = list(rep1 = "pdf", rep2 = "docx"))
##' write_makefile(gm1)
##' plot(gm1)
##'
##' @seealso \code{\link{write_makefile}} \code{\link{plot}}  \code{\link{print}}
##' @export
create_makefile  <-
  function(targets, phony = NULL, comments = NULL,
           file.exts = NULL, target.all = NULL,
           auto.variables = FALSE,
           default.exts = list(R = "Rout", Rmd = "html", Rnw = "pdf"),
           rules.mk = "~/lib/r-rules.mk"){

  ## need to do checking and defaulting - might be good to use
  ## internal functions to keep coding clean although perhaps even
  ## more useful to put them in utils.R and not export them

  ## start defaults ------------------------------------------------
  ##
  ## NB: needs to be put into separate function(s) including
  ##     interrogating r-rules.mk and setting global options to set
  ##     default dependency and target file name extensions
  
  ## create internal fun: process file.exts (need to generalise from r-rules.mk)
  ## default_file_exts <- list(R = "Rout", Rmd = "html")
  ## need better error checking etc
    
  ## need to derive this from r-rules but this a temp fix
  R_exts <- c("Rout", "pdf", "html", "docx", "rtf", "odt")

  make_rules_exts <- list(R = R_exts, Rmd = R_exts[-1], Rnw = "pdf")
  make_rules_exts

  phony.cleanall <-
    c("# remove all target, output and extraneous files",
      ".PHONY: cleanall", "cleanall:",
      "\trm -f *~ *.Rout *.RData *.docx *.pdf *.html *-syntax.R *.RData")

  if (is.null(phony)) phony <- phony.cleanall
  
  phony.all <-
    c("# .PHONY all target which is run when make is invoked",
      ".PHONY: all")
  
  ## end defaults ------------------------------------------------
  
  ## target files
  target_files <- create_target_files(targets, file.exts, default.exts)
  ## dependency files
  dependency_files <- create_dependency_files(targets, target_files)
  ## create comments
  target_comments <- create_comments(comments, targets, target_files,
                                     dependency_files)

  ## now need to get Makefile in the right order using DAG
  makefile_dag <- create_gnumake_dag(target_files, dependency_files,
                                    target.all)
  ## plot(makefile_dag$dag) # for checking

  ## will need to do tests on ordering as think may not yet be robust
  order_targets <- order_gnumake_targets(makefile_dag, target_files)

  ## create_rules(makefile_dag, order_targets, auto.variables = FALSE)
  ## create_rules(makefile_dag, order_targets, auto.variables = TRUE)
  gnumake_rules <-
    create_rules(makefile_dag, order_targets, auto.variables = auto.variables)

  unlist(lapply(order_targets[-1],
         function(x) c("", target_comments[x], gnumake_rules[x])))
  
  ## wonder if purrr, recursive map etc a better way to put comments
  ## and rules together
  gnu_makefile <-
    unlist(c(phony.all, gnumake_rules[["all"]],
      unlist(lapply(order_targets[-1],
                    function(x) c("", target_comments[x], gnumake_rules[x]))),
      "", "# include GNU Makfile rules. Most recent version available at",
      "# https://github.com/petebaker/r-makefile-definitions",
      stringr::str_c("include", rules.mk), "", phony))
  names(gnu_makefile) <- NULL

  gnumaker <- list(gnu_makefile = gnu_makefile, makefile_dag = makefile_dag)
  
  class(gnumaker) <- "gnu_makefile"
  gnumaker
}

##' Print an object of class gnu_makefile
##'
##' @param x of class gnu_makefile
##' @param ... generic optional arguments to print function
##' @method print gnu_makefile
##' @export
print.gnu_makefile <- function(x, ...){
  print(x$gnu_makefile, ...)
  print(x$makefile_dag$dag, ...)
}
  
## ## for experimenting
## targets <- list(read = c("read.R", "simple.csv"), linmod = c("linmod.R", "read"), rep1 = c("report1.Rmd", "linmod"), rep2 = c("report2.Rmd", "linmod"))
## phony <- NULL
## comments <- list(linmod = "plots and analysis using 'linmod.R'")
## file.exts = list(rep1 = "pdf", rep2 = "docx")

## ## may need to add in some test cases - different no. and types of
## ## dependencies
## targets2 <- targets
## targets2$test <- "pretend.R"

## ## target_files <- create_target_files(targets)
## target.all <- NULL
## ## target.all  <-  c("rep1", "rep2")
## rules.mk <- "~/lib/r-rules.mk"
## auto.variables <- FALSE
## default.exts <- list(R = "Rout", Rmd = "html", Rnw = "pdf")

## gm1 <-
##   create_makefile(targets = list(read = c("read.R", "simple.csv"),
##                                  linmod = c("linmod.R", "read"),
##                                  rep1 = c("report1.Rmd", "linmod"),
##                                  rep2 = c("report2.Rmd", "linmod")),
##            comments = list(linmod = "plots and analysis using 'linmod.R'"))

## print(gm1)
