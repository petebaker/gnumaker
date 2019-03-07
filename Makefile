## File: Makefile.runR
## 
## What: Template typical rules for R files but adds extension R_OUT_EXT
## 
##   - take a copy and modify as necessary
##   - ideally put modified copy in a directory you access often or write
##     a script to grab a copy whenever you need

RMARKDOWN_GITHUB_OPTS = \"github_document\"
RMARKDOWN_GITHUB_EXTRAS =

## .md from .Rmd  - github doc
%.md: %.Rmd
	${RSCRIPT} ${RSCRIPT_OPTS} -e "library(rmarkdown);render(\"${@:.md=.Rmd}\", ${RMARKDOWN_GITHUB_OPTS} ${RMARKDOWN_GITHUB_EXTRAS})"
%.md: %.rmd
	${RSCRIPT} ${RSCRIPT_OPTS} -e "library(rmarkdown);render(\"${@:.md=.rmd}\", ${RMARKDOWN_GITHUB_OPTS} ${RMARKDOWN_GITHUB_EXTRAS})"





##R_OUT_EXT = Rout
R_OUT_EXT = pdf
##R_OUT_EXT = html
##R_OUT_EXT = docx
##R_OUT_EXT = odt
##R_OUT_EXT = rtf

RMD_OUT_EXT = docx

DATAFILE=

.PHONY: all
all: README.pdf

## readme.md
README.md:README.Rmd

## unclude pattern rules
include ~/lib/r-rules.mk
