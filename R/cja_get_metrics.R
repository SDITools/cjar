#' Get a list of metrics in CJA
#'
#' Retrieves a list of metrics available in a specified dataview
#'
#' @param dataviewId *Required* The id of the dataview for which to retrieve metrics
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
#' "approved" "favorite" "tags" "usageSummary" "usageSummaryWithRelevancyScore"
#' "description" "sourceFieldId" "segmentable" "required" "hideFromReporting"
#' "hidden" "includeExcludeSetting" "fieldDefinition" "bucketingSetting"
#' "noValueOptionsSetting" "defaultmetricsort" "persistenceSetting" "storageId"
#' "tableName" "dataSetIds" "dataSetType" "type" "schemaPath" "hasData"
#' "sourceFieldName" "schemaType" "sourceFieldType" "fromGlobalLookup"
#' "multiValued" "precision"
#'
#' @return A data frame of metrics in a specified dataview
#' @examples
#' \dontrun{
#' cja_get_metrics(dataviewId = "dv_5f4f1e2572ea0000003ce262")
#' }
#' @export
#' @import assertthat httr
#' @importFrom stringr str_remove
#'
cja_get_metrics <- function(dataviewId = NULL,
                            expansion = 'description',
                            includeType = NULL,
                            locale = 'en_US',
                            debug = FALSE,
                            client_id = Sys.getenv("CJA_CLIENT_ID"),
                            client_secret = Sys.getenv("CJA_CLIENT_SECRET"),
                            org_id = Sys.getenv('CJA_ORGANIZATION_ID')) {
    if (is.null(dataviewId)){
        stop ("The dataviewId argument is required.")
    }
    assertthat::assert_that(
        assertthat::is.string(dataviewId),
        assertthat::is.string(client_id),
        assertthat::is.string(client_secret),
        assertthat::is.string(org_id)
    )

    query_params <- list(expansion = expansion,
                         includeType = includeType,
                         locale = locale)

    req_path <- glue::glue('datagroups/data/{dataviewId}/metrics')

    urlstructure <- paste(req_path, format_URL_parameters(query_params), sep = "?")

    req <- cja_call_api(req_path = urlstructure,
                        body = NULL,
                        debug = debug,
                        client_id = client_id,
                        client_secret = client_secret,
                        org_id = org_id)

    res <- httr::content(req, as = "text",encoding = "UTF-8")

    df <- jsonlite::fromJSON(res)$content

    df %>% mutate(id = stringr::str_remove(id, 'metrics/'))
}
