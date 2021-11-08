#' Get a list of metrics in CJA
#'
#' Retrieves a list of metrics available in a specified dataview
#'
#' @param dataviewid *Required* The id of the dataview for which to retrieve metrics
#' @param expansion Comma-delimited list of additional segment metadata fields to include on response. See Details for all options available.
#' @param includeType Include additional segments not owned by user. Options include: "shared" "templates" "deleted" "internal"
#' @param locale Locale - Default: "en_US"
#' @param debug Used to help troubleshoot api call issues. Shows the call and result in the console
#' @param client_id Set in the global environment using "AW_CLIENT_ID" or pass directly here
#' @param client_secret Set in the global environment using "AW_CLIENT_SECRET" or pass directly here
#' @param org_id Set in the global environment using "AW_ORGANIZATION_ID" or pass directly here
#'
#' @details
#'
#' *Expansion* options can include the following:
#' "approved" "favorite" "tags" "usageSummary" "usageSummaryWithRelevancyScore" "description" "sourceFieldId" "segmentable" "required" "hideFromReporting" "hidden" "includeExcludeSetting" "fieldDefinition" "bucketingSetting" "noValueOptionsSetting" "defaultmetricsort" "persistenceSetting" "storageId" "tableName" "dataSetIds" "dataSetType" "type" "schemaPath" "hasData" "sourceFieldName" "schemaType" "sourceFieldType" "fromGlobalLookup" "multiValued" "precision"
#'
#' @return A data frame of metrics in a specified dataview
#' @examples
#' \dontrun{
#' cja_get_metrics()
#' }
#' @export
#' @import assertthat httr
#' @importFrom stringr str_remove
#'
cja_get_metrics <- function(dataviewid = NULL,
                            expansion = 'definition',
                            includeType = NULL,
                            locale = 'en_US',
                            debug = FALSE,
                            client_id = Sys.getenv("CJA_CLIENT_ID"),
                            client_secret = Sys.getenv("CJA_CLIENT_SECRET"),
                            org_id = Sys.getenv('CJA_ORGANIZATION_ID')) {
    if (is.null(dataviewid)){
        stop ("The dataviewid argument is required.")
    }
    assertthat::assert_that(
        assertthat::is.string(dataviewid),
        assertthat::is.string(client_id),
        assertthat::is.string(client_secret),
        assertthat::is.string(org_id)
    )

    #remove spaces from the list of expansion items
    if (!is.na(paste(expansion,collapse=","))) {
        expansion <- paste(expansion,collapse=",")
    }
    #remove spaces from the list of includeType items
    if (!is.na(paste(includeType,collapse=","))) {
        includeType <- paste(includeType,collapse=",")
    }

    vars <- tibble::tibble(expansion,
                           includeType,
                           locale)


    #Turn the list into a string to create the query
    prequery <- vars %>% purrr::discard(~all(is.na(.) | . ==""))
    #remove the extra parts of the string and replace it with the query parameter breaks
    query_param <-  paste(names(prequery), prequery, sep = '=', collapse = '&')

    req_path <- glue::glue('datagroups/data/{dataviewid}/metrics')

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
    res <- httr::content(req, as = "text",encoding = "UTF-8")

    df <- jsonlite::fromJSON(res)$content

    df %>% mutate(id = stringr::str_remove(id, 'metrics/'))
}
