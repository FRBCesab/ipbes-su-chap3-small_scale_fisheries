#' IPBES Sustainable Use Assessment - Figure Chapter 3 - Small-scale Fisheries
#' 
#' This R script reproduces the Figure 'Small-scale Fisheries' of the 
#' chapter 3 of the IPBES Sustainable Use Assessment. This figure shows the 
#' global distribution of 350 reviewed studies on small-scale fisheries.
#' 
#' @author Nicolas Casajus <nicolas.casajus@fondationbiodiversite.fr>
#' @date 2022/02/07



## Install `remotes` package ----

if (!("remotes" %in% installed.packages())) install.packages("remotes")


## Install required packages (listed in DESCRIPTION) ----

remotes::install_deps(upgrade = "never")


## Load project dependencies ----

devtools::load_all(".")

