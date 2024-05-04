##' Define data from formula
##' @param data Data object in long format
##' @param location_formula Formula for location
##' @param scale_formula Formula for scale
##' @keywords internal
prepare_data_for_nimble <- function(data, location_formula, scale_formula) {
  ## Helper function to prepare model parts
  prepare_model_part <- function(data, formula, is_scale_model = FALSE) {
    ## Parse the formula to get response and predictors
    response_var <- if(is_scale_model) NA else all.vars(formula)[1]

    fixed_effects <- strsplit(deparse(formula ), split = "\\+ \\(", perl = TRUE)[[1]][1]
    ## slplit out random effects, first split contains grouping variable
    random_effects_F <- strsplit(deparse(formula ), split = "\\+ \\(", perl = TRUE)[[1]][2]
    ## split at | 
    random_effects <- strsplit(random_effects_F, split = "\\|", perl = TRUE)[[1]][1]

    predictors <- all.vars(formula)[-length(all.vars(formula) )]
    if (!is_scale_model) {
      predictors <- predictors[-1]  # Exclude the response variable for location model
    }    
    
    ## Creating X matrix
    X_formula <- update.formula(formula,   fixed_effects )
      #update.formula(formula, paste("~", paste(predictors, collapse = "*")))
    X_matrix <-  model.matrix(X_formula, data)
    
    ## For Z, random effects predictors
    Z_matrix <- if(length(predictors) > 0 ) {
                  model.matrix( formula( paste("~", random_effects) ), data)
                } else {
                  stop("Random effects missing")
                }
    list(X = X_matrix, Z = Z_matrix) # Adjusting for intercept
  }
  
  ## Extracting the grouping variable from the location formula
  location_formula_string <- deparse(location_formula)
  grouping_variable_match <- regmatches(location_formula_string, regexec("\\|\\s*(\\w+)", location_formula_string))
  if (length(grouping_variable_match[[1]]) < 2) {
    stop("Grouping variable not found in the location formula.")
  }
  grouping_variable <- grouping_variable_match[[1]][2]
  ## Extracting the grouping variable from the scale formula
  ## Only support models where grouping variable is the same for location and scale
  scale_formula_string <- deparse(scale_formula)
  scl_grouping_variable_match <- regmatches(scale_formula_string, regexec("\\|\\s*(\\w+)", scale_formula_string))
  if (length(scl_grouping_variable_match[[1]]) < 2) {
    stop("Grouping variable not found in the scale formula.")
  }
  ## Check that both location and scale have same grouping variable
  if(grouping_variable != scl_grouping_variable_match[[1]][2]) {
    stop("Location and scale grouping variable needs to be the same.")
  }
    
  ## Ensure the grouping variable is numeric
  if(!is.numeric(data[[grouping_variable]])) {
    data[[grouping_variable]] <- as.numeric(as.factor(data[[grouping_variable]]))
  }
  ## Ensure that grouping variable is a continuous sequence without any missing values
  if( !identical(  seq_len( max(unique(data[[grouping_variable]])) ),
                 as.integer( sort(unique(data[[grouping_variable]])))) ) {
    stop("Grouping variable is not a sorted and continuous index.")
  }
  
  ## Processing location and scale models
  location_data <- prepare_model_part(data, formula = location_formula)
  scale_formula_cleaned <- gsub("sigma = ", "", deparse(scale_formula))  # Remove "sigma = " if present
  scale_data <- if(!is.null(scale_formula_cleaned) && nzchar(scale_formula_cleaned)) {
                  prepare_model_part(data, formula = as.formula(paste(scale_formula_cleaned)), TRUE)
  } else {
    list(X = NULL, Z = NULL)
  }
  
  # Assemble the data structure for NIMBLE
  list(data = list(
         Y = data[[all.vars(location_formula)[1]]],  # Assuming the first variable is the response
         X = location_data$X, 
         Z = location_data$Z, 
         X_scale = scale_data$X, 
         Z_scale = scale_data$Z
       ), 
       groups = length(unique(data[[grouping_variable]])), 
       group_id = data[[grouping_variable]],
       response_var = all.vars(location_formula)[1]
  )
}
##' Extract samples to mcmc object
##' @param obj 
##' @return mcmc object
##' @author Philippe Rast
##' @keywords internal 
.extract_to_mcmc <- function(obj) {
  e_to_mcmc <- lapply(obj$samples, FUN = function(x) mcmc(x$samples))
  return(e_to_mcmc)
}
