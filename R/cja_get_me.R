#' CJA Get My Information
#'
#' This function will quickly pull the list of company ids that you have access to.
#'
#' @param expansion The endpoint for that particular report
#' @param useCache cache the response for faster recall
#' @param debug Used to help troubleshoot api call issues. Shows the call and result in the console
#' @param client_id Set in environment args, or pass directly here
#' @param client_secret Set in environment args, or pass directly here
#' @param org_id The organization ID the data should be pulled from
#'
#' @return A list of the current user metadata
#' @examples
#' \dontrun{
#' cja_get_me()
#' }
#' @export
#' @import assertthat httr
#' @importFrom tibble as_tibble
#'
cja_get_me <- function(expansion = NULL,
                       useCache = TRUE,
                       debug = FALSE,
                       client_id = Sys.getenv("CJA_CLIENT_ID"),
                       client_secret = Sys.getenv("CJA_CLIENT_SECRET"),
                       org_id = Sys.getenv('CJA_ORGANIZATION_ID')) {

    assertthat::assert_that(
        assertthat::is.string(client_id),
        assertthat::is.string(client_secret),
        assertthat::is.string(org_id)

    )

    # Add query parameters to the api call for greater control
    query_params <- list(expansion = expansion,
                         useCache = useCache)

    req_path <- 'aresconfig/users/me'

    urlstructure <- paste(req_path, format_URL_parameters(query_params), sep = "?")

    req <- cja_call_api(req_path = urlstructure,
                        body = NULL,
                        debug = debug,
                        client_id = client_id,
                        client_secret = client_secret,
                        org_id = org_id)

    res <- httr::content(req, as= 'text', encoding = 'UTF-8')

    tibble::as_tibble(jsonlite::fromJSON(res))
}
