#' Get a list of calculated metrics.
#'
#' Retrieve a list of available calculated metrics. The results will always include these default items:
#' `id`, `name`, `description`, `owner`, `polarity`, `precision`, `type`. Other attributes can
#' be optionally requested through the `expansion` field.
#'
#' @details
#' This function is useful/needed to identify the specific ID of a calculated metric for use in other
#' functions like `cja_freeform_report`.
#'
#' The `expansion` argument accepts the following values, which will then include additional columns
#' in the results:
#'
#' * **ownerFullName**: adds `owner.name` and `owner.login` columns to the results (`owner.id` is
#' already included by default).
#'
#' * **modified**: adds a `modified` column to the output with the date (ISO 8601 format) each
#' calculated metric was last modified.
#'
#' * **definition**: adds _multiple_ columns (the number will vary based on the number and complexity
#' of calculated metrics returns) that provide the actual formula for each of the calculated metrics.
#' This is returned from the API as a JSON object and converted into columns by the function, which
#' means it is pretty messy, so, really, it's not recommended that you use this value.
#'
#' * **compatability**: should add a column with the products that the metric is compatible with, but this
#' behavior has not actually been shown to be true, so this may actually do nothing if included.
#'
#' * **reportSuiteName**: adds a `reportSuiteName` and a `siteTitle` column with the friendly report
#' suite name for the RSID.
#'
#' * **tags**: adds a column with an embedded data frame with all of the existing tags that are
#' associated with the calculated metric. This can be a bit messy to work with, but the information
#' is, at least, there.
#'
#' Other Expansion options that are available: "dataName", "approved", "favorite",
#' "shares", "sharesFullName", "usageSummary", "usageSummaryWithRelevancyScore",
#' "siteTitle", "migratedIds", "isDeleted", "authorization", "legacyId",
#' "internal", "dataGroup", "categories"
#'
#' Multiple values for `expansion` can be included in the argument as a vector. For instance,
#' `expansion = c("tags", "modified")` will add both a `tags` column and a `modified` column to the output.
#'
#' @seealso \code{\link{cja_get_metrics}}
#'
#' @param expansion Additional calculated metric metadata fields to include in the results:
#' "dataName" "approved" "favorite" "shares" "tags" "sharesFullName" "usageSummary"
#' "usageSummaryWithRelevancyScore" "reportSuiteName" "siteTitle" "ownerFullName"
#' "modified" "migratedIds" "isDeleted" "definition" "authorization" "compatibility"
#' "legacyId" "internal" "dataGroup" "categories".
#' @param includeType Include additional calculated metrics not owned by user. Available values are `all` (default),
#' `shared`, `templates`, `unauthorized`, `deleted`, `internal`, and `curatedItem`. The `all` option takes precedence over `shared`
#' @param dataviewIds Filter the list to only include calculated metrics tied to a specified dataviewId or
#' list of dataviewIds. Specify multiple dataviewIds as a vector (i.e., "`dataviewIds = c("dataviewid_1", dataviewid_2",...dataviewid_n")`").
#' Use \code{\link{cja_get_dataviews}} to get a list of available `dataviewId` values.
#' @param ownerId Filter the list to only include calculated metrics owned by the specified loginId.
#' @param filterByIds Filter the list to only include calculated metrics in the specified list as
#' specified by a single string or as a vector of strings.
#' @param toBeUsedInRsid 	The data view where the calculated metric intended to be used.
#' This data view will be used to determine things like compatibility and permissions.
#' If it is not specified then the permissions will be calculated based on the union of all metrics
#' authorized in all groups the user belongs to. If the compatibility expansion is specified and toBeUsedInRsid
#' is not then the compatibility returned is based off the compatibility from the last time the calculated metric was saved.
#' @param locale The locale that system-named metrics should be returned in. Non-localized values will
#' be returned for title, name, description, etc. if a localized value is not available.
#' @param favorite Set to `TRUE` to only include calculated metrics that are favorites in the results. A
#' value of `FALSE` will return all calculated metrics, including those that are favorites.
#' @param approved Set to `TRUE` to only include calculated metrics that are approved in the results. A
#' value of `FALSE` will return all calculated metrics, including those that are approved and those that are not.
#' @param pagination return paginated results. Set to 'TRUE' by default
#' @param limit Number of results per page. Default is 10
#' @param page The "page" of results to display. This works in conjunction with the `limit` argument and is
#' zero-based. For instance, if `limit = 10` and `page = 1`, the results returned would be 11 through 20.
#' @param sortDirection The sort direction for the results: `ASC` (default) for ascending or `DESC` for
#' descending. (This is case insensitive, so `asc` and `desc` work as well.)
#' @param sortProperty The property to sort the results by. Currently available values are `id` (default), `name`,
#' and `modified_date`. Note that setting `expansion = modified` returns results with a column added called
#' `modified`, which is the last date the calculated metric was modified. When using this value for `sortProperty`,
#' though, the name of the argument is `modified_date`.
#' @param debug Include the output and input of the api call in the console for debugging. Default is FALSE
#'
#' @return A data frame of calculated metrics and their metadata.
#'
#' @import stringr
#' @importFrom utils URLencode
#' @export
#'
cja_get_calculatedmetrics <- function(expansion = NULL,
                                      includeType = 'all',
                                      dataviewIds = NULL,
                                      ownerId = NULL,
                                      filterByIds = NULL,
                                      toBeUsedInRsid = NULL,
                                      locale = "en_US",
                                      favorite = NULL,
                                      approved = NULL,
                                      pagination = TRUE,
                                      limit = 10,
                                      page = 0,
                                      sortDirection = 'DESC',
                                      sortProperty = NULL,
                                      debug = FALSE)
{

  #includeType is case senstative
  includeType <- tolower(includeType)

  query_params <- list(expansion = expansion,
                       includeType = includeType,
                       dataIds = dataviewIds,
                       ownerId = ownerId,
                       filterByIds = filterByIds,
                       toBeUsedInRsid = toBeUsedInRsid,
                       locale = locale,
                       favorite = favorite,
                       approved = approved,
                       pagination = pagination,
                       limit = limit,
                       page = page,
                       sortDirection = sortDirection,
                       sortProperty = sortProperty)

  req_path <- 'calculatedmetrics'

  urlstructure <- paste(req_path, format_URL_parameters(query_params), sep = "?")

  req <- cja_call_api(req_path = urlstructure,
                      body = NULL,
                      debug = debug)

  tibble::as_tibble(jsonlite::fromJSON(httr::content(req, as = 'text', encoding = "UTF-8"))$content)
}

