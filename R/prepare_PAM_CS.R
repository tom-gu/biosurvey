#' Preparing data for new diversity-range plot
#'
#' @description Preparation of data and details to create diversity-range
#' plots.
#'
#' @param PAM matrix, data.frame, or base_PAM object containing information on
#' species presence and absence for a set of sites. Sites are organized in the
#' rows and species in the columns. See details.
#' @param exclude_column (optional) name or numeric index of columns to be
#' excluded. Default = NULL.
#' @param id_column (optional) name or numeric index of column containing the ID
#' of sites-cells of the PAM. Default = NULL.
#' @param significance_test (logical) whether to perform a test to detect
#' sites-cells that are statistically significant (i.e., the pattern detected
#' can be distinguished o random expectations). Default = FALSE.
#' @param randomization_iterations (numeric) number of iterations for the
#' randomization test used to calculate statistical significance. Default = 100.
#' @param CL (numeric) confidence limit to detect statistically significant
#' values. Default = 0.05.
#' @param picante_iterations (numeric) number of iterations to be used for each
#' matrix randomization process (to be done \code{randomization_iterations}
#' times). This process is done using the function \code{randomizeMatrix}
#' from the package \code{picante}. The default, NULL, uses \code{2 * sum(PAM)}.
#' @param keep_randomizations (logical) whether to keep a matrix with all values
#' from the randomization process. Default = FALSE.
#' @param parallel (logical) whether to perform analyses in parallel.
#' Default = FALSE.
#' @param n_cores (numeric) number of cores to be used when \code{parallel} =
#' TRUE. The default, NULL, uses available cores - 1.
#'
#' @return
#' An S3 object of class PAM_CS if \code{PAM} is a matrix or data.frame,
#' otherwise, the base_PAM that includes the PAM_CS object as part of
#' PAM_indices.
#'
#' Significant vales are presented as a vector in which 0 means non-significant,
#' and 1 and 2 represent significant values below and above confidence limits of
#' random expectations, respectively.
#'
#' @details
#' Diversity-range plot allow explorations of patterns of biodiversity
#' in a region based on the data of presence-absence matrices. The
#' plots to be produced using the information prepared here are a modification
#' of those presented in Arita et al. (2011)
#' \doi{https://doi.org/10.1111/j.1466-8238.2011.00662.x}.
#'
#'
#' @usage
#' prepare_PAM_CS(PAM, exclude_column = NULL, id_column = NULL,
#'                significance_test = FALSE, randomization_iterations = 100,
#'                CL = 0.05, picante_iterations = NULL,
#'                keep_randomizations = FALSE, parallel = FALSE,
#'                n_cores = NULL)
#'
#' @export
#'
#' @importFrom foreach foreach %dopar%
#' @importFrom parallel detectCores
#' @importFrom snow makeSOCKcluster stopCluster
#' @importFrom doSNOW registerDoSNOW
#' @importFrom utils txtProgressBar setTxtProgressBar
#' @importFrom picante randomizeMatrix
#' @importFrom stats cor
#'
#' @examples
#' # data
#' data("b_pam", package = "biosurvey")
#'
#' # preparing data for CS diagram
#' pcs <- prepare_PAM_CS(PAM = b_pam)
#'
#' summary(pcs$PAM_indices$CS_diagram)

prepare_PAM_CS <- function(PAM, exclude_column = NULL, id_column = NULL,
                           significance_test = FALSE,
                           randomization_iterations = 100, CL = 0.05,
                           picante_iterations = NULL,
                           keep_randomizations = FALSE, parallel = FALSE,
                           n_cores = NULL) {

  if (missing(PAM)) {
    stop("Argument 'PAM' is missing.")
  }
  cpam <- class(PAM)[1]
  if (!cpam %in% c("base_PAM", "matrix", "data.frame")) {
    stop("Argument 'PAM' must be of class 'base_PAM' or 'matrix'.")
  }

  # preparing data
  ## data for analyses
  if (cpam == "base_PAM") {
    bp <- PAM$PAM
    site_id <- bp@data[, 1]
    mtt <- bp@data[, -(1:3)]
  } else {
    if (!is.null(id_column)) {
      site_id <- PAM[, id_column]
    } else {
      site_id <- 1:nrow(PAM)
    }
    mtt <- PAM[, -exclude_column]
  }

  ## getting valid sites-cells and indices
  keep <- rowSums(mtt, na.rm = TRUE) > 0
  mtt <- mtt[keep, ]
  site_id <- site_id[keep]
  keepc <- colSums(mtt, na.rm = TRUE) > 0
  mtt <- mtt[, keepc]
  PAM <- PAM_indices(mtt, indices = "all")

  # Preparing values to be used in plots
  s <- PAM$One_value_indices["Species", ]
  n <- PAM$One_value_indices["Sites_Cells", ]
  alfas <- PAM$Richness_normalized
  fist <- PAM$Dispersion_field / n
  fists <- fist / s

  # prepare vertex of plot limits
  arange <- range(alfas)
  rrange <- range(PAM$Mean_composition_covariance)
  betty <- PAM$One_value_indices["Beta_Whittaker", ]
  vx <- c(arange, rev(arange))
  vy <- c(rrange[1] + arange[1] / betty, rrange[1] + arange[2] / betty,
          rrange[2] + arange[2] / betty, rrange[2] + arange[1] / betty)

  # Spearman correlation
  sper <- cor(cbind(alfas, fist), method = "spearman")[[1, 2]]

  # significance test
  if (significance_test == TRUE) {
    mt3 <- mtt

    ## running randomization
    reps <- randomization_iterations
    pit <- ifelse(is.null(picante_iterations), 2 * sum(mt3), picante_iterations)

    if (parallel == TRUE) {
      ## preparing parallel running
      n_cores <- ifelse(is.null(n_cores), parallel::detectCores() - 1, n_cores)
      cl <- snow::makeSOCKcluster(n_cores)
      doSNOW::registerDoSNOW(cl)

      ## progress bar
      pb <- utils::txtProgressBar(min = 1, max = reps, style = 3)
      progress <- function(n) {utils::setTxtProgressBar(pb, n)}
      opts <- list(progress = progress)

      ## processing
      alea <- foreach::foreach(i = 1:reps, .inorder = TRUE, .options.snow = opts,
                               .combine = "cbind") %dopar% {
                                 mt3 <- picante::randomizeMatrix(mtt,
                                                                 null.model = "independentswap",
                                                                 iterations = pit)
                                 pin <- PAM_indices(mt3, indices = c("DF"))
                                 return((pin$Dispersion_field / n) / s)
                               }

      snow::stopCluster(cl)

    } else {
      ## progress bar
      pb <- utils::txtProgressBar(min = 1, max = reps, style = 3)

      ## processing
      alea <- matrix(0, nrow = n, ncol = reps)

      for (x in 1:reps) {
        Sys.sleep(0.1)
        utils::setTxtProgressBar(pb, x)

        mt3 <- picante::randomizeMatrix(mtt, null.model = "independentswap",
                                        iterations = pit)
        pin <- PAM_indices(mt3, indices = c("DF"))
        alea[, x] <- (pin$Dispersion_field / n) / s
      }
    }

    ## identifying significant cells
    cl <- CL / 2

    qq <- vapply(1:n, FUN.VALUE = numeric(1), FUN = function(x) {
      qqq <- quantile(alea[x, ], prob = c(0 + cl, 1 - cl))
      ifelse(fists[x] > qqq[1] & fists[x] < qqq[2], 0,
             ifelse(fists[x] < qqq[1], 1, 2))
    })
  }

  # preparing results
  PAM$CS_diagram <- new_PAM_CS(Species = s, Sites_cells = n,
                               Beta_W = betty, Spearman_cor = sper,
                               Theoretical_boundaries = list(x = vx, y = vy),
                               Richness_normalized = alfas,
                               Dispersion_field_normalized = fist)

  if (significance_test == TRUE) {
    names(qq) <- site_id
    PAM$CS_diagram$S_significance_id <- qq

    if (keep_randomizations == TRUE) {
      PAM$CS_diagram$Randomized_DF <- alea
    }
  }

  # returning results
  if (cpam == "base_PAM") {
    return(new_base_PAM(PAM = bp, PAM_indices = PAM))
  } else {
    return(PAM$CS_diagram)
  }
}
