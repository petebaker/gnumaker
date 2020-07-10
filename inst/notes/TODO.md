

# DONE extract dependency and target file extensions in \`r-rules.mk\`,

preferably by parsing the included file (done using \`pattern-exts\`')


# DONE incorporate dependency and target file extensions extracted

using \`pattern-exts\` into \`create\_makefile\` and set defaults


# DONE move \`pattern\_exts\` to internal functions and create


# TODO either incorporate \`makefile2graph\` as a way of plotting \`Makefile\`s not

made with ****gnumaker\*\***** or write own functions.  (See [makefile2graph
on github](<https://github.com/lindenb/makefile2graph> "makefile2graph
on github"))


# TODO allow specification of <span class="underline">global options</span> in \`zzz.R\` so that it

is easier to customise defaults e.g. so user can specify defaults in
.Rprofile


# TODO allow \`target.all\` to be determined from DAG if this is sensible


# TODO add \`testthat\` unit testing for more complicated examples


# TODO add travis.ci

-   and other automatic checking: see
    [r-pkgs.had.co.nz/release.html](<http://r-pkgs.had.co.nz/release.html>)


# TODO allow for target file extensions and dependency files to be set

as user specified variables which would make the \`Makefile\`s
produced more flexible but less easy to read

