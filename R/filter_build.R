#' Build the Segment
#'
#' This function combines predicates into a container.
#'
#' @param dataId This is the data view id that the filter reference.
#' @param name This is the name of the new filter
#' @param description  This is the description of the filter
#' @param containers List of the container(s) that make up the filter
#' @param predicates List of the predicate(s) to create a filter
#' @param context This defines the main container context, either hits, visits (Default), or visitors
#' @param conjunction This will tell how the different containers and predicates should be compared. Use either 'and' or 'or' at this time. Sequential 'then' will be added in a future update.
#' @param exclude excludes the main container which will include all predicates. Only used when the predicate arguments are used.
#' @param version This is the default version. Only used if updating an existing filter. Not to be edited at this time.
#' @param internal Determines if the segment will be seen in the UI or not. If ad-hock analysis, this should be left to default (FALSE) to prevent confusion in the UI.
#' @param debug Helps in troubleshooting function issues
#' @param client_id This is the report suite that the filter will be referenced to.
#' @param client_secret This is the report suite that the filter will be referenced to.
#' @param org_id This is the organization id from the Adobe console project associated with your authentication project.
#'
#' @return A data frame of a newly created filter and corresponding metadata such as ID
#'
#' @import dplyr
#' @import assertthat
#' @import stringr
#' @importFrom glue glue
#' @export
#'
filter_build <- function(dataId = NULL,
                         name = 'this is the name',
                         description = 'this is the description',
                         containers = NULL,
                         predicates = NULL,
                         context = 'hits',
                         conjunction = 'and',
                         exclude = FALSE, #only used if the 'predicates' argument is used
                         version = list(1, 0, 0),
                         internal = TRUE,
                         debug = FALSE,
                         client_id = Sys.getenv("CJA_CLIENT_ID"),
                         client_secret = Sys.getenv("CJA_CLIENT_SECRET"),
                         org_id = Sys.getenv('CJA_ORGANIZATION_ID')){
  assertthat::assert_that(
    assertthat::is.string(dataId),
    assertthat::is.string(name),
    assertthat::is.string(description)
  )
  if(is.null(containers) & !is.null(predicates)) {
    if(exclude == FALSE) {
      if(length(predicates) == 1){
        seg <- structure(list(
          name = name,
          description = description,
          definition = list(
            container = list(
              func = 'container',
              context = context,
              pred = list(
                  func = 'container',
                  context = context,
                  pred = predicates[[1]]
              )
            ),
            func = 'segment',
            version = version
          ),
          dataId = dataId,
          internal = internal
        ))
      } else {
        seg <- structure(list(
          name = name,
          description = description,
          definition = list(
            container = list(
              func = 'container',
              context = context,
              pred = list(
                func = conjunction,
                preds = predicates
              )
            ),
            func = 'segment',
            version = version
          ),
          dataId = dataId,
          internal = internal
        ))
      }
    } #/exclude FALSE
    if(exclude == TRUE) {
      if(length(predicates) == 1) {
        seg <-  structure(list(
          name = name,
          description = description,
          definition = list(
            container = list(
              func = 'container',
              context = context,
              pred = list(
                func = 'without',
                pred = list(
                  func = 'container',
                  context = context,
                  pred = predicates[[1]]
                  )
                )
            ),
            func = 'segment',
            version = version
          ),
          dataId = dataId,
          internal = internal
        ))

      } else {
        seg <-  structure(list(
          name = name,
          description = description,
          definition = list(
            container = list(
              func = 'container',
              context = context,
              pred = list(
                func = 'without',
                pred = list(
                  func = 'container',
                  context = context,
                  pred = list(
                    func = conjunction,
                    preds = predicates
                  )
                )
              )
            ),
            func = 'segment',
            version = version
          ),
          dataId = dataId,
          internal = internal
        ))
      }
    } #/exclude TRUE
  } else if(is.null(predicates) & !is.null(containers)){
    if(length(containers) == 1){
     seg <- structure(list(
       name = name,
       description = description,
        definition = list(
         container = list(
           func = 'container',
           context = context,
           pred = containers[[1]]
           ),
         func = 'segment',
         version = version
         ),
       dataId = dataId
       ))
      } else {
        seg <-  structure(list(
          name = name,
          description = description,
          definition = list(
            func = 'segment',
            version = version,
            container = list(
              func = 'container',
              context = context,
              pred = list(
                func = conjunction,
                preds = containers
              )
            )
          ),
          dataId = dataId,
          internal = internal
        ))
      }
  } else if(is.null(predicates) & is.null(containers)){
    stop('Either a predicate(s) or containers must be provided.')
  }

  #verify that the account has been authorized to make the post request
  token_config <- get_token_config(client_id = client_id, client_secret = client_secret)

  debug_call <- NULL

  if (debug) {
    debug_call <- httr::verbose(data_out = TRUE, data_in = TRUE, info = TRUE)
  }

  #validate the new segment
  req_path <- 'filters/validate'

  request_url <- sprintf("https://cja.adobe.io/%s?locale=en_US",
                         req_path)

  req <- httr::RETRY("POST",
                     url = request_url,
                     body = seg,
                     encode = "json",
                     debug_call,
                     token_config,
                     httr::add_headers(
                       `x-api-key` = client_id,
                       `x-gw-ims-org-id` = org_id
                     ))
  if(!httr::content(req)$valid){
    stop(httr::content(req))
  } else {

    #defined parts of the post request
    req_path = 'filters'
    body = seg
    request_url <- sprintf("https://cja.adobe.io/%s?locale=en_US",
                        req_path)

    req <- httr::RETRY("POST",
                       url = request_url,
                       body = body,
                       encode = "json",
                       debug_call,
                       token_config,
                       httr::verbose(data_out = TRUE),
                       httr::add_headers(
                         `x-api-key` = client_id,
                         `x-gw-ims-org-id` = org_id
                       ))

    dplyr::bind_rows(unlist(httr::content(req)))
  }
}
