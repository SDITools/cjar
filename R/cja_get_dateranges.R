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
#' @param client_id Set in environment args, or pass directly here
#' @param client_secret Set in environment args, or pass directly here
#' @param org_id Set in environment args or pass directly here
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
#'
cja_get_dateranges <- function(locale = "en_US",
                               filterByIds = NULL,
                               limit = 10,
                               page = 0,
                               expansion = 'definition',
                               includeType = 'all',
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

    vars <- tibble::tibble(locale,
                           filterByIds,
                           limit,
                           page,
                           expansion,
                           includeType)


    #Turn the list into a string to create the query
    prequery <- vars %>% purrr::discard(~all(is.na(.) | . ==""))
    #remove the extra parts of the string and replace it with the query parameter breaks
    query_param <-  paste(names(prequery), prequery, sep = '=', collapse = '&')

    req_path <- 'dateranges'

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
