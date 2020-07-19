test_that("checking that create_makefile creates correct Makefile object",{
  
makefile_1 <- 
  create_makefile(targets = list(read = c("read.R", "simple.csv")))

makefile_2 <- 
  create_makefile(targets = list(read = c("read.R", "simple.csv")),
                  all.exts = list(read = "pdf"))

## list of length 2
expect_length(makefile_1, 2)
expect_length(makefile_2, 2)

## text of 1st component
expect_equal(makefile_1[[1]][6], "read.Rout: read.R simple.csv")
expect_equal(makefile_1[[1]][8],
             "# include GNU Makfile rules. Most recent version available at")
expect_equal(makefile_1[[1]][9],
             "# https://github.com/petebaker/r-makefile-definitions")

## attributes of 2nd component: DAG
##"graphNEL"

##str(m1)
})
