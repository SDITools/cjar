#' Get a filter in CJA
#'
#' Retrieves a specific filter, also known as a `segment` in Adobe Analytics.
#'
#' @param id The filter id to retrieve
#' @param toBeUsedInRsid The data view where the filter is intended to be used.
#' This data view will be used to determine things like compatibility and permissions.
#' @param locale Locale - Default: "en_US"
#' @param expansion Comma-delimited list of additional filter metadata fields to
#' include on response. See Details for all options available
#' @param debug Used to help troubleshoot api call issues. Shows the call and result in the console
#'
#' @details
#'
#' *Expansion* options can include the following:
#' "compatibility", "definition", "internal", "modified", "isDeleted", "definitionLastModified",
#' "createdDate", "recentRecordedAccess", "performanceScore", "owner", "dataId",
#' "ownerFullName", "dataName", "sharesFullName", "approved", "favorite", "shares",
#' "tags", "usageSummary", "usageSummaryWithRelevancyScore"
#'
#' @return A filter list
#' @examples
#' \dontrun{
#' cja_get_filter()
#' }
#' @export
#' @import assertthat httr
#' @importFrom purrr map_df
#'
cja_get_filter <- function(id = NULL,
                           toBeUsedInRsid = NULL,
                           locale = "en_US",
                           expansion = 'definition',
                           debug = FALSE) {

  assertthat::assert_that(assertthat::not_empty(id),
                          msg = "The `id` argument must be supplied")

    query_params <- list(toBeUsedInRsid = toBeUsedInRsid,
                         locale = locale,
                         expansion = expansion)

    req_path <- glue::glue('filters/{id}')

    urlstructure <- paste(req_path, format_URL_parameters(query_params), sep = "?")

    req <- cja_call_api(req_path = urlstructure,
                        body = NULL,
                        debug = debug)

    httr::content(req)

}
