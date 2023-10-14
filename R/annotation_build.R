#' Build the annotation in CJA
#'
#' This function builds an annotation in Customer Journey Analytics
#'
#' @param name This is the name of the new segment (required)
#' @param description  This is the description of the segment (required)
#' @param date_range The date range of the annotation
#' @param color Color name string representing the annotation's color. Supported values include 'blue', 'purple', 'green', 'orange', 'red', 'light green', 'pink', 'dark green', and 'yellow'.
#' @param applyToAllReports A boolean that determines if the annotation applies to all report suites.
#' @param metric_id The id for the metric scope as found in the `aw_get_metrics()` and `aw_get_calculatedmetrics()` functions.
#' This needs to be a "list()" array of items.
#' @param metric_compType The component type. This is either 'm' for metric or 'cm' for calculated metric. This needs to be a "list()" array of items.
#' @param filter_id The id for the metric scope as found in the `aw_get_dimensions()` and `aw_get_segments()` functions.
#' This needs to be a "list()" array of items.
#' @param filter_verb The verb is the operator of the filter. The options include
#' 'equals', 'equals_any', and 'exists'. If the 'dimension type' is 'enum' or 'ordered_enum' it
#' can only use one of the verbs, 'equals' or 'exists'. This needs to be a "list()" array of items.
#' @param filter_dimType The dimension type as defined by the 'type' column in `aw_get_dimensions()` if it is a dimension that is being
#' used or it is blank because it is a segment. If it is a segment make sure to include an, "''", empty list item. This needs to be a "list()" array of items
#' @param filter_terms If the verb is "equals_any" then this argument should contain a list of values.
#' If the verb is "equals" then the argument should be a single item. This needs to be a "list()" array of list items.
#' @param filter_compType The component type is either a 'd' (dimension) or an 's' (segemnt).
#' This needs to be a "list()" array of items.
#' @param create_annotation Default is TRUE. Set this to FALSE if you want to get the json string that hte function
#' creates.
#' @param dataviewId *Required* The id of the dataview for which to retrieve dimensions. If an environment variable called `CJA_DATAVIEW_ID` exists
#' in `.Renviron` or elsewhere and no `dataviewId` argument is provided, then the `CJA_DATAVIEW_ID` value will
#' be used. Use [cja_get_dataviews()] to get a list of available `dataviewId`.
#' @param debug This enables the api call information to show in the console for
#' help with debugging issues. default is FALSE
#'
#' @return An id of the newly created annotation
#'
#' @import dplyr
#' @import assertthat
#' @import stringr
#' @importFrom glue glue
#' @export
#'
annotation_build <- function(name = NULL,
                             description = NULL,
                             date_range = c(Sys.Date()-30, Sys.Date()-1),
                             color = 'blue',
                             applyToAllReports = FALSE,
                             metric_id = NULL,
                             metric_compType = NULL,
                             filter_id = NULL,
                             filter_verb = NULL,
                             filter_dimType = NULL,
                             filter_terms = NULL,
                             filter_compType = NULL,
                             create_annotation = TRUE,
                             debug = FALSE,
                             dataviewId = Sys.getenv('CJA_DATAVIEW_ID')){
  ##define the color function
  color_it <- function(color){
    clrs <- list('blue', 'purple', 'green', 'orange', 'red', 'light green', 'pink', 'dark green', 'yellow')
    ind <- which(clrs == color)
    paste0('STANDARD', ind)
  }
  #if scoping is needed then we need to scope it according to the metrics and/or dimensions defined arguments
  #Metric scope function
  metrics_scope_it <- function(metric_id, metric_compType){
    if (metric_compType == 'm' || metric_compType == 'metric'){
      metric_id <- paste0('metrics/', metric_id)
      metric_compType <- 'metric'
    } else if (metric_compType %in% c('cm', 'calculatedmetric', 'calculatedMetric')) {
      metric_compType <- 'calculatedMetric'
    }
    list(id = metric_id,
         componentType = metric_compType)
  }
  #build the list of metrics information that has been provided
  metric_info <- list(metric_id, metric_compType)
  #use the list of filters information to generate the filters scope
  metrics_scope <- purrr::pmap(metric_info, metrics_scope_it)

  #Filter/Dimension scope function
  filters_scope_it <- function(filter_id, filter_verb, filter_dimType, filter_terms, filter_compType) {
    #compType
    if(filter_compType == 'd' || filter_compType == 'dimension'){
      filter_id <- paste0('variables/', filter_id)
      filter_compType <- 'dimension'
    } else if (filter_compType == 's' || filter_compType == 'segment'){
      filter_operator <- NULL
      filter_dimType <- NULL
      filter_compType <- 'segment'
    }
    #verb
    if (filter_verb %in% c('eq', 'equals') && filter_dimType %in% c('int', 'ordered_enum')) {
      filter_verb <- 'eq'
    } else if (filter_verb %in% c('streq', 'eq', 'equals') && filter_dimType %in% c('string', 'enum')) {
      filter_verb <- 'streq'
    } else if (filter_verb %in% c('eq_any', 'equals_any') && filter_dimType %in% c('int', 'ordered_enum')) {
      filter_verb <- 'eq-in'
    } else if (filter_verb %in% c('streq_any', 'eq_any', 'equals_any') && filter_dimType == c('string', 'enum')) {
      filter_verb <- 'streq-in'
    }

    list(id = filter_id,
         operator = filter_verb,
         dimensionType = filter_dimType,
         terms = filter_terms,
         componentType = filter_compType)
  }
  #build the list of filters information that has been provided
  filter_info <- list(filter_id, filter_verb, filter_dimType, filter_terms, filter_compType)
  #use the list of filters information to generate the filters scope
  filters_scope <- purrr::pmap(filter_info, filters_scope_it)

  annote_it <- function(name,
                        description,
                        dataviewId,
                        date_range,
                        color,
                        metrics_scope,
                        filters_scope){
    list(name = name,
         description = description,
         dataId = dataviewId,
         dateRange = date_range,
         color = color_it(color),
         scope = list(metrics = metrics_scope, filters = filters_scope))
  }

  body <- annote_it(name = name,
                    description = description,
                    dataId = dataviewId,
                    date_range = make_timeframe(date_range),
                    color = color,
                    metrics_scope = metrics_scope,
                    filters_scope = filters_scope)

  #remove segment list items that are not needed and mess with the api post call
  clean_it <- function(filters) {
    if (filters$componentType == 'segment'){
      filters$operator <- NULL
      filters$dimensionType <- NULL
    }
    if (filters$terms == '') {
      filters$terms <- list()
    }
    return(filters)
  }

  body$scope$filters <- purrr::map(body$scope$filters,  clean_it)
  #defined parts of the post request
  req_path <- 'annotations'

  if (!create_annotation) {
    req <- jsonlite::toJSON(body, auto_unbox = T)
  } else if (create_annotation) {
    req <- cja_call_api(req_path = req_path,
                       debug = debug,
                       body = body)
  }
  req
}
