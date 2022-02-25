#' Get audit logs
#'
#' This function will pull a list of audit logs defined by the different defined parameters.
#'
#' @param startDate Date is not required, but if you filter by date, both start & end date must be set.
#' @param endDate Date is not required, but if you filter by date, both start & end date must be set.
#' @param action The action you want to filter by.See details section for options
#' @param component The type of component you want to filter by. See details section for options
#' @param componentId The ID of the component.
#' @param userType The type of user.
#' @param userId The ID of the user.
#' @param userEmail The email address of the user.
#' @param description The log description you want to filter by.
#' @param pageSize Number of results per page. If left null, the default size will be set to 100.
#' @param pageNumber Page number (base 0 - first page is "0")
#' @param debug Used to help troubleshoot api call issues. Shows the call and result in the console
#'
#' @details
#'
#' *startDate/endDate* format
#'
#' *Action* available values are: 'CREATE', 'EDIT', 'DELETE', 'LOGIN_FAILED',
#' 'LOGIN_SUCCESSFUL', 'API_REQUEST', 'LOGOUT', 'APPROVE', 'UNAPPROVE', 'SHARE', 'UNSHARE',
#' 'TRANSFER', 'ORG_CHANGE'
#'
#' *Component* available values are: 'ANNOTATION', 'CALCULATED_METRIC', 'CONNECTION',
#' 'DATA_GROUP', 'DATA_VIEW', 'DATE_RANGE', 'FILTER', 'MOBILE', 'PROJECT',
#' 'REPORT', 'SCHEDULED_PROJECT', 'USER', 'USER_GROUP', 'IMS_ORG',
#' 'FEATURE_ACCESS'
#'
#' @return A data frame of audit logs and corresponding metadata
#' @examples
#' \dontrun{
#' cja_get_audit_logs()
#' }
#' @export
#' @import assertthat httr dplyr
#'
cja_get_audit_logs <- function(startDate = NULL,
                               endDate = NULL,
                               action = NULL,
                               component = NULL,
                               componentId = NULL,
                               userType = NULL,
                               userId = NULL,
                               userEmail = NULL,
                               description = NULL,
                               pageSize = 100,
                               pageNumber = 0,
                               debug = FALSE) {
  if (pageSize > 1000) {
    stop("The argument `pageSize` can not be more than 1000. Use `pageNumber` to get the next set of results if more than 1000 results are needed.")
  }

  #modify the startDate and endDate
  if (!is.null(startDate) & !is.null(endDate) & !grepl('t|T', startDate)) {
    date_time <- make_startDate_endDate(startDate, endDate)
    startDate <- date_time[[1]]
    endDate <- date_time[[2]]
  }
  query_params <- list(startDate = startDate,
                       endDate = endDate,
                       action = action,
                       component = component,
                       componentId = componentId,
                       userType = userType,
                       userId = userId,
                       userEmail = userEmail,
                       description = description,
                       pageSize = pageSize,
                       pageNumber = pageNumber)

  req_path = 'auditlogs/api/v1/auditlogs'

  urlstructure <- paste(req_path, format_URL_parameters(query_params), sep = "?")

  req <- cja_call_api(req_path = urlstructure,
                      body = NULL,
                      debug = debug)

  res <- httr::content(req, as = "text",encoding = "UTF-8")

  logs <- jsonlite::fromJSON(res)$content

  logs
}
