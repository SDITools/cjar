#' Get a paginated list of filters in CJA
#'
#' Retrieves a paginated list of filters, also known as `segments` in Adobe Analytics.
#'
#' @param expansion Comma-delimited list of additional segment metadata fields to include on response. See Details for all options available
#' @param includeType Include additional filters not owned by user. Default is "all". Options include: "shared" "templates" "deleted" "internal"
#' @param dataviewIds Filter list to only include filters tied to the specified data group ID list (comma-delimited)
#' @param ownerId Filter list to only include filters owned by the specified imsUserId
#' @param filterByIds Filter list to only include filters in the specified list (comma-delimited list of IDs). This has filtered Ids from tags, approved, favorites and user specified Ids list.
#' @param toBeUsedInRsid The report suite where the segment is intended to be used. This report suite will be used to determine things like compatibility and permissions.
#' @param locale Locale - Default: "en_US"
#' @param name Filter list to only include filters that contains the Name. Can only be a string value.
#' @param filterByModifiedAfter Filter list to only include filters modified since this date. 'yyyy-mm-dd' format
#' @param cached Return cached results. TRUE by default.
#' @param pagination Return paginated results
#' @param limit Number of results per page
#' @param page Page number (base 0 - first page is "0")
#' @param sortDirection Sort direction ('ASC' or 'DESC'). 'ASC' is default.
#' @param sortProperty Property to sort by (name, modified_date, performanceScore, id is currently allowed). 'id' is default
#' @param debug Used to help troubleshoot api call issues. Shows the call and result in the console
#'
#' @details
#'
#' *Expansion* options can include the following:
#' "compatibility", "definition", "internal", "modified", "isDeleted",
#' "definitionLastModified", "createdDate", "recentRecordedAccess",
#' "performanceScore", "owner", "dataId", "ownerFullName", "dataName",
#' "sharesFullName", "approved", "favorite", "shares", "tags", "usageSummary",
#' "usageSummaryWithRelevancyScore"
#'
#' @return A data frame of company ids and company names
#' @examples
#' \dontrun{
#' cja_get_filters()
#' }
#' @export
#' @import assertthat httr
#' @importFrom purrr map_df
#'
cja_get_filters <- function(expansion = NULL,
                            includeType = 'all',
                            dataviewIds = NULL,
                            ownerId = NULL,
                            filterByIds = NULL,
                            toBeUsedInRsid = NULL,
                            locale = "en_US",
                            name = NULL,
                            filterByModifiedAfter = NULL,
                            cached = TRUE,
                            pagination = TRUE,
                            limit = 10,
                            page = 0,
                            sortDirection = 'ASC',
                            sortProperty = 'id',
                            debug = FALSE) {

  query_params <- list(expansion = expansion,
                       includeType = includeType,
                       dataIds = dataviewIds,
                       ownerId = ownerId,
                       filterByIds = filterByIds,
                       toBeUsedInRsid = toBeUsedInRsid,
                       locale = locale,
                       name = name,
                       filterByModifiedAfter = filterByModifiedAfter,
                       cached = cached,
                       pagination = pagination,
                       limit = limit,
                       page = page,
                       sortDirection = sortDirection,
                       sortProperty = sortProperty)

    req_path <- 'filters'

    urlstructure <- paste(req_path, format_URL_parameters(query_params), sep = "?")

    req <- cja_call_api(req_path = urlstructure,
                        body = NULL,
                        debug = debug)

    res <- httr::content(req, as= 'text', encoding = 'UTF-8')

    jsonlite::fromJSON(res)
}
