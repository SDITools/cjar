#' Get a paginated list of dateranges in CJA
#'
#' This function allows users to pull a list of stored date ranges so that they can be reused in an analysis.
#'
#' @param locale Locale - Default: "en_US"
#' @param filterByIds Filter list to only include date ranges in the specified list (comma-delimited list of IDs). This has filtered Ids from tags, approved, favorites and user specified Ids list.
#' @param limit Number of results per page. default is 10
#' @param page Page number (base 0 - first page is "0")
#' @param expansion Comma-delimited list of additional date range metadata fields to include on response.
#' @param includeType Include additional filters not owned by user. Default is "all". Options include: "all" (default), "shared", "templates"
#' @param debug Used to help troubleshoot api call issues. Shows the call and result in the console
#'
#' @details
#'
#' *expansion* options can include any of the following:
#' "definition" "modified" "ownerFullName" "sharesFullName" "shares" "tags"
#'
#' *includeType* options can include any of the following:
#' "all", "shared", "templates"
#'
#' @return A data frame of dateranges and their corresponding metadata
#' @examples
#' \dontrun{
#' cja_get_dateranges()
#' }
#' @export
#' @import assertthat httr
#' @importFrom purrr map_df
#' @importFrom tibble as_tibble
#'
cja_get_dateranges <- function(locale = "en_US",
                               filterByIds = NULL,
                               limit = 10,
                               page = 0,
                               expansion = 'definition',
                               includeType = 'all',
                               debug = FALSE) {

    query_params <- list(locale = locale,
                         filterByIds = filterByIds,
                         limit = limit,
                         page = page,
                         expansion = expansion,
                         includeType = includeType)

    req_path <- 'dateranges'

    urlstructure <- paste(req_path, format_URL_parameters(query_params), sep = "?")

    req <- cja_call_api(req_path = urlstructure,
                        body = NULL,
                        debug = debug)

    res <- httr::content(req, as= 'text', encoding = 'UTF-8')

    tibble::as_tibble(jsonlite::fromJSON(res)$content)
}
