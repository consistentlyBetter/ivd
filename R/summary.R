##' @title Filter coda object
##' @param stats summary object
##' @param Kr Number of random location efx
##' @return filtered coda 
##' @author philippe
##' @keywords internal
.summary_table <- function(stats, Kr ) {
  ## Convert row names into a format that makes it easy to identify the rows to exclude
  rows_to_exclude <- c()
  for (row_name in rownames(stats)) {
    if (grepl("^R\\[", row_name)) {
      ## Extract the numeric indices from the row name
      elements <- as.numeric(unlist(regmatches(row_name, gregexpr("[0-9]+", row_name))))
      if (length(elements) == 2) {
        ## Exclude if row index is less than or equal to column index
        ## This removes both the diagonal and the upper triangular part
        if (elements[1] <= elements[2]) {
          rows_to_exclude <- c(rows_to_exclude, row_name)
        }
      }
    } else if (grepl("^ss\\[", row_name)) {
      ## Exclude the rows that pertain to location as SS is always 1
      row_number <- as.numeric(unlist(regmatches(row_name, gregexpr("[0-9]+", row_name)))[1])
      if (row_number <= Kr) {
        rows_to_exclude <- c(rows_to_exclude, row_name)
      }
    } else if (grepl("^sigma\\_rand\\[", row_name)) {
      ## Extract the numeric indices from the row name
      elements <- as.numeric(unlist(regmatches(row_name, gregexpr("[0-9]+", row_name))))
      if (length(elements) == 2) {
        ## Keep only diagonal elements by excluding if row index is not equal to column index
        if (elements[1] != elements[2]) {
          rows_to_exclude <- c(rows_to_exclude, row_name)
        }
      }
    } else if (grepl("^u\\[", row_name)) {
      rows_to_exclude <- c(rows_to_exclude,  row_name )
    }
  }
  ## Exclude rows
  stats_filtered <- stats[!rownames(stats) %in% rows_to_exclude, ]
  return(stats_filtered )
}




##' Summarize ivd object
##' @title Summary of posterior samples
##' @param object ivd object
##' @param digits Integer (Default: 2, optional). Number of digits to round to when printing.
##' @param ... Not used
##' @return summary.ivd object
##' @author Philippe Rast
##' @importFrom coda gelman.diag mcmc mcmc.list
##' @export

summary.ivd <- function(object, digits = 2, ...) {
  ## Extract samples from list: This does not include warmup
  extract_samples <- .extract_to_mcmc(object)

  ## rbind lists to one big object
  combined_samples <- do.call(rbind,  extract_samples)
  cn <- colnames(combined_samples )

  ## exclude mu and tau
  mu_index <- grep('mu',  cn )
  tau_index <- grep('tau',  cn )
  
  ## mcmc from coda
  summary_stats <- summary(mcmc(combined_samples[, -c(mu_index, tau_index)]))
  
  ## Add n_eff and R-hats
  summary_stats$statistics <- cbind(summary_stats$statistics,
                                    n_eff = object$n_eff[-c(mu_index, tau_index)],
                                    'R-hat' = object$rhat_values[-c(mu_index, tau_index)])
  
  ## summary_stats is a coda object with 2 summaries
  ## Means:
  sm <- .summary_table( summary_stats$statistics, Kr = object$nimble_constants$Kr )
  ## Quantiles:
  sq <- .summary_table( summary_stats$quantiles, Kr = object$nimble_constants$Kr )

  ## combine to printable object and rearrange so that R-hat is in the last column

  s_comb <- cbind(sm[, c("Mean", "SD", "Time-series SE")],  sq[, c(1, 3, 5)], sm[, c("n_eff", "R-hat")])
  colnames( s_comb ) <- c("Mean", "SD", "Time-series SE", "2.5%", "50%", "97.5%", "n_eff", "R-hat")

  table <- round(s_comb, 3)

  ## Add original variable names to output
  ## location fixed effects:
  beta_index <- grep('beta', rownames(table))
  if(length(beta_index) != length(object$X_location_name)) stop("Check beta_index in summary.R" )
  rownames(table)[beta_index] <- object$X_location_name
  ## scale fixed effects:
  zeta_index <- grep('zeta', rownames(table))
  if(length(zeta_index) != length(colnames(object$X_scale)) ) stop("Check zeta_index in summary.R" )
  rownames(table)[zeta_index] <- paste("scl_", colnames(object$X_scale), sep = '')
  ## random effects sd
  sigma_rand_index <- grep('sigma_rand', rownames(table))
  sd_names <- c( object$Z_location_names, paste0("scl_", colnames(object$Z_scale)) )
  if(length(sigma_rand_index) != length(sd_names) ) stop("Check sd_index in summary.R")
  rownames(table)[sigma_rand_index] <- paste0("sd_", sd_names)
  
  ## Rewrite correlatin variable
  ## number of random effects:
  cols <- length(sigma_rand_index)
  ## Place holder variable: R is indexed as vech
  M <- matrix(1:cols^2, ncol = cols )
  ## record positions
  vech <- M[lower.tri(M )]
  ## match variable names to position
  corrvar <- expand.grid(sd_names, sd_names)[vech,]
  R_index <-  grep('R\\[', rownames(table))
  if( nrow(corrvar) != length(R_index) )stop("Check R_index in summary.R" )
  rownames(table)[R_index] <- paste0("R[",paste(corrvar[, 1], corrvar[, 2], sep = ", "), "]")

  ## (Intercept) is annoying long. Change to Int.
  Int_index <- grep("\\(Intercept\\)", rownames(table))
  rownames(table)[Int_index] <- gsub("\\(Intercept\\)",  "Intc", rownames(table)[Int_index])

  ## TODO: Link SS to actual clustering units
  
  table
  cat("Summary statistics for ivd model:\n")
  .newline

  ##
  chains <- object$workers
  cat("Chains (workers):",  chains, "\n\n")
  
  ## extract WAIC per chain 
  waic_values <- sapply(object$samples, FUN = function(chain) chain$WAIC$WAIC)
  ## extract lppd per chain 
  lppd_values <- sapply(object$samples, FUN = function(chain) chain$WAIC$lppd)
  ## extract pWAIC per chain 
  pwaic_values <- sapply(object$samples, FUN = function(chain) chain$WAIC$pWAIC)

  ## Average across chains
  average_waic <- mean(waic_values)
  average_lppd <- mean(lppd_values)
  average_pwaic <- mean(pwaic_values)
  
  print(table)
  .newline
  
  ## Print the results
  cat("\nWAIC:", average_waic, "\n")
  cat("elppd:", average_lppd, "\n")
  cat("pWAIC:", average_pwaic, "\n")
  
  class(table) <- "summary.ivd"
  invisible(table)
}


##' @title Print helper - Return new line(s).
##' @param n Integer (Default: 1). Number of new lines.
##' @return Prints new lines.
##' @author Philippe Rast
##' @keywords internal
.newline <- function(n = 1) {
    for(i in 1:n) {
        cat("\n")
    }
}
