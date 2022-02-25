#' Verbs available to be used in filter rules.
#'
#' A dataset containing the list of available verbs which can be used in filters.
#'
#' @format A data frame with 34 rows and 5 variables:
#' \describe{
#'   \item{type}{one of number, string, or exists}
#'   \item{class}{gives the context of the type of value is expected, either
#'   string, list, glob, number, or exists}
#'   \item{verb}{the actual verb id to be used in the segment defition}
#'   \item{description}{a simple description of the verb}
#'   \item{arg}{specifies what argument to use when building the segment verb function}
#'   ...
#' }
#' @source \url{https://experienceleague.adobe.com/docs/analytics-platform/using/cja-components/cja-filters/operators.html?lang=en}
"filter_verbs"

