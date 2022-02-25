#' Get data view ids
#'
#' This function will pull a list of data views ids that you have access to. These are similar to report suites in Adobe Analytics.
#'
#' @param expansion Comma-delimited list of additional fields to include on response. Options include: "name" "description" "owner" "isDeleted" "parentDataGroupId" "segmentList" "currentTimezoneOffset" "timezoneDesignator" "modified" "createdDate" "organization" "curationEnabled" "recentRecordedAccess" "sessionDefinition" "externalData" "containerNames"
#' @param parentDataGroupId Filters data views by a single parentDataGroupId
#' @param externalIds Comma-delimited list of external ids to limit the response with
#' @param externalParentIds Comma-delimited list of external parent ids to limit the response with.
#' @param dataviewIds Comma-delimited list of data view ids to limit the response with.
#' @param includeType Include additional DataViews not owned by user. Options: "deleted"
#' @param cached return cached results. TRUE (default) or FALSE
#' @param limit number of results per page. 10 is default
#' @param page Page number (base 0 - first page is 0). 0 is default
#' @param sortDirection Sort direction ('ASC' (default) or DESC)
#' @param sortProperty property to sort by (only modifiedDate and id are currently allowed). 'id' is default
#' @param debug Used to help troubleshoot api call issues. Shows the call and result in the console
#'
#' @details
#' **Expansion** available items: "name" "description" "owner" "isDeleted"
#' "parentDataGroupId" "segmentList" "currentTimezoneOffset" "timezoneDesignator"
#' "modified" "createdDate" "organization" "curationEnabled" "recentRecordedAccess"
#' "sessionDefinition" "externalData" "containerNames"
#'
#' @return A data frame of dataview ids and their corresponding metadata
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
                              dataviewIds = NULL,
                              includeType = NULL,
                              cached = TRUE,
                              limit = 1000,
                              page = 0,
                              sortDirection = 'ASC',
                              sortProperty = 'id',
                              debug = FALSE) {
    #remove spaces from the list of expansion tags
    if(!is.na(paste(expansion,collapse=","))) {
        expansion <- paste(expansion,collapse=",")
    }

    query_params <- list(expansion = expansion,
                         parentDataGroupId = parentDataGroupId,
                         externalIds = externalIds,
                         externalParentIds = externalParentIds,
                         dataViewIds = dataviewIds,
                         includeType = includeType,
                         cached = cached,
                         limit = limit,
                         page = page,
                         sortDirection = sortDirection,
                         sortProperty = sortProperty)

    req_path <- 'datagroups/dataviews'

    urlstructure <- paste(req_path, format_URL_parameters(query_params), sep = "?")

    req <- cja_call_api(req_path = urlstructure,
                        body = NULL,
                        debug = debug)

    res <- httr::content(req, as = "text",encoding = "UTF-8")

    df <- jsonlite::fromJSON(res)$content

    return(df)
}
