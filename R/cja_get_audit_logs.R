#' CJA Get Audit Logs
#'
#' This function will pull a list of audit logs defined by the different defined parameters.
#'
#' @param startDate Date is not required, but if you filter by date, both start & end date must be set.
#' @param endDate Date is not required, but if you filter by date, both start & end date must be set.
#' @param action The action you want to filter by.
#' @param component The type of component you want to filter by.
#' @param componentId The ID of the component.
#' @param userType The type of user.
#' @param userId The ID of the user.
#' @param userEmail The email address of the user.
#' @param description The log description you want to filter by.
#' @param pageSize Number of results per page. If left null, the default size will be set to 100.
#' @param pageNumber Page number (base 0 - first page is "0")
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
cja_get_audit_logs <- function(startDate = NA,
                               endDate = NA,
                               action = NA,
                               component = NA,
                               componentId = NA,
                               userType = NA,
                               userId = NA,
                               userEmail = NA,
                               description = NA,
                               pageSize = 100,
                               pageNumber = 0,
                               client_id = Sys.getenv("CJA_CLIENT_ID"),
                               client_secret = Sys.getenv("CJA_CLIENT_SECRET"),
                               org_id = Sys.getenv('CJA_ORGANIZATION_ID')) {
    assertthat::assert_that(
        assertthat::is.string(client_id),
        assertthat::is.string(client_secret),
        assertthat::is.string(org_id)
    )
    if(pageSize > 1000){
        stop("The argument `pageSize` can not be more than 1,000. Use `pageNumber` to get the next set of results if more than 1,000 results are needed.")
    }
    vars <- tibble::tibble(startDate,
                           endDate,
                           action,
                           component,
                           componentId,
                           userType,
                           userId,
                           userEmail,
                           description,
                           pageSize,
                           pageNumber)


    #Turn the list into a string to create the query
    prequery <- vars %>% purrr::discard(~all(is.na(.) | . ==""))
    #remove the extra parts of the string and replace it with the query parameter breaks
    query_param <-  paste(names(prequery), prequery, sep = '=', collapse = '&')

    req_path = 'auditlogs/api/v1/auditlogs'

    request_url <- sprintf("https://cja.adobe.io/%s?%s",
                           req_path, query_param)

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

    logs <- jsonlite::fromJSON(res)$content

    logs
}
