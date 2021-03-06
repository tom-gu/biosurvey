biosurvey: Tools for Biological Survey Planning
================

-   [Project description](#project-description)
    -   [Status of the project](#status-of-the-project)
-   [Package description](#package-description)
-   [Installing the package](#installing-the-package)
-   [biosurvey functions and
    vignettes](#biosurvey-functions-and-vignettes)
-   [Workflow description](#workflow-description)

<!-- badges: start -->

[![R build
status](https://github.com/claununez/biosurvey/workflows/R-CMD-check/badge.svg)](https://github.com/claununez/biosurvey/actions)
<!-- badges: end -->

<br>
<hr>

<img src='README_files/biosurvey1.png' align="right" height="200" /></a>

**This repository is for the project “Biological Survey Planning
Considering Hutchinson’s Duality” developed during the program GSoC
2020.**

<br>

Project description
-------------------

Student: *Claudia Nuñez-Penichet*

GSoC Mentors: *Narayani Barve, Vijay Barve, Tomer Gueta*

Complete list of authors: *Claudia Nunez-Penichet, Marlon E. Cobos, A.
Townsend Peterson, Jorge Soberon, Narayani Barve, Vijay Barve, Tomer
Gueta*

Motivation:

Given the increasing intensity of threats to biodiversity in the world,
one of the challenges in biodiversity conservation is to complete
inventories of existing species at distinct scales. Species
distributions depend on the relationships between accessible areas,
environmental conditions, and biotic interactions. As planning a survey
system only aims to register species in a region, biodiversity
interaction can be overlooked in this case. However, the relationship
between environmental conditions and the geographic configuration of an
area is of crucial importance when trying to identify key sites for
biodiversity surveys. Among the diverse packages in R for selecting
survey sites, such considerations are not implemented and are limited to
a random selection of sampling sites or analyses that allow detecting
potential sampling sites based on the environmental similarity between
sampled and unsampled areas. Given the need for more solutions, the
**biosurvey** package aimed for considering the relationship between
environmental and geographic conditions in a region when designing
survey systems that allow sampling of most of its biodiversity.

### Status of the project

At the moment we have completed the three main modules of the package.
We have made modifications to the original list of products, which have
helped us to improve the package functionality. The package is fully
functional and almost ready for submission to CRAN.

All commits made can be seen at the
<a href="https://github.com/claununez/biosurvey/commits/master" target="_blank">complete
list of commits</a>.

Following you can find a brief description of this R package, as well as
general descriptions of how to use it.

<br>

Package description
-------------------

The biosurvey R package implements multiple tools to allow users to
select sampling sites increasing efficiency of biodiversity survey
systems by considering the relationship of environmental and geographic
conditions in a region. Three main modules are included: 1) Data
preparation; 2) Selection of sets of sites for biodiversity sampling;
and, 3) Tools for testing efficiency of distinct sets of sampling sites.
Data are prepared ways that avoid the need for more data in posterior
analyses, and allow concentrating in critical methodological decisions
to select sampling sites. Various algorithms for selecting sampling
sites are available, and options for considering pre-selected sites
(known to be important for biodiversity monitoring) are included.
Visualization is a critical component in this set of tools and most of
the results obtained can be plotted to help to understand their
implications. The options for selecting sampling sites included here
differ from other implementations in that they consider the
environmental and geographic structure of a region to suggest sampling
sites that could increase the efficiency of efforts dedicated to
monitoring biodiversity.

<br>

Installing the package
----------------------

biosurvey is in a GitHub repository and can be installed and/or loaded
using the code below (make sure to have Internet connection). If you
have any problem during installation, restart R session, close other
RStudio sessions you may have open, and try again. If during the
installation you are asked to update packages, do so if you don’t need a
specific version of one or more of the packages to be installed. If any
of the packages gives an error when updating, please install it alone
using install.packages(), then try re-installing biosurvey again.

    # Installing and loading packages
    if(!require(remotes)){
      install.packages("remotes")
    }

    # To install the package use
    remotes::install_github("claununez/biosurvey")

    # To install the package and its vignettes use   
    remotes::install_github("claununez/biosurvey", build_vignettes = TRUE)

    # Load biosurvey
    library(biosurvey)

<br>

biosurvey functions and vignettes
---------------------------------

To check all functions in the package use:

    help(biosurvey)

<br>

If the package was installed with its vignettes you can see all options
with:

    vignette(package = "biosurvey")

<br>

To check each vignette you can use:

    # For a guide on how to prepare data for analysis
    vignette("biosurvey_preparing_data")

    # For a guide on how to select sampling sites
    vignette("biosurvey_selecting_sites")

    # For a guide on how to select sampling sites when some sites have been preselected
    vignette("biosurvey_selection_with_preselected_sites")

    # For a guide on how to use the testing module
    vignette("biosurvey_testing_module")

<br>

Workflow description
--------------------

To use biosurvey efficiently the first thing to do is to prepare an
object containing all information to be used in following analyses. This
can be done using the function `preapare_master_matrix`. After that
recommend intermediate steps are: exploring the data using the function
`explore_data_EG` and creating blocks of points in environmental space
using `make_blocks`. Then, distinct functions can be used to select
sampling sites:

-   `random_selection`.- Random selection of sites to be sampled in a
    survey.
-   `uniformG_selection`.- Selection of sites to be sampled in a survey,
    with the goal of maximizing uniformity of points in geographic
    space.
-   `uniformE_selection`.- Selection of sites to be sampled in a survey,
    with the goal of maximizing uniformity of points in environmental
    space.
-   `EG_seletion`.- Selection of sites to be sampled in a survey, with
    the goal of maximizing uniformity of points in environment, but
    considering geographic patterns of data.

All functions mentioned above have the option to include user
preselected sites which will be inserted as part of the selection,
trying to maintaining the properties of each algorithm. See also how
your selected sites look like with the function `plot_sites_EG`.

After selection of sampling sites and if enough data are available,
functions from the testing module can be used to explore which of the
sets of sites selected could be better to monitor biodiversity more
efficiently. Explore the following functions to explore your data and
how well your selected sites perform in representing the exiting
biodiversity:

-   `prepare_base_PAM`.- Prepares a presence-absence matrix (PAM) in
    which all sites of interest (rows) will have a value for presence or
    absence of a species of interest (columns).
-   `PAM_indices`.- Calculates a set of biodiversity indices using
    values contained in a presence-absence matrix.
-   `plot_PAM_geo`.- Plot of PAM indices in geography.
-   `subset_PAM`.- Subsets of a base\_PAM object according to survey
    sites contained in a master\_selection object.
-   `selected_sites_SAC`.- Creates species accumulation curves for each
    set of selected sites contained in elements of PAM\_subset.
-   `plot_SAC`.- Creates species accumulation curve plots for selected
    sites.
-   `compare_SAC`.- Creates comparative plots of two species
    accumulation curves from information contained in lists obtained
    with the function `selected_sites_SAC`.
