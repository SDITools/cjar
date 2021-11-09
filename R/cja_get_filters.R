#' Get a paginated list of filters in CJA
#'
#' Retrieves a paginated list of filters, also known as `segments` in Adobe Analytics.
#'
#' @param expansion Comma-delimited list of additional segment metadata fields to include on response. See Details for all options available
#' @param includeType Include additional filters not owned by user. Default is "all". Options include: "shared" "templates" "deleted" "internal"
#' @param dataIds Filter list to only include filters tied to the specified data group ID list (comma-delimited)
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
#' @param client_id Set in environment args, or pass directly here
#' @param client_secret Set in environment args, or pass directly here
#' @param org_id Set in environment args or pass directly here
#'
#' @details
#'
#' *Expansion* options can include the following:
#' "compatibility", "definition", "internal", "modified", "isDeleted", "definitionLastModified", "createdDate", "recentRecordedAccess", "performanceScore", "owner", "dataId", "ownerFullName", "dataName", "sharesFullName", "approved", "favorite", "shares", "tags", "usageSummary", "usageSummaryWithRelevancyScore"
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
cja_get_filters <- function(expansion = 'definition',
                            includeType = 'all',
                            dataIds = NULL,
                            ownerId = NULL,
                            filterByIds = NULL,
                            toBeUsedInRsid = NULL,
                            locale = "en_US",
                            name = NULL,
                            filterByModifiedAfter = NULL,
                            cached = TRUE,
                            pagination = 'true',
                            limit = 10,
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
    #remove spaces from the list of expansion items
    if(!is.na(paste(expansion,collapse=","))) {
        expansion <- paste(expansion,collapse=",")
    }
    #remove spaces from the list of includeType items
    if(!is.na(paste(includeType,collapse=","))) {
        includeType <- paste(includeType,collapse=",")
    }
    #remove spaces from the list of dataIds items
    if(!is.na(paste(dataIds,collapse=","))) {
        dataIds <- paste(dataIds,collapse=",")
    }
    #remove spaces from the list of filterByIds items
    if(!is.na(paste(filterByIds,collapse=","))) {
        filterByIds <- paste(filterByIds,collapse=",")
    }
    #remove spaces from the list of filterByIds items
    if(!is.na(paste(filterByIds,collapse=","))) {
        filterByIds <- paste(filterByIds,collapse=",")
    }

    vars <- tibble::tibble(expansion,
                           includeType,
                           dataIds,
                           ownerId,
                           filterByIds,
                           toBeUsedInRsid,
                           locale,
                           name,
                           filterByModifiedAfter,
                           cached,
                           pagination,
                           limit,
                           page,
                           sortDirection,
                           sortProperty)


    #Turn the list into a string to create the query
    prequery <- vars %>% purrr::discard(~all(is.na(.) | . ==""))
    #remove the extra parts of the string and replace it with the query parameter breaks
    query_param <-  paste(names(prequery), prequery, sep = '=', collapse = '&')

    req_path <- 'filters'

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


    res <- httr::content(req)$content

    res1 <- tibble::as_tibble(do.call(rbind, res))

    res1 %>%
        mutate(across(.cols = everything(), as.character))
}
