#' Create a project in CJA
#'
#' Creates a project a configuration JSON string.
#'
#' @param name The name of the project
#' @param description The description of the project
#' @param dataviewId The dataview id the project will be created under
#' @param type The type of project. Either 'project' (default) or 'mobileScorecard'
#' @param definition The json string definition
#' @param expansion Comma-delimited list of additional segment metadata fields to include on response. See Details for all options available
#' @param locale Locale - Default: "en_US"
#' @param debug Used to help troubleshoot api call issues. Shows the call and result in the console
#'
#' @details
#'
#' *expansion* options can include any of the following:
#' "shares" "tags" "accessLevel" "modified" "externalReferences" "definition"
#'
#' @return A data frame of projects and corresponding metadata
#' @examples
#' \dontrun{
#' cja_get_project_create(name = "Project Name", descriiption = "The description of the project",
#' dataviewId = '6047e0a3de6aaaaac7c3accb', type = 'project', defintion = jsonObject)
#' }
#'
#' @import assertthat httr
#' @importFrom purrr map_df
#' @noRd
#'
project_create <- function(name = 'name',
                           description = NULL,
                           dataviewId = NULL,
                           type = 'project',
                           definition = NULL,
                           expansion = 'definition',
                           locale = "en_US",
                           debug = FALSE) {
    assertthat::assert_that(assertthat::not_empty(name), msg = "`name` must be supplied")
    assertthat::assert_that(assertthat::not_empty(description), msg = glue::glue("`description` must be supplied"))
    assertthat::assert_that(assertthat::not_empty(dataviewId), msg = glue::glue("`dataviewId` must be supplied"))
    assertthat::assert_that(assertthat::not_empty(definition), msg = glue::glue("`definition` must be supplied"))

    query_params <- list(expansion = expansion,
                         locale = locale)

    req_path <- glue::glue('projects')

    urlstructure <- paste(req_path, format_URL_parameters(query_params), sep = "?")

    body_object <- list(name = name,
                        description = description,
                        dataId = dataviewId,
                        type = type,
                        definition = definition)

    req <- cja_post_api(req_path = urlstructure,
                        body = body_object,
                        debug = debug)

    res <- httr::content(req, as= 'text', encoding = 'UTF-8')

    jsonlite::fromJSON(res)
}
