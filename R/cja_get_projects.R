#' Get a paginated list of projects in CJA
#'
#' Retrieves a paginated list of projects, also known as `Workspace Projects`.
#'
#' @param includeType Include additional filters not owned by user. Default is "all". Options include: "all" (default) "shared"
#' @param expansion Comma-delimited list of additional segment metadata fields to include on response. See Details for all options available
#' @param locale Locale - Default: "en_US"
#' @param filterByIds Filter list to only include filters in the specified list (comma-delimited list of IDs). This has filtered Ids from tags, approved, favorites and user specified Ids list.
#' @param pagination Return paginated results
#' @param ownerId Filter list to only include filters owned by the specified imsUserId
#' @param limit Number of results per page
#' @param page Page number (base 0 - first page is "0")
#' @param debug Used to help troubleshoot api call issues. Shows the call and result in the console
#'
#' @details
#'
#' *expansion* options can include any of the following:
#' "shares" "tags" "accessLevel" "modified" "externalReferences" "definition"
#'
#' *includeType* options can include any of the following:
#' "all", "shared"
#'
#' @return A data frame of projects and corresponding metadata
#' @examples
#' \dontrun{
#' cja_get_projects()
#' }
#' @export
#' @import assertthat httr
#' @importFrom purrr map_df
#'
cja_get_projects <- function(includeType = 'all',
                             expansion = 'definition',
                             locale = "en_US",
                             filterByIds = NULL,
                             pagination = 'true',
                             ownerId = NULL,
                             limit = 10,
                             page = 0,
                             debug = FALSE) {

    query_params <- list(includeType = includeType,
                         expansion = expansion,
                         locale = locale,
                         filterByIds = filterByIds,
                         pagination = pagination,
                         ownerId = ownerId,
                         limit = limit,
                         page = page)

    req_path <- 'projects'

    urlstructure <- paste(req_path, format_URL_parameters(query_params), sep = "?")

    req <- cja_call_api(req_path = urlstructure,
                        body = NULL,
                        debug = debug)

    res <- httr::content(req, as= 'text', encoding = 'UTF-8')

    tibble::as_tibble(jsonlite::fromJSON(res)$content)
}
