##' Plots DAG from a GNU Makefile object
##'
##' Standard GNU Make pattern rules are available at
##' https://github.com/petebaker/r-makefile-definitions and also with
##' the \code{gnumaker} package. Plots directed acyclic graph (DAG)
##' created using \code{\link{create_makefile}} using package
##' \code{Rgraphviz}.
##'
##' @param x object of class \code{gnu_makefile}
##' @param \\dots options passed to  \code{Rgraphviz} \code{\link[Rgraphviz]{plot.graphNEL}}
##' @param nodes.color color of intermediate files. Default \dQuote{wheat}
##' @param parents.shape shape of parent files box. Default \dQuote{box}
##' @param parents.color color of parent files. Default \dQuote{lightgreen}
##'
##' @return does not return an object but is used for plotting
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
##' plot(gm1)
##' plot(gm1, main = "Makefile for Simple Demo")
##' plot(gm1, attrs = list(node = list(fillsize = "20",
##'      edge = list(weight = 2.0))))
##' 
##' @seealso \code{\link{create_makefile}} \code{\link[Rgraphviz]{plot.graphNEL}}
##' @method plot gnu_makefile
##' @export
plot.gnu_makefile <- function(x, nodes.color = "wheat",
                              parents.shape = "box",
                              parents.color = "lightgreen", ...)
{
    if (class(x) != "gnu_makefile")
      stop("'x' must be of class 'gnu_makefile'")

    bdag <- x$makefile_dag$dag

    bdag_children <- unique(gRbase::children(graph::nodes(bdag), bdag))
    ## parents by looking at set difference - looks OK
    bdag_parents <- setdiff(graph::nodes(bdag), bdag_children)

    ## From Rgraphviz vignette Section 4.2 pp 9
    ## looks like the best way
    nAttrs <- list()
    nAttrs$shape[bdag_parents] <- parents.shape
    nAttrs$fillcolor[graph::nodes(bdag)] <- nodes.color
    nAttrs$fillcolor[bdag_parents] <- parents.color

    Rgraphviz::plot(bdag, nodeAttrs = nAttrs, ...)

    invisible()
}
