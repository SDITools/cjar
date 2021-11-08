#' CJA Get Data View IDs
#'
#' This function will pull a list of data views ids that you have access to. These are similar to report suites in Adobe Analytics.
#'
#' @param expansion Comma-delimited list of additional fields to include on response. Options include: "name" "description" "owner" "isDeleted" "parentDataGroupId" "segmentList" "currentTimezoneOffset" "timezoneDesignator" "modified" "createdDate" "organization" "curationEnabled" "recentRecordedAccess" "sessionDefinition" "externalData" "containerNames"
#' @param parentDataGroupId Filters data views by a single parentDataGroupId
#' @param externalIds Comma-delimited list of external ids to limit the response with
#' @param externalParentIds Comma-delimited list of external parent ids to limit the response with.
#' @param dataViewIds Comma-delimited list of data view ids to limit the response with.
#' @param includeType Include additional DataViews not owned by user.
#' @param cached return cached results. TRUE (default) or FALSE
#' @param limit number of results per page. 10 is default
#' @param page Page number (base 0 - first page is 0). 0 is default
#' @param sortDirection Sort direction ('ASC' (default) or DESC)
#' @param sortProperty property to sort by (only modifiedDate and id are currently allowed). 'id' is default
#' @param debug Used to help troubleshoot api call issues. Shows the call and result in the console
#' @param client_id Set in the global environment using "AW_CLIENT_ID" or pass directly here
#' @param client_secret Set in the global environment using "AW_CLIENT_SECRET" or pass directly here
#' @param org_id Set in the global environment using "AW_ORGANIZATION_ID" or pass directly here
#'
#' @return A data frame of dataview ids
#' @examples
#' \dontrun{
#' cja_get_dataviews()
#' }
#' @export
#' @importFrom magrittr %>%
#' @importFrom jsonlite fromJSON
#' @importFrom purrr discard
#' @import assertthat httr
#'
cja_get_dataviews <- function(expansion = c('name'),
                              parentDataGroupId = NULL,
                              externalIds = NULL,
                              externalParentIds = NULL,
                              dataViewIds = NULL,
                              includeType = NULL,
                              cached = TRUE,
                              limit = 1000,
                              page = 0,
                              sortDirection = 'ASC',
                              sortProperty = 'id',
                              debug = FALSE,
                              client_id = Sys.getenv("CJA_CLIENT_ID"),
                              client_secret = Sys.getenv("CJA_CLIENT_SECRET"),
                              org_id = Sys.getenv('CJA_ORGANIZATION_ID')) {
    assertthat::assert_that(
        assertthat::is.string(client_id),
        assertthat::is.string(client_secret),
        assertthat::is.string(org_id)
    )
    #remove spaces from the list of expansion tags
    if(!is.na(paste(expansion,collapse=","))) {
        expansion <- paste(expansion,collapse=",")
    }

    vars <- tibble::tibble(expansion,
                           parentDataGroupId,
                           externalIds,
                           externalParentIds,
                           dataViewIds,
                           includeType,
                           cached,
                           limit,
                           page,
                           sortDirection,
                           sortProperty)
    #Turn the list into a string to create the query
    prequery <- vars %>% purrr::discard(~all(is.na(.) | . ==""))
    #remove the extra parts of the string and replace it with the query parameter breaks
    query_param <-  paste(names(prequery), prequery, sep = '=', collapse = '&')
    req_path <- 'datagroups/dataviews'
    request_url <- sprintf("https://cja.adobe.io/%s?%s",
                           req_path, query_param)
    token_config <- get_token_config(client_id = client_id, client_secret = client_secret)

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
                           `x-api-key` = client_id,
                           `x-gw-ims-org-id` = org_id
                       ))

    httr::stop_for_status(req)

    res <- httr::content(req, as = "text",encoding = "UTF-8")

    df <- jsonlite::fromJSON(res)$content

    return(df)
}
