##' Extract GNU Make pattern rule file extensions
##'
##' \code{pattern_exts} extracts file name extensions from GNU Make pattern rules file
##'
##' Target and dependency file name extensions are extracted from the
##' specified GNU Make rules file for use with
##' \code{\link{create_makefile}}. While this function may be employed
##' to extract file extensions, it's main purpose is to enable all
##' specified pattern rules to be employed with the
##' \code{\link{gnumaker}} package and so update these relationships
##' when new rules are added.
##'
##' @param x file name specified as a character string. Default:
##'   \dQuote{~/lib/r-rules.mk}
##' @param rm.beamer.templates (logical) as to whether or not to remove
##'   references to beamer templates. Default: FALSE
##' @param rm.pythperl.vars (logical) as to whether or not to remove
##'   python and perl variable extension references. Default: TRUE
##'
##' @return Object of class \code{gnu_make_exts} which is a list of
##'   file name extensions to be used in creating working
##'   Makefiles. The components are \code{dep_targs}: a named list
##'   with one or more possible target file extensions with component
##'   names the the extension of the first dependency file name,
##'   \code{variables}: variables set in Make rules file \code{x} used
##'   in either targets or dependency file extensions and
##'   \code{extras} containing various material extracted from the
##'   file \code{x}.
##'
##' @examples
##' ## Extract pattern rule file extensions from 'r-rules.mk'
##' testfile <- system.file("make", "r-rules.mk", package = "gnumaker")
##' file_exts <- pattern_exts(testfile)
##' file_exts$dep_targs
##'
##' @seealso \code{\link{create_makefile}}
##' @export
pattern_exts  <- function(x = "~/lib/r-rules.mk", rm.beamer.templates = FALSE,
                          rm.pythperl.vars = FALSE){

  ## check/set GNU Make rules file ------------------------------
  if (!file.exists(x)) stop(paste(x, "does not exist"))
  rules_txt <- readLines(x)

  ## extract pattern rules with variables only -------------------
  ## detect lines starting with % - slightly strange NAs etc
  rules <- 
    rules_txt[sapply(rules_txt, function(x) length(grep(x, pattern = "^%"))>0)]
  ## checks length(rules); length(unique(rules))
  ## remove duplicates
  rules2 <- sort(unique(rules))  # length(rules2)

  ## drop off any rules from 'rules' defined on same line using ;
  ## rules[sapply(rules, function(x) length(grep(x, pattern = ";"))>0)]
  ## rules2[sapply(rules2, function(x) length(grep(x, pattern = ";"))>0)]
  rules3 <- sapply(strsplit(rules2, ";"), function(x) trimws(x[[1]][1]))

  ## drop off any reference to beamer templates ???
  ## if left in it could start to look messy but is this a prob?
  ## presumably should be left to case when producing Makefile/plots
  
  beamer_str <-
    paste(paste0("([ ]*\\$\\(BEAMER_", c("ARTICLE", "HANDOUT", "NOTES",
                                         "PRESENT"), "\\))"), collapse = "|")
  rules4 <- sapply(rules3, gsub, pattern = beamer_str, replacement = "")
  names(rules4) <- NULL
  rules3 <- rules4
  ## unfortunately, hard to program this as we want to squash all 3
  ## rules for each Rnw/rnw -> beamer into two chained rules  for Article etc
  ## how to fix these? _Article, _Handout, _Notes, _Present
  ## here's the easy/non-clever way
  beamer_rules1 <- rules3[grep("_Article*\\.[rR]nw$|_Notes*\\.[rR]nw$|_Present*\\.[rR]nw$|_Handout*\\.[rR]nw$", rules3)]
  beamer_rules1 <- rules3[grep("_Article|_Notes|_Present|_Handout", rules3)]
  beamer_rulesh <- beamer_rules1[droph <- -grep(".pdf$", beamer_rules1)]
  if (rm.beamer.templates){
    ## drop all beamer related rules from rules3
    rules3 <- setdiff(rules3, beamer_rules1)
  } else {
    ## drop the intermediate .Rnw files and conert then to _TYPE.pdf from .Rnw
    rules3 <- setdiff(rules3, beamer_rulesh)
    ## create 1 rule from each of 3 rules by removing pdf then
    ## replacing first Rnw/rnw with pdf
    beamer_rulesh2 <- beamer_rulesh[-grep(".pdf", beamer_rulesh)]
    beamer_rulesh2 <- sub(".[Rr]nw", ".pdf", beamer_rulesh2)
    rules3 <- c(beamer_rulesh2, rules3)
  }
  
  ## extract pattern rules with variables only -------------------
  rules_vars <-
    rules3[sapply(rules3, function(x) length(grep(x, pattern = "\\$"))>0)]

  ## variable names only ---------------------------
  ##
  ## extract variable names - firstly assume either $() or ${}
  ## NB: assumes $() or ${} otherwise fails
  ## may be multiple
  ## x <- rules_vars[1]  # for testing extract_var_rules
  ## x <- rules_vars[13]
  extract_var_rules <- function(x, ...){
    ## could add delimiter = c("both", "straight", "curly")
    ## but this is good enough for now
    if (class(x) != "character") stop("x is not of class 'character'")
    ## find start(s) and stop(s)
    v_start <- gregexpr( "\\$(\\(|\\{)", x)
    v_stop <- gregexpr( "\\)|\\}", x)

    ## $( or ${ not found
    if (length(v_start[[1]]) == 1 && v_start[[1]] == -1)
      stop("Inconsistent variable definition")
    ## extract variable names
    mapply(function(vstart, vstop) substr(x, vstart+2, vstop-1),
           v_start[[1]], v_stop[[1]])
  }


  ## extract all variable names
  vars <- unique(unlist(sapply(rules_vars, extract_var_rules)))
  ## make sure beamer handled correctly
  ## if (!rm.beamer.templates) vars <- c("BEAMER_LIB", vars)
  
  ## NB: ONLY IMPORTANT IF ACTUALLY A FILE EXTENSION OR PART OF
  ##     FILENAME - not a dependency like in beamer stuff
  ##     will need to handle these as a special case
  ##     Need to investigate further
  
  ## find variable definitions and extract variables ---------------
  pat1 <- paste(paste0("^[ ]*", vars, "[ ]*="), collapse = "|")
  defs_txt <-
    rules_txt[sapply(rules_txt, function(x) length(grep(x, pattern = pat1))>0)]
  ## extract variables
  ev <- strsplit(defs_txt, "=")
  vars2 <-
    lapply(ev, function(x) {if (length(x)==2) trimws(x[2]) else ""})
  names(vars2) <- sapply(ev, function(z) trimws(z[[1]][1]))
  ## vars2
  
  ## DECISION: DO I substitute variables in now - think not - or allow
  ## user/makefile itself to overwrite - need to think thru
  
  ## what format do I need this in???
  
  ## get target file extensions and possible dependencies
  t_start <- gregexpr( "^%\\.", rules3)
  t_stop <- gregexpr( ":", rules3)
  d_start <- gregexpr( ":[ ]*", rules3)
  
  target_exts <-
    mapply(function(x, tstop) trimws(substr(x, 2, tstop - 1)),
           rules3, t_stop)
  target_exts <- gsub("^\\.", "", target_exts)
  
  dep_exts <- 
    mapply(function(x, dstart)
      trimws(substr(x, dstart[1] + attr(dstart, "match.length") + 1,
                    nchar(x))), rules3, d_start)
  dep_exts <- gsub("^\\.", "", dep_exts)
  
  ## length(unique(target_exts))
  ## length(unique(dep_exts))
  
  targs <- unique(target_exts)
  deps <- unique(dep_exts)
  deps1 <-
    unique(sapply(tmp_dep <- strsplit(deps, " "), function(x) x[[1]][1]))
  
  dep_targs <- vector(mode = "list", length = length(deps1))
  names(dep_targs) <- deps1
  ttt <- target_exts
  names(ttt)  <- NULL
  for (D in deps1) dep_targs[[D]] <- ttt[dep_exts == D] 
  
  dep_targs_all <- dep_targs
  ## drop beamer intermediate files because don't want these specified
  ## in Makefile but these are automatically created
  keep_dt <-
    names(dep_targs)[grep("\\.Rnw|\\.Rmd", names(dep_targs), invert = TRUE)]
  dep_targs <- dep_targs[keep_dt]
  dep_targs <-
    sapply(dep_targs, function(x) x[grep("\\.Rnw|\\.Rmd", x,  invert = TRUE)])
  
  pat_exts <- list(dep_targs = dep_targs, variables = vars2,
                   extras = list(target_exts = target_exts,
                                 dep_exts = dep_exts, rules = rules3,
                                 dep_targs_all = dep_targs_all))
  class(pat_exts) <- "gnu_make_exts"
  ## NB: need to curate dep_targs and set defaults for 'dep_targs' by
  ##     hand in create_makefile
  pat_exts
}
