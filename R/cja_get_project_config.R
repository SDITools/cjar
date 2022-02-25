#' Get a project configuration in CJA
#'
#' Retrieves a project configuration JSON string.
#'
#' @param id (Required) The Project id for which to retrieve information
#' @param expansion Comma-delimited list of additional segment metadata fields to include on response. See Details for all options available
#' @param locale Locale - Default: "en_US"
#' @param debug Used to help troubleshoot api call issues. Shows the call and result in the console
#'
#' @details
#'
#' *expansion* options can include any of the following:
#' "shares" "tags" "accessLevel" "modified" "externalReferences" "definition"
#'
#' @return A project configuration list
#' @examples
#' \dontrun{
#' cja_get_project_config(id = '6047e0a3de6aaaaac7c3accb')
#' }
#' @export
#' @import assertthat httr
#' @importFrom purrr map_df
#'
cja_get_project_config <- function(id = NULL,
                                   expansion = 'definition',
                                   locale = "en_US",
                                   debug = FALSE) {
  assertthat::assert_that(
    assertthat::is.string(id)
  )
  query_params <- list(expansion = expansion,
                       locale = locale)

  req_path <- glue::glue('projects/{id}')

  urlstructure <- paste(req_path, format_URL_parameters(query_params), sep = "?")

  req <- cja_call_api(req_path = urlstructure,
                      body = NULL,
                      debug = debug)

  res <- httr::content(req, as= 'text', encoding = 'UTF-8')

  jsonlite::fromJSON(res)
}
