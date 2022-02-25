#' Build the filter in CJA
#'
#' This function combines rules and/or containers and then makes the post
#' call to create the filter in CJA.
#'
#' @param dataviewId CJA data view id.  If an environment variable called `CJA_DATAVIEW_ID` exists
#' in `.Renviron` or elsewhere and no `dataviewId` argument is provided, then the `CJA_DATAVIEW_ID` value will
#' be used. Use [cja_get_dataviews()] to get a list of available `dataviewId`. Required
#' @param name This is the name of the new filter (required)
#' @param description  This is the description of the filter (required)
#' @param containers List of the container(s) that make up the filter. Containers
#' are list objects created using the [`filter_con()`] function.
#' @param rules List of the rules to create a filter. Rules are
#' list objects created using the `filter_rule()` function.
#' @param sequences List of the predicate(s) and sequence container(s) that are
#' combined to make a filter. Sequence containers are list objects created using
#' the `filter_seq()` function.
#' @param context Defines the level that the filter logic should operate on. Valid
#' values are visitors, visits, and hits. See Details
#' @param conjunction This will tell how the different containers and rules
#' should be compared. Use either 'and' or 'or'.
#' @param sequence Used to define if the filter should be 'in_order' (default),
#' 'after', or 'before' the sequence of events
#' @param sequence_context Used to define the sequential items context which
#' should be below the container context. ex. if container context is visitors
#' then the sequence_context should be visits or hits
#' @param exclude Excludes the main container which will include all rules.
#' Only used when the rule arguments are used.
#' @param create_filter Used to determine if the filter should be created in the
#' UI or if the definition should be returned to be used in a freeform
#' table API call as a global filter. Default is FALSE, which means the segment
#' json string will be returned and the segment will not be created in the UI.
#' @param locale Locale. Default "en_US"
#' @param expansion Comma-delimited list of additional filter metadata fields to
#' include on response. See Detail section for available options
#' @param debug This enables the api call information to show in the console for
#' help with debugging issues. default is FALSE
#'
#' @details
#'
#' **Context**
#' The rules in a filter have a context that specify the level of operation.
#' The context can be visitors, visits or hits.
#' As an example, let's build a filter rule where revenue is greater than 0 (meaning
#' a purchase took place) and change the context to see how things change.
#' If the context is set to visitors, the filter includes all hits from visitors
#' that have a purchase of some kind during a visit. This is useful in analyzing
#' customer behavior in visits leading up to a purchase and possibly behavior after
#' a purchase.
#' the context is set to visits, the filter includes all hits from visits where
#' a purchase occurred. This is useful for seeing the behavior of a visitor in
#' immediate page views leading up to the purchase.
#' If the context is set to hit, the filter only includes hits where a purchase
#' occurred, and no other hits. This is useful in seeing which products were most popular.
#' In the above example, the context for the container listed is hits. This means
#' that the container only evaluates data at the hit level, (in contrast to visit
#' or visitor level). The rows in the container are also at the hit level.
#'
#' **Expansion**
#' Available option include the following:
#' "compatibility" "definition" "internal" "modified" "isDeleted" "definitionLastModified"
#' "createdDate" "recentRecordedAccess" "performanceScore" "owner" "dataId" "ownerFullName"
#' "dataName" "sharesFullName" "approved" "favorite" "shares" "tags" "usageSummary"
#' "usageSummaryWithRelevancyScore"
#'
#' @return If the filter validates it will return a data frame of the newly
#' created filter id along with some other basic meta data. If it returns and
#' error then the error response will be returned to help understand what needs
#' to be corrected. If the argument `create_filter` is set to FALSE, the json string
#' will be returned in list format.
#'
#' @import dplyr
#' @import assertthat
#' @import stringr
#' @importFrom glue glue
#' @export
#'
filter_build <- function(dataviewId = Sys.getenv("CJA_DATAVIEW_ID"),
                         name = NULL,
                         description = NULL,
                         containers = NULL,
                         rules = NULL,
                         sequences = NULL,
                         context = 'hits',
                         conjunction = 'and',
                         sequence = 'in_order',
                         sequence_context = 'hits',
                         exclude = FALSE,
                         create_filter = FALSE,
                         debug = FALSE,
                         locale = 'en_US',
                         expansion = NULL){
  #validate arguments
  if (dataviewId == ''){
    stop("The dataviewId argument is required.")
  }
  if (is.null(name) || is.null(description)) {
    stop('The arguments, `name` and `description`, must be included.')
  }

  #define the new filter version
  version <- list(1, 0, 0)

  #Create the filter list object
  if (!is.null(rules) && is.null(containers) && is.null(sequences)) { ## Rules
    if (exclude == FALSE) {
      if (length(rules) == 1){
        if (!is.null(rules[[1]]$val$`allocation-model`)) {
          if (context == 'visits' && rules[[1]]$val$`allocation-model`$func == 'allocation-dedupedInstance'){
            rules[[1]]$val$`allocation-model`$context = 'sessions'
          }
        }
        filter <- list(
          name = name,
          description = description,
          definition = list(
            container = list(
              func = 'container',
              context = context,
              pred = rules[[1]]
            ),
            func = 'segment',
            version = version
          ),
          dataId = dataviewId
        )
      } else {
        filter <- list(
          name = name,
          description = description,
          definition = list(
            container = list(
              func = 'container',
              context = context,
              pred = list(
                func = conjunction,
                preds = rules
              )
            ),
            func = 'segment',
            version = version
          ),
          dataId = dataviewId
        )
      }
    } #/exclude FALSE
    if (exclude == TRUE) {
      if (length(rules) == 1) {
        filter <-  list(
          name = name,
          description = description,
          definition = list(
            container = list(
              func = 'container',
              context = context,
              pred = list(
                func = 'without',
                pred = rules[[1]]
              )
            ),
            func = 'segment',
            version = version
          ),
          dataId = dataviewId
        )
      } else {
        filter <-  list(
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
                    preds = rules
                  )
                )
              )
            ),
            func = 'segment',
            version = version
          ),
          dataId = dataviewId
        )
      }
    } #/exclude TRUE
  } else if (is.null(rules) && !is.null(containers) && is.null(sequences)){  #Containers
    if (length(containers) == 1) {
      filter <- list(
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
        dataId = dataviewId
      )
    } else {
      filter <-  list(
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
        dataId = dataviewId
      )
    }
  } else if(is.null(rules) && is.null(containers) && !is.null(sequences)) {
    sequence_dir <- dplyr::case_when(sequence == 'in_order' ~ 'sequence',
                                     sequence == 'after' ~ 'sequence-prefix',
                                     sequence == 'before' ~ 'sequence-suffix')

    ## Add in the necessary 'container' and 'hits' variables to each rule for the sequence to work
    seq_items <- list()
    for (i in seq_along(sequences)) {
      if (!is.null(sequences[[i]]$stream)) {
        seq_items[[i]] <- list(
          context = sequence_context,
          func = 'container',
          pred = sequences[[i]]
        )
      } else if (!is.null(sequences[[i]]$val)) {
        seq_items[[i]] <- list(
          context = sequence_context,
          func = 'container',
          pred = sequences[[i]]
        )
      } else {
        seq_items[[i]] <- sequences[[i]]
      }
    }

    filter <- if (sequence_dir == 'sequence') {
      list(
        name = name,
        description = description,
        definition = list(
          container = list(
            func = 'container',
            context = context,
            pred = list(
              func = sequence_dir,
              stream = seq_items
            )
          ),
          func = 'segment',
          version = version
        ),
        dataId = dataviewId
      )
    } else if (sequence_dir %in% c('sequence-prefix', 'sequence-suffix')) {
      list(
        name = name,
        description = description,
        definition = list(
          container = list(
            func = 'container',
            context = 'hits',
            pred = list(
              func = sequence_dir,
              context = context,
              stream = seq_items
            )
          ),
          func = 'segment',
          version = version
        ),
        dataId = dataviewId
      )
    }
  } else if (is.null(rules) & is.null(containers) & is.null(sequences)) {
    stop('Either a predicate(s), containers, or sequences must be provided.')
  }

  body <- filter

  if (!create_filter) {
    req <- jsonlite::toJSON(body, auto_unbox = T)
  } else if (create_filter) {
    #defined parts of the post request
    req_path <- 'filters'

    query_params <- list(locale = locale,
                         expansion = expansion)

    urlstructure <- paste(req_path, format_URL_parameters(query_params), sep = "?")
    #post request
    req <- cja_call_data(req_path = urlstructure,
                         debug = debug,
                         body = body)
  }
  req
}
