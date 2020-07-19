
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gnumaker

Version: 0.0.0.9009

## Overview

**gnumaker** makes if easy to create and use GNU Makefiles to aid a
reproducible work flow for data analysis projects.

GNU Make is the defacto standard for efficiently rerunning appropriate
steps in the data analysis or reporting process if a particular file is
changed. Only the necessary steps are rerun.

Rather than creating a new system for setting up and building output
from statistical software syntax files, **gnumaker** leverages off
existing GNU Make rules. These rules, for R, Sweave, R Markdown, Stata,
SAS and other syntax files are available at [r-makefile-definitions on
Github](https://github.com/petebaker/r-makefile-definitions). These are
described in P Baker (2020) Using GNU Make to Manage the Workflow of
Data Analysis Projects, *Journal of Statistical Software (Accepted)*.

For those not familiar with GNU Make, **gnumaker** allows simple
dependencies between files to be specified to produce a working Makefile
and the associated directed acyclic graph (DAG). I’d welcome Github
issues containing error reports or feature requests. Alternatively, you
can email the package maintainer at drpetebaker at gmail dot com.

## Installation

<!--
Install the latest CRAN version of **gnumaker** with:


```r
##install.packages("gnumaker")
```
## Note that three dependencies are in BioConductor so use BiocManager
NB: parked here in case biocViews: line in DESCRIPTION does not work

if (!requireNamespace("BiocManager", quietly = TRUE))
   install.packages("BiocManager")
devtools::install_github("petebaker/gnumaker", repos = BiocManager::repositories())
-->

You can install the development version of **gnumaker** from GitHub
with:

``` r
## if you don't have devtools installed, automatically install it from CRAN
if (!requireNamespace("devtools", quietly = TRUE))
   install.packages("devtools")
devtools::install_github("petebaker/gnumaker")
```

## Usage

There are currently four key functions in **gnumaker**. These are:

  - `create_makefile()` creates a `gnu_makefile` object given the
    specified dependencies between syntax, data and output files,
  - `write_makefile()` writes a `gnu_makefile` object to a `Makfile` on
    disk,
  - `info_rules()` provides information about data analysis `GNU Make`
    rules for various target and dependency filename extensions, and
  - `plot()` plots the DAG of a `gnu_makefile` object.

## Example

Suppose we have a data file `simple.csv` and use `read.R` to read and
clean the data. After storing the cleaned data in a .RData file, we then
employ `linmod.R` to plot and analyse the data. Next, using the stored
results, two reports `report1.pdf` and `report2.docx` are produced from
`report1.Rmd` and `report2.Rmd`. The workflow may be encapsulated in a
Makefile which is then employed to manage the process and generate or
regenerate any intermediate files when the data or syntax changes.

Rather than writing `GNU Make` commands, we can employ the **gnumaker**
package to create an appropriate `Makefile` called `Makefile.demo` with:

``` r
library(gnumaker)
gm1 <-
  create_makefile(targets = list(read = c("read.R", "simple.csv"),
                  linmod = c("linmod.R", "read"),
                  rep1 = c("report1.Rmd", "linmod"),
                  rep2 = c("report2.Rmd", "linmod")),
                  target.all = c("rep1", "rep2"),
                  all.exts = list(rep1 = "pdf", rep2 = "docx"))
write_makefile(gm1, file = "Makefile.demo")
#> File: Makefile.demo written at Sun Jul 19 15:40:31 2020
```

To plot the DAG, we use:

``` r
plot(gm1)
```

![DAG of Makefile for simple example. The DAG of the `gnu_makefile`
object can be produced with `plot(gm1)`. Using the minimal set of files
(shown in green rectangles), then GNU Make allows us to (re)generate all
other files shown as wheat coloured circles)](images/simple-dag-1.png)

### Details

Using the **gnumaker** package we simply need to provide a list of
targets to the the `create_makefile` function where the components
specify a target as a name and dependency file(s) as a character vector.
The package uses the `GNU Make` pattern rules in `r-rules.mk` to choose
file names for targets but we can override the defaults.

For instance, in this example the first two dependency files are
`simple.csv` and `read.R` so we provide the first target as the first
component of the list as `read = c("read.R", "simple.csv")`, where the
name `read` can be anything we like. Note that the target filename for
`read` will be derived from the first failename in the list `read.R`.
The second target depends on the `read` target and `linmod.R` and so we
specify this with `linmod = c("linmod.R", "read")` and so on.

Using the function `create_makefile` to create a `gnu_makefile` object,
target file names are substituted using defaults and the appropriate
`Make` commands are rearranged using the DAG of the relationships. For
instance, the default target file for the first dependency in the `read`
component, which is `read.R`, becomes `read.Rout` but we can change the
default target file extension for all `.R` files using the
`default.exts` argument and specify say a HTML target file with
`default.exts = list(R = "html")`.

Finally we specify the first target (usually `all`) as two reports
`report1.pdf` and `report2.docx` using `target.all = c("rep1","rep2")`
which by default would be `report1.html` and `report2.html` but which we
specify as `report1.pdf` and `report2.docx` by specifying the option
`all.exts = list(rep1 = "pdf", rep2 = "docx")`.

Once we have constructed a suitable `gnu_makefile` object then we write
it to disk with `write_makefile`. To run all `R` script files and
analyses in order we simply type `make` in a terminal or set up
`RStudio` or our IDE to use GNU Make as the build mechanism which allows
us to (re)run analyses by pressing the appropriate Build button.

The `Makefile`, with optional comment for `linmod` target, is specified
using:

``` r
library(gnumaker)
gm1 <-
  create_makefile(targets = list(read = c("read.R", "simple.csv"),
                  linmod = c("linmod.R", "read"),
                  rep1 = c("report1.Rmd", "linmod"),
                  rep2 = c("report2.Rmd", "linmod")),
                  target.all = c("rep1", "rep2"),
                  all.exts = list(rep1 = "pdf", rep2 = "docx"),
 comments = list(linmod = "plots and analysis using 'linmod.R'"))
```

A Makefile `Makefile.demo` is produced with `write_makefile(gm1)`

``` r
write_makefile(gm1, file = "Makefile.demo")
#> File: Makefile.demo written at Sun Jul 19 15:40:31 2020
```

    # File: Makefile.demo
    # Created at: Sun Jul 19 15:40:31 2020
    
    # Produced by gnumaker:  0.0.0.9009 on R version 4.0.2 (2020-06-22)
    # Before running make, please check file and edit if necessary
    
    # .PHONY all target: run when 'make' is invoked without a target
    .PHONY: all
    all: report1.pdf report2.docx
    
    # report1.pdf depends on report1.Rmd, linmod.Rout
    report1.pdf: report1.Rmd linmod.Rout
    
    # report2.docx depends on report2.Rmd, linmod.Rout
    report2.docx: report2.Rmd linmod.Rout
    
    # plots and analysis using 'linmod.R'
    linmod.Rout: linmod.R read.Rout
    
    # read.Rout depends on read.R, simple.csv
    read.Rout: read.R simple.csv
    
    # include GNU Makfile rules. Most recent version available at
    # https://github.com/petebaker/r-makefile-definitions
    include ~/lib/r-rules.mk
    
    # remove all target, output and extraneous files
    .PHONY: cleanall
    cleanall:
        rm -f *~ *.Rout *.RData *.docx *.pdf *.html *-syntax.R *.RData

<!-- The DAG of the `gnu_makefile` object can be produced with `plot(gm1)`. -->

<!-- ```{r, simple-dag2, fig.cap = "DAG of Makefile for simple example. The DAG of the `gnu_makefile` object can be produced with `plot(gm1)`. Using the minimal set of files (shown in green rectangles), then GNU Make allows us to (re)generate all other files shown as wheat coloured circles)"} -->

<!-- plot(gm1) -->

<!-- ``` -->

We can use the function `info_rules` to determine the possible target
files for dependency files. For instance, what target files have
`Makefile` rules for an `.R` R syntax file?

``` r
info_rules("R")
#> Possible filename extensions for 'R':
#> [1] "docx" "html" "odt"  "pdf"  "Rout" "rtf" 
#> 
#> Default: 'Rout'
#> 
#> Example rules:
#> example1.Rout: example1.R dep_file2 dep_file3
#>  or
#> example1.Rout: {@:.Rout=.R} dep_file2 dep_file3
#> 
#> NB: For further help on Makefile rules, type 'make help' in a terminal once
#>     an appropriate 'Makefile' is present in the current directory
```

For `.Rmd` R Markdown files, use

``` r
info_rules("Rmd")
#> Possible filename extensions for 'Rmd':
#>  [1] "_beamer-handout.Rmd" "_beamer.pdf"         "_ioslides.html"     
#>  [4] "_slidy.html"         "_tufte.pdf"          "-syntax.R"          
#>  [7] "docx"                "html"                "odt"                
#> [10] "pdf"                 "pptx"                "rtf"                
#> 
#> Default: 'html'
#> 
#> Example rules:
#> example1.html: example1.Rmd dep_file2 dep_file3
#>  or
#> example1.html: {@:.html=.Rmd} dep_file2 dep_file3
#> 
#> Other options are available for R Markdown files, such as:
#> 
#> example1_ioslides.html: example1.Rmd dep_file2 dep_file3
#> example1_beamer.pdf: example1.Rmd dep_file2 dep_file3
#> 
#> to produce ioslide and beamer presentation formats.
#> 
#> An R syntax file can be produced with
#>   make example1-syntax.R
#> and a similar rule can be specified if required with
#> example1-syntax.R: example1.Rmd dep_file2 dep_file3
#> 
#> NB: For further help on Makefile rules, type 'make help' in a terminal once
#>     an appropriate 'Makefile' is present in the current directory
```

For more examples, see the gnumaker vignette (under construction).

## Note

**gnumaker** is under construction and could change (and improve)
rapidly at various times but this depends on work/life balance.
