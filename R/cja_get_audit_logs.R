#' CJA Get Audit Logs
#'
#' This function will pull a list of company ids that you have access to.
#'
#' @param client_id Set in environment args, or pass directly in the function
#' @param client_secret Set in environment args, or pass directly in the function
#' @param org_id Set in environment args or pass directly in the function
#'
#' @return A data frame of company ids and company names
#' @examples
#' \dontrun{
#' get_me()
#' }
#' @export
#' @import assertthat httr dplyr
#'
cja_get_audit_logs <- function(client_id = Sys.getenv("CJA_CLIENT_ID"),
                               client_secret = Sys.getenv("CJA_CLIENT_SECRET"),
                               org_id = Sys.getenv('CJA_ORGANIZATION_ID')) {
    assertthat::assert_that(
        assertthat::is.string(client_id),
        assertthat::is.string(client_secret),
        assertthat::is.string(org_id)
    )
    req_path = 'auditlogs/api/v1/auditlogs'

    request_url <- sprintf("https://cja.adobe.io/%s",
                           req_path)

    token_config <- get_token_config(client_id = client_id, client_secret = client_secret)

    req <- httr::RETRY("GET",
                       url = request_url,
                       encode = "json",
                       body = FALSE,
                       token_config,
                       httr::add_headers(
                           `x-api-key` = client_id,
                           `x-gw-ims-org-id` = org_id
                       ))

    httr::stop_for_status(req)

    res <- httr::content(req, as = "text",encoding = "UTF-8")

    logs <- jsonlite::fromJSON(res)

    logs
}
