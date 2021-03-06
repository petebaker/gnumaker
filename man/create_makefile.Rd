% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_makefile.R
\name{create_makefile}
\alias{create_makefile}
\title{Creates a GNU Makefile assuming standard pattern rules}
\usage{
create_makefile(
  targets,
  target.all = NULL,
  all.exts = NULL,
  phony = NULL,
  comments = NULL,
  auto.variables = FALSE,
  default.exts = NULL,
  rules.mk = "~/lib/r-rules.mk"
)
}
\arguments{
\item{targets}{targets specified as a list where the component
names are the targets and the components are a character vector
of dependency file names}

\item{target.all}{a character vector containing file names that
will be specified as a phony target at top of file and so will
always be made when make is run. Default: the last target in the
\code{targets} list but ideally this should be set in order to
produce a more flexible \code{Makefile}}

\item{all.exts}{a list specifying which target file extension
should be used for each specific target specified in
\code{targets.all}. (Default: determined automatically from
\code{default.exts})}

\item{phony}{\code{.PHONY} targets specified as a list where the
component names are the \code{.PHONY} targets and the list
follows the same format as \code{targets}. This is often used
for target 'clean' or 'cleanall' for removing output and
intermediate files. Will be placed at bottom of
Makefile. Default: \code{cleanall} with rule that can be easily
modified.}

\item{comments}{a list of comments to precede each target with
names that are in \code{targets}. By default, a suitable comment
is constructed from target and dependency file names}

\item{auto.variables}{logical to produce automatic variables for
the first dependency. This may prove helpful if Makefile is to
be modified manually. Currently not implemented. Default: FALSE}

\item{default.exts}{a list specifying a target file extension to
be used for particular dependency file extension. This only
needs to be specified if a different extension is required than
that already set in the included pattern rule file
\code{rules.mk}. Default: Rout for R files, html for Rmd files
and so on as specified in included \code{rules.mk} file. NB:
Function \code{show_extensions} is under construction to show
all file extensions from \code{r-rules.mk}}

\item{rules.mk}{location of GNU Make rules to be
included. Default: \code{~/lib/r-rules.mk}}
}
\value{
Object of class \code{gnu_makefile} which contains a
  character vector of the GNU Makefile and a directed acyclic
  graph (DAG) of the Makefile
}
\description{
Standard GNU Make pattern rules are available at
https://github.com/petebaker/r-makefile-definitions and also with
the \code{gnumaker} package. These rules provide a standard way to
produce target files given names of one or more dependency
files. If a dependency file changes then targets can be updated by
invoking \code{make}. For instance, for an R syntax file, a target
could be an Rout, html or pdf file. \code{create_makefile} will
produce a \code{Makefile} object which can be written to file,
plotted and also checked to test that the relationships specified
are a directed acyclic graph (DAG)
}
\examples{
# Create a Makfile for simple data analysis demo
gm1 <-
  create_makefile(targets = list(read = c("read.R", "simple.csv"),
                  linmod = c("linmod.R", "read"),
                  rep1 = c("report1.Rmd", "linmod"),
                  rep2 = c("report2.Rmd", "linmod")),
                  target.all = c("rep1", "rep2"),
                  all.exts = list(rep1 = "pdf", rep2 = "docx"),
                  comments = list(linmod = "plots and analysis using 'linmod.R'"))
write_makefile(gm1)
plot(gm1)

}
\seealso{
\code{\link{write_makefile}} \code{\link{plot}}  \code{\link{print}}
}
