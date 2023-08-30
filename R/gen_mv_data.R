#' gen_mv_data
#'
#' @param n A numeric specifying the number of units.
#' @param n_j A numeric specifying the number of observations per unit.
#'
#' @importMethodsFrom Matrix t
#' @importFrom Matrix sparseMatrix KhatriRao
#' @importFrom mvtnorm rmvnorm
#' @importFrom methods selectMethod as
#' @export
gen_mv_data <- function(n, n_j) {
  N <- n * n_j

  # design matrix + betas
  X <- cbind(1, sample(0:1, size = N, replace = TRUE))
  B1 <- rbind(1, 2)
  B2 <- rbind(3, 4)

  # random effect SDs
  tau <- diag(c(3, 2, 2, 2))

  # 4 x 4 cor matrix for random effects
  Rb <- rbind(
    c(1, 0.1, 0.2, 0.3),
    c(0.1, 1, 0.1, 0.1),
    c(0.2, 0.1, 1, 0.1),
    c(0.3, 0.1, 0.1, 1)
  )

  # vcov matrix for random effects
  Tau <- tau %*% Rb %*% tau

  # generate random effects and stack them for each regression
  u_mat <- mvtnorm::rmvnorm(n, rep(0, 4), Tau)

  # -- random effects for y1
  u_list1 <- lapply(1:n, function(i) cbind(u_mat[i, 1:2]))
  u1 <- do.call(rbind, u_list1)
  # -- random effects for y2
  u_list2 <- lapply(1:n, function(i) cbind(u_mat[i, 3:4]))
  u2 <- do.call(rbind, u_list2)

  # generate factor levels + Z matrix
  # -- taken from lme4 documentation
  g <- gl(n, n_j)
  J <- as(g, Class = "sparseMatrix")
  t2 <- selectMethod("t", signature = "dgCMatrix")
  Ji <- t2(J)
  Z <- t(KhatriRao(t(Ji), t(X)))

  # cor matrix for residuals
  Rw <- rbind(
    c(1, 0.3),
    c(0.3, 1)
  )

  # residual SDs
  sigma <- c(2, 0.5)

  # vcov matrix for residuals
  Sigma <- diag(sigma) %*% Rw %*% diag(sigma)
  eps <- mvtnorm::rmvnorm(N, c(0,0), Sigma)

  # generate data
  y <- X %*% cbind(B1, B2) + Z %*% cbind(u1, u2) + eps

  df <- data.frame(y1 = y[, 1], y2 = y[, 2], x = X[, 2], id = g)
  return(df)
}

