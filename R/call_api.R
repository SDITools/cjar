#' Gets the data from Adobe Analytics API v2
#'
#' This gives a raw call to the API, but it is intended other functions call this one
#'
#' @noRd
#'
#' @param req_path The endpoint for that particular report
#' @param body The body contained in the call
#' @param debug Default `FALSE`. Set this to TRUE to see the information about the api calls as they happen.
#' @param client_id Set in environment args, or pass directly here
#' @param client_secret Set in environment args, or pass directly here
#' @param use_oob Always set to TRUE. Needed for tests
#'
#' @examples
#'
#' \dontrun{
#'
#' cja_call_api("reports/ranked")
#'
#' }
#'
#' @import assertthat httr
cja_call_api <- function(req_path,
                         body = NULL,
                         debug = FALSE) {

    assertthat::assert_that(
        assertthat::is.string(req_path)
    )

    request_url <- sprintf("https://cja.adobe.io/%s",
                           req_path)

    env_vars <- get_env_vars()
    token_config <- get_token_config(client_id = env_vars$client_id,
                                     client_secret = env_vars$client_secret)

    debug_call <- NULL

    if (debug) {
        debug_call <- httr::verbose(data_out = TRUE, data_in = TRUE, info = TRUE)
    }

    req <- httr::RETRY("GET",
                       url = request_url,
                       encode = "json",
                       body = FALSE,
                       token_config,
                       debug_call,
                       httr::add_headers(
                           `x-api-key` = env_vars$client_id,
                           `x-gw-ims-org-id` = env_vars$org_id
                       ))

    httr::stop_for_status(req)
    req
}

