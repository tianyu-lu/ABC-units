# tocID <- "BIN-PHYLO-Tree_building.R"
#
# Purpose:  A Bioinformatics Course:
#              R code accompanying the BIN-PHYLO-Tree_building unit.
#
# Version:  1.2
#
# Date:     2017-10   2020-09
# Author:   Boris Steipe (boris.steipe@utoronto.ca)
#
# Versions:
#           1.2    deprecate save()/load() for saveRDS()/readRDS(); Mac:
#                  instructions to authorize proml.app
#           1.1    Change from require() to requireNamespace(),
#                      use <package>::<function>() idiom throughout,
#           1.0    First 2017 version
#           0.1    First code copied from 2016 material.
#
#
# TODO:
#           Add MrBayes
# https://cran.r-project.org/web/packages/phangorn/vignettes/IntertwiningTreesAndNetworks.html
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
#TOC>   Section  Title                                       Line
#TOC> -----------------------------------------------------------
#TOC>   1        Calculating Trees                             48
#TOC>   1.1        PROMLPATH ...                               68
#TOC>   1.1.1          ... on the Mac                          73
#TOC>   1.1.2          ... on Windows                         101
#TOC>   1.1.3          ... on Linux                           115
#TOC>   1.1.4          Confirming PROMLPATH                   120
#TOC>   1.2        Building a maximum likelihood tree         134
#TOC> 
#TOC> ==========================================================================


# =    1  Calculating Trees  ===================================================


# Follow the instructions found at phylip's home on the Web to install. If you
# are on a Windows computer, take note of the installation directory.

# After you have installed Phylip on your computer, install the R package that
# provides an interface to the Phylip functions.

if (! requireNamespace("Rphylip", quietly = TRUE)) {
  install.packages("Rphylip")
}
# Package information:
#  library(help = Rphylip)       # basic information
#  browseVignettes("Rphylip")    # available vignettes
#  data(package = "Rphylip")     # available datasets

# This will install RPhylip, as well as its dependency, the package "ape".


# ==   1.1  PROMLPATH ...  =====================================================
# The next part may be tricky. You will need to figure out where
# on your computer Phylip has been installed and define the path
# to the proml program that calculates a maximum-likelihood tree.

# ===   1.1.1  ... on the Mac                    
# On the Mac, the standard installation places a phylip folder
# in the /Applications directory. That folder contains all the
# individual phylip programs as <name>.app files. These are not
# the actual executables, but "app" files are actually directories
# that contain the required resources for a program to run.

# The executable is in a subdirectory and you can point Rphylip
# directly to that subdirectory to find the program it needs:
# PROMLPATH <- "/Applications/phylip-3.695/exe/proml.app/Contents/MacOS"

# However, RPHYLIP will not be able to run PHYLIP applications immediately,
# because they have not been "signed" by the PHYLIP developers. The process
# will terminate by your system, with a warning.

#   -  Navigate to the phylip folder in your ~/Applications directory
#   -  Descend into the "exe" folder and find  proml.app
#   -  Ctrl-click  proml.app  and choose "Open". A dialogue will show that
#      says: "macOS cannot verify the developer of “proml.app”.
#             Are you sure you want to open it?"
#   -  Click open to continue. You may need to allow access to the terminal
#      as well. When the proml terminal session open, you can type
#      Ctrl-c to abort the program and close the window.
#
#   This adds proml.app to the list of known-good programs and you will not
#   need to repeat this process.
#

# ===   1.1.2  ... on Windows                    
# On Windows you need to know where the programs have been installed, and you
# need to specify a path that is correct for the Windows OS. Find the folder
# that is named "exe", and right-click to inspect its properties. The path
# should be listed among them.

# If the path looks like "C:\Users\Meng\Programs\phylip-3.695\exe", then your
# assignment has to be
# PROMLPATH <- "C:/Users/Meng/Programs/phylip-3.695/exe"
# (Note: "/", not "\")

# I have heard that your path must not contain spaces, and it is prudent to
# avoid other special characters as well.

# ===   1.1.3  ... on Linux                      
# If you are running Linux I trust you know what to do. It's probably
# something like
# PROMLPATH <- "/usr/local/phylip-3.695/bin"

# ===   1.1.4  Confirming PROMLPATH              
# Confirm that the settings are right.
PROMLPATH                # returns the path
list.dirs(PROMLPATH)     # returns the directories in that path
list.files(PROMLPATH)    # lists the files [1] "proml"   "proml.command"

# If "proml" is NOT among the files that the last command returns, you
# can't continue. Ask on the mailing list for advice.

# If everything is good, you can add the line that defines PROMLPATH to
# myScripts/.myProfile.R - the path will then be automatically set when
# you quit RStudio and return.


# ==   1.2  Building a maximum likelihood tree  ================================
# Now read the mfa file you have saved in the BIB-PHYLO-Data_preparation unit,
# as a "proseq" object with the read.protein() function of the RPhylip package:

apsIn <- Rphylip::read.protein("data/APSESphyloSet.mfa")
str(apsIn)

# ... and you are ready to build a tree.

# There are many fast options in PHYLIP - we will use the most _accurate_ one
# that it has: proml, a maximum-likelihood tree building program for protein
# data.

# Building maximum-likelihood trees can eat as much computer time
# as you can throw at it. Calculating a tree of 48 APSES domains
# with default parameters of Rproml() runs for more than half a day
# on my computer. But we have only twelve sequences here, so the
# process will take us about 5 to 15 minutes. Run this, and anjoy a good cup
# of coffee while you are waiting.

apsTree <- Rphylip::Rproml(apsIn, path=PROMLPATH)

# A quick first look:

plot(apsTree)

# save your tree:
saveRDS(apsTree, file = "data/APSEStreeRproml.rds")

# If this did not work, ask for advice.




# [END]
