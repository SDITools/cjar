#' Validate a filter in CJA
#'
#' Returns a filter validation for a filter contained in a json string object.
#'
#' @param filter_body The json string of the filter that is being validated (required)
#' @param debug This enables the api call information to show in the console for
#' help with debugging issues. default is FALSE
#'
#' @return A validation True or False response
#'
#' @import dplyr
#' @import assertthat
#' @importFrom glue glue
#' @export
#'
filter_val <- function(filter_body = NULL,
                       debug = FALSE){
  #validate arguments
  if (is.null(filter_body)) {
    stop('The arguments `filter_body` must be included.')
  }

  #defined parts of the post request
  req_path <- glue::glue('filters/validate')

  req <- cja_call_data(req_path = req_path,
                       body = filter_body,
                       debug = debug)

  if (jsonlite::fromJSON(req)$valid) {
    "The filter is valid."
  } else {
    purrr::map_df(jsonlite::fromJSON(req)$errors, jsonlite::fromJSON) %>%
      dplyr::relocate(3, 1)
  }
}
