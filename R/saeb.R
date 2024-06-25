#' Basic Education Evaluation System (Saeb) -2021
#'
#' The Basic Education Evaluation System (Saeb) is a series of large-scale 
#' external assessments conducted by Inep (National Institute for 
#' Educational Studies and Research) to diagnose the state of basic education 
#' in Brazil and identify factors that may affect student performance.
#' This dataset contains the 2021 results of a subset of 160 randomly chosen 
#' schools from the state of Rio de Janeiro.
#'
#' @format A data frame with 11386 student's observations including 5 variables:
#'  \describe{
#'   \item{school_id}{A unique identifier for each school in the dataset.}
#'   \item{public}{A binary variable indicating the type of school. It takes a value of `1` if the school is public and `0` 
#'   if the school is private.}
#'   \item{student_ses}{A numerical variable representing the socioeconomic status (SES) of the students.}
#'   \item{math_proficiency}{A numerical variable representing the math proficiency level of the students, 
#'   standardized with a mean of 0 and a standard deviation of 1.}
#'   \item{location}{A numerical variable indicating the geographical location of the school. 
#'   It takes a value of 1 for urban schools and 2 for rural schools.}
#'
#'   }
#' @source \url{https://www.gov.br/inep/pt-br/areas-de-atuacao/avaliacao-e-exames-educacionais/saeb/resultados}
"saeb"