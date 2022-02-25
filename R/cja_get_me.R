#' Get my information
#'
#' This function will quickly pull the list of company ids that you have access to
#'
#' @param expansion Comma-delimited list of additional metadata fields to include in the response. Options are 'admin'
#' @param debug Used to help troubleshoot api call issues. Shows the call and result in the console
#'
#' @return A list of the current user metadata
#' @examples
#' \dontrun{
#' cja_get_me()
#' }
#' @export
#' @import assertthat httr
#' @importFrom tibble as_tibble
#'
cja_get_me <- function(expansion = NULL,
                       debug = FALSE) {

    # Add query parameters to the api call for greater control
    query_params <- list(expansion = expansion)

    req_path <- 'configuration/users/me'

    urlstructure <- paste(req_path, format_URL_parameters(query_params), sep = "?")

    req <- cja_call_api(req_path = urlstructure,
                        body = NULL,
                        debug = debug)

    res <- httr::content(req, as= 'text', encoding = 'UTF-8')

    tibble::as_tibble(jsonlite::fromJSON(res))
}
