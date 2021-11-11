#' CJA Get Audit Logs Search
#'
#' This function will pull a list of audit logs.
#'
#' @param client_id Set in environment args, or pass directly in the function
#' @param client_secret Set in environment args, or pass directly in the function
#' @param org_id Set in environment args or pass directly in the function
#' @param debug Set to TRUE if needed to help troubleshoot api call errors
#'
#' @return A data frame of audit logs and corresponding metadata
#' @examples
#' \dontrun{
#' get_me()
#' }
#' @export
#' @import assertthat httr dplyr
#'
cja_get_audit_logs_search <- function(client_id = Sys.getenv("CJA_CLIENT_ID"),
                                      client_secret = Sys.getenv("CJA_CLIENT_SECRET"),
                                      org_id = Sys.getenv('CJA_ORGANIZATION_ID'),
                                      debug = FALSE) {
    assertthat::assert_that(
        assertthat::is.string(client_id),
        assertthat::is.string(client_secret),
        assertthat::is.string(org_id)
    )

    req_path = 'auditlogs/api/v1/auditlogs/search'

    request_url <- sprintf("https://cja.adobe.io/%s",
                           req_path)

    debug_call <- NULL

    if (debug) {
        debug_call <- httr::verbose(data_out = TRUE, data_in = TRUE, info = TRUE)
    }

    token_config <- get_token_config(client_id = client_id, client_secret = client_secret)

    req <- httr::RETRY("POST",
                       url = request_url,
                       encode = "json",
                       token_config,
                       debug_call,
                       httr::add_headers(
                           `x-api-key` = client_id,
                           `x-gw-ims-org-id` = org_id
                       ))

    httr::stop_for_status(req)

    res <- httr::content(req, as = "text",encoding = "UTF-8")

    logs <- jsonlite::fromJSON(res)$content

    logs
}
