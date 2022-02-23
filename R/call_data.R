#' Gets the data from CJA API - Internal Function
#'
#' This gives a raw call to the API, but it is intended other functions to call this one
#'
#' @noRd
#'
#' @param req_path The endpoint for that particular report
#' @param debug Default `FALSE`. Set this to TRUE to see the information about the api calls as they happen.
#' @param body An R list that will be parsed to JSON
#' @param query_param The query url parameters to be sent with the api call. NULL is default
#' @param client_id Set in environment args, or pass directly here
#' @param client_secret Set in environment args, or pass directly here
#'
#' @examples
#'
#' \dontrun{
#'
#' cja_call_data("reports/ranked",
#'             body = list(..etc..))
#'
#' }
#' @import assertthat httr
#'
cja_call_data <- function(req_path,
                          body = NULL,
                          debug = FALSE,
                          query_param = NULL ){
    assert_that(
        is.string(req_path)
    )
    if(!is.null(query_param)) {
        request_url <- sprintf("https://cja.adobe.io/%s?%s",
                               req_path, query_param)
    } else {
        request_url <- sprintf("https://cja.adobe.io/%s",
                           req_path)
    }

    env_vars <- get_env_vars()
    token_config <- get_token_config(client_id = env_vars$client_id,
                                   client_secret = env_vars$client_secret)

    debug_call <- NULL

    if (debug) {
        debug_call <- httr::verbose(data_out = TRUE, data_in = TRUE, info = TRUE)
    }

    req <- httr::RETRY("POST",
                       url = request_url,
                       body = body,
                       encode = "json",
                       token_config,
                       debug_call,
                       httr::add_headers(
                           `x-api-key` = env_vars$client_id,
                           `x-gw-ims-org-id` = env_vars$org_id
                       ))

    stop_for_status(req)

    req_errors <- content(req)$columns$columnErrors[[1]]

    if(status_code(req) == 206  & length(req_errors) != 0) {
        stop(paste0('The error code is ', req_errors$errorCode, ' - ', req_errors$errorDescription))
    } else if(status_code(req) == 206) {
        stop(paste0('Please check the metrics your requested. A 206 error was returned.'))
    }
    httr::content(req, as = "text",encoding = "UTF-8")
}
