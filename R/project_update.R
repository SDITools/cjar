#' Update a project in CJA
#'
#' Edits an existing project in CJA
#'
#' @param project The updated/edited project json string
#' @param locale Locale Default value : en_US
#' @param debug Set to `TRUE` to publish the full JSON request(s) being sent to the API to the console when the
#' function is called. The default is `FALSE`.
#'
#' @return A json string
#' @export
#'
cja_update_project <- function(project = NULL,
                        locale = 'en_US',
                        debug = FALSE){
  query_params <- list(
    locale = locale
  )

  req_path <- glue::glue("projects/validate")
  urlstructure <- paste(req_path, format_URL_parameters(query_params), sep = "?")

  res <- cja_call_data(req_path = urlstructure,
                      body = project,
                      debug = debug)

  jsonlite::fromJSON(res)
}
