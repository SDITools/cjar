#' `cjar` Package
#'
#' Connect to the 'CJA' API
#' <https://www.adobe.io/cja-apis/docs> which powers 'CJA
#' Workspace'. The package was developed with the analyst in mind, and it will
#' continue to be developed with the guiding principles of iterative,
#' repeatable, timely analysis.
#'
#'
"_PACKAGE"

# Environment for caching tokens for the session
.cjar <- new.env(parent = emptyenv())
