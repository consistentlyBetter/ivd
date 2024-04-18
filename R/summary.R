##' @title Filter coda object
##' @param stats summary object
##' @param Kr Number of random location efx
##' @param Sr Number of random scale efx
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
##' @importFrom coda gelman.diag
##' @export

summary.ivd <- function(object, digits = 2, ...) {
  summary_stats <- summary(object$samples)
  ## summary_stats is a coda object with 2 summaries
  sm <- .summary_table( summary_stats$statistics, Kr = object$nimble_constants$Kr )
  sq <- .summary_table( summary_stats$quantiles, Kr = object$nimble_constants$Kr )
  ## obtain rhat
  rhat <- gelman.diag(object$samples[, rownames(sm)])
  ## combine to printable object
  s_comb <- cbind(sm[,-3],  sq[, c(1, 3, 5)], rhat$psrf )
  
  table <- round(s_comb, 3)

  cat("Summary statistics for ivd model:\n")
  .newline
  
  print(table)
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
