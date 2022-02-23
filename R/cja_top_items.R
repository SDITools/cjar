#' Get a list of dimensions in CJA
#'
#' Retrieves a list of dimensions available in a specified dataview
#'
#' @param dataId Data Group or Data View to run the report against. Required
#' @param dimension Dimension to run the report against. Example: "page" Required
#' @param locale Locale Default: "en_US"
#' @param dateRange Format: YYYY-MM-DD/YYYY-MM-DD
#' @param search_clause General search string; wrap with single quotes. Example: 'PageABC'
#' @param startDate Format: YYYY-MM-DD
#' @param endDate Format: YYYY-MM-DD
#' @param searchAnd Search terms that will be AND-ed together. Space delimited.
#' @param searchOr Search terms that will be OR-ed together. Space delimited. See Details
#' @param searchNot Search terms that will be treated as NOT including. Space delimited. See Details
#' @param searchPhrase A full search phrase that will be searched for. See Details
#' @param includeOberonXml Controls if Oberon XML should be returned in the response - DEBUG ONLY. Default: false
#' @param lookupNoneValues Controls None values to be included. Default: TRUE
#' @param limit Number of results per page. Default: 10
#' @param page Page number (base 0 - first page is "0"). Default: 0
#' @param debug Use this to see the api calls in the console when trying to debug
#'
#' @details
#' **DateRange
#' Get the top X items (based on paging restriction) for the specified dimension and dataId. Defaults to last 90 days.
#' **Search Clause examples:** contains test: 'test'
#' contains test or test1: 'test' OR 'test1'
#' contains test and test1: 'test' AND 'test1'
#' contains test and not (test1 or test2): 'test' AND NOT ('test1' OR 'test2')
#' does not contain test: NOT 'test'
#'
#' @return A data frame of dimensions in a specified dataview
#' @examples
#' \dontrun{
#' cja_get_dimensions(dataviewId = "dv_5f4f1e2572ea0000003ce262")
#' }
#' @export
#' @import assertthat httr
#' @importFrom stringr str_remove
#'
cja_top_items <- function(dataId = NULL,
                          dimension = 'page',
                          locale = 'en_US',
                          dateRange = NULL,
                          search_clause = NULL,
                          startDate = NULL,
                          endDate = NULL,
                          searchAnd = NULL,
                          searchOr = NULL,
                          searchNot = NULL,
                          searchPhrase = NULL,
                          includeOberonXml = NULL,
                          lookupNoneValues = TRUE,
                          limit = 10,
                          page = 0,
                          debug = FALSE) {
    if(is.null(dataId)){
        stop("The dataId argument is required.")
    }
    assertthat::assert_that(
        assertthat::is.string(dataId)
    )
    dimension <- glue::glue("variables/{dimension}")

    query_params <- list(dataId = dataId,
                         dimension = dimension,
                         locale = locale,
                         dateRange = dateRange,
                         `search-clause` = search_clause,
                         startDate = startDate,
                         endDate = endDate,
                         searchAnd = searchAnd,
                         searchOr = searchOr,
                         searchNot = searchNot,
                         searchPhrase = searchPhrase,
                         includeOberonXml = includeOberonXml,
                         lookupNoneValues = lookupNoneValues,
                         limit = limit,
                         page = page)

    req_path <- glue::glue('reports/topItems')

    urlstructure <- paste(req_path, format_URL_parameters(query_params), sep = "?")

    req <- cja_call_api(req_path = urlstructure,
                        body = NULL,
                        debug = debug)

    res <- httr::content(req, as = "text",encoding = "UTF-8")

    jsonlite::fromJSON(res)$rows

}
