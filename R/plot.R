#' caterpillar_plot
#'
#' Create a caterpillar plot of the random effects produced by `ivd` models.
#'
#'
#' @param obj An object of type `ivd`.
#' @param ci The width of the credible interval that should be used. Defaults to 0.9.
#' @param col_id Whether the plot should color in points by their unique identifier.
#' @param legend Should legend be included? Defaults to TRUE
#' @param ... Currently not in use.
#'
#' @import ggplot2 patchwork
#' @export


caterpillar_plot <- function(obj, ci = 0.9, col_id = TRUE, legend = TRUE, ...) {
  ranef_summ <- ranef_summary(obj, ci = ci, as_df = TRUE)

  ## To prevent "no visible binding for global variable" error init variables:
  PIP = model = id = Post_mean = lb = ub = NULL
  
  type <- obj$call[1]
  if (grepl("beta", type)) {
    sorted_ranefs2 <- ranef_summ[grepl("theta2", rownames(ranef_summ)), ]
    sorted_ranefs2 <- sorted_ranefs2[order(sorted_ranefs2$Post_mean), ]

    sorted_ranefs2$id <- gsub("theta2_", "", row.names(sorted_ranefs2))
    sorted_ranefs2$id <- factor(sorted_ranefs2$id, levels = c(sorted_ranefs2$id))

    sorted_ranefs1 <- ranef_summ[grepl("theta1", rownames(ranef_summ)), ]
    sorted_ranefs1 <- sorted_ranefs1[order(sorted_ranefs1$Post_mean), ]

    sorted_ranefs1$id <- gsub("theta1_", "", row.names(sorted_ranefs1))
    # make factor levels same as ranefs2
    sorted_ranefs1$id <- factor(sorted_ranefs1$id, levels = c(sorted_ranefs1$id))

    colnames(sorted_ranefs1)[2:3] <- c("lb", "ub")
    colnames(sorted_ranefs2)[2:3] <- c("lb", "ub")

    p1 <-
      ggplot(sorted_ranefs1, aes(x = id, y = Post_mean)) +
      geom_hline(yintercept = 0, col = "red", linetype = "dashed") +
      geom_errorbar(aes(ymin = lb, ymax = ub), width = 0.1) +
      labs(y = "theta1 (intercept random effects)")

    p2 <-
      ggplot(sorted_ranefs2, aes(x = id, y = Post_mean)) +
      geom_hline(yintercept = 0, col = "red", linetype = "dashed") +
      geom_errorbar(aes(ymin = lb, ymax = ub), width = 0.1) +
      labs(y = "theta2 (slope random effects)")

    if ( !legend ) {
      p1 <- p1 + theme(legend.position="none")
      p2 <- p2 + theme(legend.position="none")
    }

    if (col_id) {
      p1 <-
        p1 + geom_point( aes(col = id), size = 2) #+ guides(col = "none")
      p2 <-
        p2 + geom_point( aes(col = id), size = 2) #+ guides(col = "none")
    } else {
      p1 <- p1 + geom_point(size = 2)
      p2 <- p2 + geom_point(size = 2)
    }

    p <- p2/p1 #+ plot_layout(guides = "collect")

    return(p)

  } else { # begin plot for 'alpha' model
    # sort random effects and created a sorted id
    sorted_ranefs <- ranef_summ[order(ranef_summ$Post_mean), ]
    sorted_ranefs$id <- gsub("theta_", "", row.names(sorted_ranefs))
    sorted_ranefs$id <- factor(sorted_ranefs$id, levels = c(sorted_ranefs$id))

    colnames(sorted_ranefs)[2:3] <- c("lb", "ub")

    p <-
      ggplot(sorted_ranefs, aes(x = id, y = Post_mean)) +
      geom_hline(yintercept = 0, col = "red", linetype = "dashed") +
      geom_errorbar(aes(ymin = lb, ymax = ub), width = 0.1) +
      labs(y = "theta")

    if ( !legend ) {
      p <- p + theme(legend.position="none")
    }

    if (col_id) {
      p <- p + geom_point(aes(col = id), size = 2)
    } else {
      p <- p + geom_point(size = 2)
    }

    return(p)
  }

}


#' pip_plot
#'
#' @param obj An object of type `ivd`
#' @param pip_line Where the line denoting a posterior inclusion cut-off should be drawn. Defaults to 0.5.
#' @param col_id Whether the plot should color in points by their unique identifier.
#' @param legend Should legend be included? Defaults to TRUE
#' @param ... Currently not in use
#'
#' @import ggplot2
#' @export

pip_plot <- function(obj, pip_line = 0.5, col_id = TRUE, legend = TRUE, ...) {
  ## To prevent "no visible binding for global variable" error init variables:
  PIP = model = id = Post_mean = lb = ub = NULL

  type <- obj$call[1]
  ranef_summ <- ranef_summary(obj, as_df = TRUE)
  if (grepl("beta", type)) {
    sorted_ranefs <- ranef_summ[grepl("theta2", rownames(ranef_summ)), ]
    sorted_ranefs$id <- gsub("theta2_", "", row.names(sorted_ranefs))
    sorted_ranefs$id <- factor(sorted_ranefs$id, levels = c(sorted_ranefs$id))

    p <-
      ggplot(sorted_ranefs, aes(x = Post_mean, y = PIP)) +
      geom_hline(yintercept = pip_line, col = "red", linetype = "dashed") +
      labs(x = "theta2")

    if ( !legend ) {
      p <- p + theme(legend.position="none")
    }
    
    if (col_id) {
      p <- p + geom_point(aes(col = id), size = 2)
    } else {
      p <- p + geom_point(size = 2)
    }
    return(p)


  } else {
    # sort random effects and created a sorted id
    sorted_ranefs <- ranef_summ[order(ranef_summ$Post_mean), ]
    sorted_ranefs$id <- gsub("theta_", "", row.names(sorted_ranefs))
    sorted_ranefs$id <- factor(sorted_ranefs$id, levels = c(sorted_ranefs$id))

    p <-
      ggplot(sorted_ranefs, aes(x = Post_mean, y = PIP)) +
      geom_hline(yintercept = pip_line, col = "red", linetype = "dashed") +
      labs(x = "theta")

    if ( !legend ) {
      p <- p + theme(legend.position="none")
    }

    if (col_id) {
      p <- p + geom_point(aes(col = id), size = 2)
    } else {
      p <- p + geom_point(size = 2)
    }
    return(p)
  }
}


#' funnel_plot
#'
#' @param obj An object fit with `ivd_mv()`
#' @param ... Currently not in use
#'
#' @import ggplot2
#' @export

funnel_plot <- function(obj, ...) {
  ## To prevent "no visible binding for global variable" error init variables:
  PIP = pip = model = id = Post_mean = lb = ub = NULL

  type <- obj$call[1]
  if (!grepl("mv", type)) stop("funnel_plot() only works with objects produced by ivd_mv()")

  ranef_summ <- ranef_summary(obj, as_df = TRUE)

  pips_df <- subset(ranef_summ, !is.na(PIP))


  pips_df$model <- sapply(row.names(pips_df), function(x) strsplit(x, split = "_")[[1]][3])
  pips_df$model <- ifelse(pips_df$model == "2", "1", "2")

  pips_df$pip <- pips_df$PIP
  pips_df$pip[pips_df$model == "1"] <- -pips_df$PIP[pips_df$model == "1"]



  pips_df$id <- factor(rep(1:obj$data_list$J, 2))

  plot_order <- subset(pips_df, model == "1")
  plot_order <- plot_order[order(plot_order$PIP, decreasing = F), ]



  p <-
    ggplot(pips_df, aes(x = id, y = pip, fill = model)) +
    geom_col(col = "black", width = 1) +
    scale_x_discrete(limits = plot_order$id) +
    scale_y_continuous(labels = abs(seq(-1, 1, 0.5)),
                       breaks = seq(-1, 1, 0.5)) +
    coord_flip()

  return(p)


}

