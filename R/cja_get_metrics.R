#' Get a list of metrics in CJA
#'
#' Retrieves a list of metrics available in a specified dataview
#'
#' @param dataviewId *Required* The id of the dataview for which to retrieve metrics. If an environment variable called `CJA_DATAVIEW_ID` exists
#' in `.Renviron` or elsewhere and no `dataviewId` argument is provided, then the `CJA_DATAVIEW_ID` value will
#' be used. Use [cja_get_dataviews()] to get a list of available `dataviewId`.
#' @param expansion Comma-delimited list of additional segment metadata fields to include on response. See Details for all options available.
#' @param includeType Include additional segments not owned by user. Options include: "shared" "templates" "deleted" "internal"
#' @param locale Locale - Default: "en_US"
#' @param debug Used to help troubleshoot api call issues. Shows the call and result in the console
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
cja_get_metrics <- function(dataviewId = Sys.getenv("CJA_DATAVIEW_ID"),
                            expansion = 'description',
                            includeType = NULL,
                            locale = 'en_US',
                            debug = FALSE) {
    if (dataviewId == ''){
        stop ("The dataviewId argument is required.")
    }
    assertthat::assert_that(
        assertthat::is.string(dataviewId)
    )

    query_params <- list(expansion = expansion,
                         includeType = includeType,
                         locale = locale)

    req_path <- glue::glue('datagroups/data/{dataviewId}/metrics')

    urlstructure <- paste(req_path, format_URL_parameters(query_params), sep = "?")

    req <- cja_call_api(req_path = urlstructure,
                        body = NULL,
                        debug = debug)

    res <- httr::content(req, as = "text",encoding = "UTF-8")

    df <- jsonlite::fromJSON(res)$content

    df %>% mutate(id = stringr::str_remove(id, 'metrics/'))
}
