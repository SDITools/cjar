#' CJA Get My Information
#'
#' This function will quickly pull the list of company ids that you have access to.
#'
#' @param expansion The endpoint for that particular report
#' @param useCache cache the response for faster recall
#' @param debug Used to help troubleshoot api call issues. Shows the call and result in the console
#' @param client_id Set in environment args, or pass directly here
#' @param client_secret Set in environment args, or pass directly here
#' @param org_id The organization ID the data should be pulled from
#'
#' @return A list of the current user metadata
#' @examples
#' \dontrun{
#' cja_get_me()
#' }
#' @export
#' @import assertthat httr
cja_get_me <- function(expansion = 'admin',
                       useCache = TRUE,
                       debug = FALSE,
                       client_id = Sys.getenv("CJA_CLIENT_ID"),
                       client_secret = Sys.getenv("CJA_CLIENT_SECRET"),
                       org_id = Sys.getenv('CJA_ORGANIZATION_ID')) {

    assertthat::assert_that(
        assertthat::is.string(client_id),
        assertthat::is.string(client_secret)
    )

    #remove spaces from the list of expansion items
    if(!is.na(paste(expansion,collapse=","))) {
        expansion <- paste(expansion,collapse=",")
    }

    # Add query parameters to the api call for greater control
    vars <- tibble::tibble(expansion, useCache)
    #Turn the list into a string to create the query
    prequery <- vars %>% dplyr::select_if(~ !any(is.na(.)))
    #remove the extra parts of the string and replace it with the query parameter breaks
    query_param <-  paste(names(prequery), prequery, sep = '=', collapse = '&')

    req_path <- 'aresconfig/users/me'

    request_url <- sprintf("https://cja.adobe.io/%s?%s",
                           req_path, query_param)
    token_config <- get_token_config(client_id = client_id, client_secret = client_secret)

    #setting debug option
    debug_call <- NULL
    if (debug) {
        debug_call <- httr::verbose(data_out = TRUE, data_in = TRUE, info = TRUE)
    }

    req <- httr::RETRY("GET",
                       url = request_url,
                       encode = "json",
                       body = FALSE,
                       debug_call,
                       token_config,
                       httr::add_headers(
                           `x-api-key` = client_id,
                           `x-gw-ims-org-id` = org_id
                       ))

    httr::stop_for_status(req)

    res <- httr::content(req, as = "text",encoding = "UTF-8")

    return(res)
}
