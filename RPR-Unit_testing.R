# tocID <- "RPR-Unit_testing.R"
#
# Purpose:  A Bioinformatics Course:
#              R code accompanying the RPR-Unit_testing unit.
#
# Version:  1.2
#
# Date:     2017  10  -  2019  01
# Author:   Boris Steipe (boris.steipe@utoronto.ca)
#
# Versions:
#           1.2    2020 Updates. Discuss local tests.
#           1.1    Change from require() to requireNamespace()
#           1.0    New code
#
#
# TODO:
#
#
# == DO NOT SIMPLY  source()  THIS FILE! =======================================
#
# If there are portions you don't understand, use R's help system, Google for an
# answer, or ask your instructor. Don't continue if you don't understand what's
# going on. That's not how it works ...
#
# ==============================================================================


#TOC> ==========================================================================
#TOC> 
#TOC>   Section  Title                             Line
#TOC> -------------------------------------------------
#TOC>   1        Unit Tests with testthat            42
#TOC>   2        Organizing your tests              165
#TOC>   2.1        Testing scripts                  189
#TOC>   2.2        Rethinking testing               202
#TOC>   3        Task solutions                     220
#TOC> 
#TOC> ==========================================================================


# =    1  Unit Tests with testthat  ============================================

# The testthat package supports writing and executing unit tests in many ways.

if (! requireNamespace("testthat", quietly = TRUE)) {
  install.packages("testthat")
}
# Package information:
#  library(help = testthat)       # basic information
#  browseVignettes("testthat")    # available vignettes
#  data(package = "testthat")     # available datasets

# testthat is one of those packages that we either use A LOT in a script,
# or not at all. Therefore it's more reasonable to depart from our usual
# <package>::<function>() idiom, and load the entire library. In fact, if
# we author packages, it is common practice to load testthat in the part
# of the package that automates testing.

library(testthat)

# An atomic test consists of an expectation about the bahaviour of a function or
# the existence of an object. testthat provides a number of useful expectations:

# At the most basic level, you can use expect_true() and expect_false():

expect_true(file.exists("./data/S288C_YDL056W_MBP1_coding.fsa"))
expect_true(file.exists("NO-SUCH-FILE.txt"))

expect_false(is.integer(NA))

# More commonly, you will test for equality of an output with a given result.
# But you need to consider what it means for two numbers to be "equal" on a
# digital computer. Consider:

49*(1/49) == 1      # Surprised? Read FAQ 7.31
                    # https://cran.r-project.org/doc/FAQ/R-FAQ.html
49*(1/49) - 1       # NOT zero (but almost)

# This is really unpredictable ...
0.1 + 0.05 == 0.15
0.2 + 0.07 == 0.27

# It's easy to be caught on the wrong foot with numeric comparisons, therefore
# R uses the function all.equal() to test whether two numbers are equal for
# practical puposes up to machine precision.
49*(1/49) == 1
all.equal(49*(1/49), 1)

# The testthat function expect_equal() uses all.equal internally:
expect_equal(49*(1/49), 1)

# ... which is reasonable, or, if things MUST be exactly the same ...
expect_identical(49*(1/49), 1)

# ... but consider:
expect_identical(2, 2L) # one is typeof() "double", the other is integer"

# Some very useful expectations are expect_warning(), and expect_error(), for
# constructing tests that check for erroneous output:

as.integer(c("1", "2", "three"))
expect_warning(as.integer(c("1", "2", "three"))) # Note that the warning is NOT
                                                 # printed.
1/"x"
expect_warning(1/"x")
expect_error(1/"x")      # Again: note that the error is NOT printed, as well
                         # code execution will continue.

# Even better, you can check if the warning or error is what you expect it
# to be - because it could actually have occured somewhere else in your code.

v <- c("1", "x")
log(v[1:2])
expect_error(log(v[1:2]), "non-numeric argument to mathematical function")
expect_error(log(v[1:2]), "non-numeric") # We can abbreviate the error message.
expect_error(log(v[1,2]))                # This appears oK, but ...
expect_error(log(v[1,2]), "non-numeric") # ... it's actually a different error!

# Producing unit tests simply means: we define a function, and then we check
# whether all test pass. Consider a function that is loaded on startup from
# the .utilities.R script:

biCode

# We could test it like so:

expect_equal(biCode(""), ".....")
expect_equal(biCode(" "), ".....")
expect_equal(biCode("123 12"), ".....")
expect_equal(biCode("h sapiens"), "H..SA")
expect_equal(biCode("homo sapiens"), "HOMSA")
expect_equal(biCode("[homo sapiens neanderthaliensis]"), "HOMSA")
expect_equal(biCode(c("Phascolarctos cinereus", "Macropus rufus")),
             c("PHACI", "MACRU"))
expect_error(biCode(), "argument \"s\" is missing, with no default")

# The test_that() function allows to group related tests, include an informative
# message which test is being executed, and run a number of tests that are
# passed to the function inside a code block - i.e. {...}
# test_that("<descriptive string>, {<code block>})

test_that("NA values are preserved", {
  # bicode() respects vector length: input and output must have the smae length.
  # Therefore NA's can't be simply skipped, bust must be properly passed
  # into output:
  expect_true(is.na((biCode(NA))))
  expect_equal(biCode(c("first", NA, "last")),
               c("FIRST", NA, "LAST."))
})


# Task: Write a function calcGC() that calculates GC content in a sequence.
#       Hint: you could strsplit() the sequence into a vector, and count
#       G's and C's; or you could use gsub("[AT]", "", <sequence>) to remove
#       A's and T's, and use nchar() before and after to calculate the content
#       from the length difference.
#       Then write tests that:
#          confirm that calcGC("AATT") is 0;
#          confirm that calcGC("ATGC") is 0.5;
#          confirm that calcGC("AC")   is 0.5;
#          confirm that calcGC("CGCG") is 1;


# =    2  Organizing your tests  ===============================================


# Tests are only useful if they are actually executed and we need to make sure
# there are no barriers to do that. The testthat package supports automatic
# execution of tests:
#  - put your tests into an R-script,
#  - save your tests in a file called "test_<my-function-name>.R"
#  - execute the test with test_file("test_<my-function-name>.R") ...
#  ... or, if you are working on a project ...
#  - place the file in a test-directory (e.g. the directory "test" in this
#      project),
#  - execute all your tests with test_dir("<my-test-directory>")

# For example I have provided a "tests" directory with this project, and
# placed the file "test_biCode.R" inside.
file.show("./tests/test_biCode.R")

# Execute the file ...
test_file("./tests/test_biCode.R")

# .. or execute all the test files in the directory:
test_dir("./tests")

# ==   2.1  Testing scripts  ===================================================

# Scripts need special consideration since we do not necessarily source() them
# entirely. Therefore automated testing is not reasonable. What you can do
# instead is to place a conditional block at the end of your script, that
# never gets executed - then you can manually execute the code in the block
# whenever you wish to test your functions. For example:

if (FALSE) {
  # ... your tests go here

}

# ==   2.2  Rethinking testing  ================================================

# However, it is important to keep in mind that different objectives lead to
# different ideas of what works best. There is never a "best" in and of itself,
# the question is always: "Best for what?" While automated unit testing is a
# great way to assure the integrity of packages and larger software artefacts as
# they are being developed, more loosely conceived aggregates of code - like the
# scripts for this course for example - have different objectives and in this
# case I find the testthat approach to actually be inferior. The reason is its
# tendency to physically separate code and tests. Keeping assets, and functions
# that operate on those assets separated is always poor design. I have found
# over time that a more stable approach is to move individual functions into
# their individual scripts, all in one folder, one function (and its helpers)
# per file, and examples, demos and tests in an if (FALSE) { ... } block, as
# explained above.



# =    3  Task solutions  ======================================================

calcGC <- function(s) {
  s <- gsub("[^agctAGCT]", "", s)
  return(nchar(gsub("[atAT]", "", s)) / nchar(s))
}

expect_equal(calcGC("AATT"), 0)
expect_equal(calcGC("ATGC"), 0.5)
expect_equal(calcGC("AC"),   0.5)
expect_equal(calcGC("CGCG"), 1)



# [END]
