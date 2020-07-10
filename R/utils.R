## should I also use library(repurrrsive) ??

order_gnumake_targets <- function(makefile_dag, target_files){

  is_parent_target <- function(x){
    targets_all <- target_names[target_files %in%
                                gRbase::parents(x, makefile_dag$dag)]
    unique(targets_all)
  }
  
  if (class(makefile_dag) != "gnumake_dag")
    stop("makefile_dag must be of class 'gnumake_dag'")
  target_files <- sapply(makefile_dag$dag_list, function(x) x[1])
  lapply(target_files, function(x) gRbase::parents(x, makefile_dag$dag) )

  ## first target is always 'all'
  target_names <- names(target_files)

  ## how to turn this into a loop/apply/purrr or recursive??
  
  targets_all <- is_parent_target("all")
  next_targets <-
    unique(sapply(targets_all, function(x)is_parent_target(target_files[x])))
  order_targets <- c("all", targets_all, next_targets)

  next_targets1 <- next_targets
  while(length(next_targets1[[1]])>0){
    next_targets1 <-
      unique(sapply(next_targets,
                    function(x) is_parent_target(target_files[x])))
    order_targets <- c(order_targets, next_targets1)
    ## if (stringr::str_length(next_targets1[[1]]) == character(0)) break
    next_targets <- next_targets1
  }

  ## make sure elements aren't repeated
  unique(unlist(order_targets))
  
}

create_gnumake_dag <- function(target_files, dependency_files, target.all){

  ## edges
  n_edges <- length(target_files$file_names)
  dag_list <- as.vector(rep("", length.out = n_edges), mode = "list")
  names(dag_list) <- names(target_files$file_names)

  ## dag components
  for (I in 1:n_edges){
    ## NB: could also just list components as character vectors
    ##     which would be easier to manipulate
    dag_list[[I]] <- c((target_files$file_names)[[I]],
                       (dependency_files$dependencies)[[I]])
  }

  ## target all defined (or not then guessed)
  if (!is.null(target.all)){
    ## target_all <- sapply(target.all, subst_target_file)
    target_all <- target_files$file_names[target.all]
    dag_list$all <- c("all", target_all)
  } else {
    ## create dag so far for working out child nodes
    test_dag <- gRbase::dag(dag_list)
    ## test_edges <- igraph::edges(test_dag) # actually graphNEL-class !igraph
    test_edges <- graph::edges(test_dag)
    ## get children 
    child <- sapply(test_edges, function(x) length(x) == 0)
    dag_list$all  <- c("all", names(child[child]))
  }
  
  gnumake_dag <- list(dag = gRbase::dag(dag_list),
                      dag_list = dag_list)
  class(gnumake_dag) <- "gnumake_dag"
  gnumake_dag
}

create_comments <- function(comments, targets, target_files,
                            dependency_files, line.width = 72){
  ## logical as to whether comment specified
  specified_comments <- names(targets) %in% names(comments)
  
  full_comments <- targets
  
  ## use comment if specified
  full_comments[names(comments)] <-
    stringr::str_c("# ", comments[names(comments)])

  ## dependecies as file lists
  dep_file_lists <- 
    lapply(dependency_files$dependencies,
           function(x) paste(x, collapse = ", "))
  
  ## make comment from targets/dependencies if not specified
  full_comments[!specified_comments] <-
    paste("#", target_files$file_names[!specified_comments], "depends on",
          dep_file_lists[!specified_comments])

  ## any lines > 72? - formatR is pretty messy so let's hope no changes
  max_length <- max(sapply(full_comments, stringr::str_length))
  if (max_length > line.width){
    for (I in 1:length(full_comments)){
      if (stringr::str_length(full_comments[[I]]) > line.width){
        tmp <- formatR::tidy_source(text = full_comments[[I]])
        full_comments[[I]] <- tmp[[1]]
      }
    }
  }
  full_comments
}

## if a target substitute the target file else leave as is
subst_target_file <- function(x, target_files = target_files) {
  if (length(x) == 0) return(x)
  if (tools::file_ext(x) != "") return(x)
  t_names <- target_files$file_names
  if (x %in% names(t_names)) {
    tgt <- t_names[[x]]
  } else {
    tgt <- x
    warning(paste0("Target: '", x, "' not specified"))
  }
  tgt
}

create_rules <- function(makefile_dag, order_targets, auto.variables){

  if (class(makefile_dag) != "gnumake_dag")
    stop("Object 'makefile_dag' must be of class 'gnumake_dag'")

    simple_rule <- function (x) {
      stringr::str_c(makefile_dag$dag_list[[x]][1], ": ",
                     stringr::str_c(makefile_dag$dag_list[[x]][-1],
                                    collapse = " "))
    }
  
  ## create simple list of makefile targets: dependencies
  if (!auto.variables){
    gnumake_rules <- lapply(order_targets, simple_rule)
  } else {
    
    targets <- sapply(order_targets, function(x) makefile_dag$dag_list[[x]][1])
    deps1 <- sapply(order_targets, function(x) makefile_dag$dag_list[[x]][2])
    target_exts <- sapply(targets, tools::file_ext)
    depend1_exts <- sapply(deps1, tools::file_ext)
    names(depend1_exts) <- order_targets
    
    with_variables <- function (x) {
      if (target_exts[[x]] == ""){
        simple_rule(x)
      } else {
        stringr::str_c(targets[[x]], ": ${@:.",
                       target_exts[x], "=.",
                       depend1_exts[x], "} ",
                       stringr::str_c(makefile_dag$dag_list[[x]][-c(1,2)],
                                      collapse = " "))
      }
    }
    gnumake_rules <- lapply(order_targets, with_variables)
  }
  names(gnumake_rules) <- order_targets
  class(gnumake_rules) <- "gnumake_rules"
  gnumake_rules
}

create_dependency_files <- function(targets, target_files){
  
  if (class(target_files) != "target_files")
    stop("target files must be of class 'target_files'")
  
  target_exts <- tools::file_ext(target_files$file_names)
  depend1_exts <- tools::file_ext(target_files$first_dep)

  ## other bits - first just grab them 
  ##other_deps  <-
  ##  sapply(targets, function (x) sapply(x[-1], subst_target_file))
  ## names(other_deps) <- names(targets)

  ## other bits - first just grab them 
  all_deps  <-
    lapply(targets, function(x) sapply(x, subst_target_file, target_files))

  ## any advantage in purrr?
  ##      purrr::map(targets, function(x) sapply(x, subst_target_file))

  ## create dependency files object
  dependency_files <- list(dependencies = all_deps,
                           first_dep = target_files$first_dep)
  class(dependency_files) <- "dependency_files"
  dependency_files

}

create_target_files <- function(targets, file.exts, default.exts){
  ## process target names
  ##target_names <- names(targets)
  ##names(target_names) <- names(targets)
  ##target_names
  
  ## grab 1st dependency in order to set target names
  depend1_names <- sapply(targets, function(x) x[1])
  depend1_names
  ## dependency file extensions
  depend_exts <- tools::file_ext(depend1_names)
  depend_exts
  
  ## logical as to whether target filename extension specified
  specified_exts <- rep(FALSE, length(targets))
  names(specified_exts) <- names(targets)
  ## if (is.null(file.exts)){
  ##   specified_exts <- rep(FALSE, length(targets))
  ## }
  
  ## if specified use file.exts otherwise use default
  target_file_names <- tools::file_path_sans_ext(depend1_names)
  ## file extensions specified
  if (!is.null(file.exts)){
    specified_exts[names(file.exts)] <- TRUE
    target_file_names[names(file.exts)] <- 
      stringr::str_c(target_file_names[names(file.exts)], ".", file.exts)
  }
  ## file extensions not specified - use defaults
  target_file_names[!specified_exts] <-
    stringr::str_c(target_file_names[!specified_exts], ".",
                   default.exts[depend_exts[!specified_exts]])
  ## create target files object
  target_files <- list(file_names = target_file_names,
                       first_dep = depend1_names)
  class(target_files) <- "target_files"
  target_files
}

## What: load and store target/dependency filename extensions and
## defaults using 'pattern_exts'

## I'm not sure whether to automate this or not so currently I use it
## interactively with   save_dep_targ_exts()
## save defaults at same time for use in 'create_makefile' etc
## Date: 2019-05-17 at 18:20:35
## NB: Could use as standalone prog from top level Makefile
##     and potentially add to .Rbuildignore
save_dep_targ_exts <- function(x = "../inst/make/r-rules.mk",
                               OVERWRITE = FALSE){

  if(!OVERWRITE)
    warning("Call this with save_dep_targ_exts(OVERWRITE = TRUE) ?")
  
  dep_targ_definitions <- pattern_exts(x)

  ## default exts is a list but should just be a character vector -
  ## sure you can only have one!
  dep_targ_defaults <-
    list(R = "Rout", r = "Rout",    # perhaps should be "html" ??
         Rmd = "html", rmd = "html", 
         Rnw = "pdf", rnw = "pdf",
         Snw = "pdf", snw = "pdf",
         tex = "rtf",
         do = "log", DO = "LOG",
         sas = "lst", SAS = "LST",
         PL = "txt", pl = "txt",
         PY = "txt", py = "txt",
         PY = "txt", py = "txt",
         SPS = "PDF", sps = "pdf",
         "_Handout.pdf" = "-6up.pdf",
         "_beamer-handout.pdf" = "_beamer-6up.pdf")
    
  usethis::use_data(dep_targ_definitions, dep_targ_defaults, internal = TRUE,
                    overwrite = OVERWRITE)
}
