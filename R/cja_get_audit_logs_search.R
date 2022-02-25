#' Get audit logs search
#'
#' This function will pull a list of audit logs.
#' @param body The json string with the search functions included
#' @param debug Set to TRUE if needed to help troubleshoot api call errors
#'
#' @return A data frame of audit logs and corresponding metadata
#' @examples
#' \dontrun{
#' cja_get_audit_logs_search(body = jsonrequest)
#' }
#' @export
#' @import assertthat httr dplyr
#'
cja_get_audit_logs_search <- function(body = NULL,
                                      debug = FALSE) {

    req_path = 'auditlogs/api/v1/auditlogs/search'

    urlstructure <- sprintf("https://cja.adobe.io/%s",
                           req_path)

    req <- cja_call_api(req_path = urlstructure,
                        body = body,
                        debug = debug)

    res <- httr::content(req, as = "text",encoding = "UTF-8")

    logs <- jsonlite::fromJSON(res)$content

    logs
}
