#' Get list of annotations
#'
#' Retrieve all annotations or filter to return only one
#'
#' @param id Filter the results to one specific annotation by the annotation id. If not used, a list of annotations will be returned limited by the 'limit' and 'page' arguments.
#' @param expansion Obtain additional information around an annotation. You can include multiple expansions using the 'c()' function. See details for options.
#' @param includeType Include additional segments not owned by the user. Available values are `all` (default) and
#' `shared`. The `all` option takes precedence over "shared".
#' @param locale A query string that returns strings localized by Adobe into the desired language. Localization does not apply to user-defined fields, such as annotation names.
#' See details for options.
#' @param filterByModifiedAfter An ISO 8601 date that returns only annotations that were modified after the desired date. example datetime format: 'YYYY-MM-DDTHH:MM:SSZ'
#' @param filterByDateRange Two ISO 8601 dates separated by a forward slash (/) that returns only annotations that fully reside within the desired date range. example format: 'MM:SSZ/YYYY-MM-DDTHH:MM:SSZ'
#' @param limit  An integer that represents the number of results per page. Default is 10
#' @param page An integer that represents which page to return results. The first page is 0. The API supports up to 1000 pages
#' @param debug Include the output and input of the api call in the console for debugging. Default is FALSE
#'
#' @return A data frame of segments and their meta data.
#'
#' @details
#' - Expansion options include the following:
#'   - **name:** The name of the annotation.
#'   - **description** The annotation's description.
#'   - **dateRange** The date range of the annotation.
#'   - **color:** An enum representing the annotation's color. Supported values include STANDARD1 through STANDARD9. These correspond with 'blue', 'purple', 'green', 'orange', 'red', 'light green', 'pink', 'dark green', and 'yellow', in that order.
#'   - **applyToAllReports:** A boolean that determines if the annotation applies to all report suites.
#'   - **scope:** An object including the metrics and filters that the annotation uses.
#'   - **createdDate:** The date that the annotation was created.
#'   - **modifiedDate:** The date that the annotation was last modified.
#'   - **modifiedById:** The ID of the user who last modified the annotation.
#'   - **tags:** The tags applied to the annotation.
#'   - **shares:** The shares applied to the annotation.
#'   - **approved:** A boolean that determines if the annotation is approved by an admin.
#'   - **favorite:** A boolean that determines if the user has this annotation favorited (starred).
#'   - **usageSummary:** An object that shows where this annotation is used.
#'   - **owner:** An object showing the ID, name, and login of the user that created the annotation.
#'   - **imsOrgId:** The IMS org of the annotation.
#'   - **dataName:** The Data View name.
#'   - **dataId:** The Data View ID.
#'
#' - Locale options include the following:
#'   - **en_US:** English
#'   - **fr_FR:** French
#'   - **ja_JP:** Japanese
#'   - **de_DE:** German
#'   - **es_ES:** Spanish
#'   - **ko_KR:** Korean
#'   - **pt_PR:** Brazilian Portuguese
#'   - **zh_CN:** Simplified Chinese
#'   - **zh_TW:** Traditional Chinese
#'
#' @export
#'
#' @importFrom purrr map_df
#' @importFrom tidyr nest
#'
cja_get_annotations <- function(id = NULL,
                               expansion = NULL,
                               includeType = 'all',
                               locale = 'en_US',
                               filterByModifiedAfter = NULL,
                               filterByDateRange = NULL,
                               limit = 10,
                               page = 0,
                               debug = FALSE)
{
  query_params <- list(
    expansion = expansion,
    includeType = includeType,
    locale = locale,
    filterByModifiedAfter = filterByModifiedAfter,
    filterByDateRange = filterByDateRange,
    limit = limit,
    page = page
  )
  if(!is.null(id)) {
    urlstructure <- paste(paste0('annotations/', id), format_URL_parameters(query_params), sep = "?")
  } else {
    urlstructure <- paste('annotations', format_URL_parameters(query_params), sep = "?")
  }
  res <- cja_call_api(req_path = urlstructure, debug = debug)

  items <- jsonlite::parse_json(res)$content

  if (length(names(items[[1]])[purrr::map(items[[1]], class) == 'list']) >= 1) {
    ##possibly want to expand this function for other element pulls which have list values
    tf_func <- function(x) {
      nm <- names(x)[purrr::map(x, class) == 'list']
      tibble::as_tibble(x[!names(x) %in% nm]) %>%
        dplyr::mutate(lists = tibble::as_tibble(rbind(x[nm])))
    }
    purrr::map_df(items, tf_func)
  } else {
    map_df(items, tibble::as_tibble)
  }

}
